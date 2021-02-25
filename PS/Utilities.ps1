function Get-LogicAppActionResult {
    param(
        [Parameter(Mandatory=$true)][string] $ActionName,
        [Parameter(Mandatory=$true)][string] $UniqueId,
        [Parameter(Mandatory=$true)][string] $ResourceGroupName,
        [Parameter(Mandatory=$true)][string] $LogicAppName
    )

    # Setup variables
    $timeoutMinutes = 30
    $start = Get-Date

    # Keep trying until we return or reach timeoutMinutes
    do {
        # Get logic app trigger history
        # NOTE: this will only return the 30 most recent runs, which is not enough if the system is under load. Need to use the NextLink to get the next page. See https://github.com/Azure/azure-powershell/issues/9141
        $runHistory = Get-AzLogicAppRunHistory -ResourceGroupName $ResourceGroupName -Name $LogicAppName

        # Loop through run history and check each one to see if it matches the uniqueId we are looking for
        foreach ($run in $runHistory) {
            # Make sure that we have an output link as there may be failed runs with no output link in the history
            if ($null -eq $run.Trigger.OutputsLink) {
                Write-Host 'Detected null - skipping.'
                continue;
            }

            # Get the output link doucment content. Get-AzlogicAppRunHistory just gives us a link to a json document which contains the output links, therefore we have to go and get the json document seperately.
            $outputLinksContent = (Invoke-WebRequest -Method 'GET' -Uri $run.Trigger.OutputsLink.Uri).Content | ConvertFrom-Json

            # For very large outputs, the content is base 63 encoded. Use this to decode body from base 64 string, overriding the $outputLinksContent
            #$outputLinksContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($outputLinksContent.body.ContentData)) | ConvertFrom-Json

            # Check that the run is the one we are looking for by matching uniqueId to the passed in parameter
            if ($outputLinksContent.body.uniqueId -like "*$UniqueId*") {

                # If we have a failed run, we fail the test by throwing
                if ($run.Status -eq "Failed") {
                    throw "LogicApp run $UniqueId failed"
                }

                # If the run succeeded then we can check the output
                if ($run.Status -eq "Succeeded") {

                    # We have a matching run. Get the output from the specified action
                    $actionResult = Get-AzLogicAppRunAction -ResourceGroupName $ResourceGroupName -Name $LogicAppName -RunName $run.Name -ActionName $ActionName
                    if ($null -ne $actionResult.OutputsLink.Uri) 
                    {
                        $actionResultContent = (Invoke-WebRequest -Method 'GET' -Uri $actionResult.OutputsLink.Uri).Content | ConvertFrom-Json
                    } else {
                        throw "LogicApp run action $ActionName had no content"
                    }

                    return @{
                        Response = $actionResultContent;
                        Run      = $run;
                    }
                }
            }
        }

        # Snooze
        Write-Host "Retrying after a 30 second snooze"
        Start-Sleep -s 30
        
    } while ($start.AddMinutes($timeoutMinutes) -gt (Get-Date))

    throw "Timeout for $UniqueId"
}

function Wait-ForLogicAppToComplete {
    param (
        [parameter(Mandatory = $true)] [string] $LogicAppUri,
        [parameter(Mandatory = $true)] [int] $TimeoutMinutes
    )

    $startDate = Get-Date

    do {
        $response = Invoke-WebRequest -Method GET -Uri $LogicAppUri

        if ($response.StatusCode -ge 500) {
            throw "LogicApp GET $LogicAppUri returned error status code $($response.StatusCode)"
        }
        
        if ($response.StatusCode -eq 200) {
            return $response
        }

        Start-Sleep -s 10
    } while ($startDate.AddMinutes($TimeoutMinutes) -gt (Get-Date))
}

function HelloWorld {
    Write-Host "hello world"
}