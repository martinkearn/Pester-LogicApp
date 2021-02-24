# Invoke with Invoke-Pester -Output Detailed LogicApp.tests.ps1

BeforeAll { 
    . $PSScriptRoot/Utilities.ps1
}

BeforeDiscovery {
    # Load environment variables from local .env file by using Set-PsEnv
    if (-not (Get-Module -ListAvailable -Name Set-PsEnv)) {
        Install-Module -Name Set-PsEnv -Force
    }
    Set-PsEnv

    $uniqueId = New-Guid
}

Describe "Logic App Integration Tests | UniqueId: $uniqueId" {

    Context "Host machine has the environment variables setup correctly" {

        It "Expects LOGICAPPURI environment variable to be setup" {
            $env:LOGICAPPURI | Should -Not -BeNullOrEmpty
        }

        It "Expects LOGICAPPNAME environment variable to be setup" {
            $env:LOGICAPPNAME | Should -Not -BeNullOrEmpty
        }

        It "Expects RESOURCEGROUPNAME environment variable to be setup" {
            $env:RESOURCEGROUPNAME | Should -Not -BeNullOrEmpty
        }

    }

    Context "Trigger the logic app and test the results" {
        BeforeAll { 
            $postBody = @{
                location = "London"
                uniqueid = $uniqueId
            } | ConvertTo-Json
            $response = Invoke-WebRequest -Method POST -Uri $env:LOGICAPPURI -Body $postBody -ContentType "application/json"
            $locationHeader = $response.Headers.Location
        }
        It "Has sucessfully completed" {
            if ($locationHeader -ne $null)
            {
                # This means that async repsonses are enabled on the Logic App so we expect an initial 202 with a header called 'location' containing a uri to get final status.
                $response.StatusCode | Should -Be 202
                # Wait until the uri on the 'location' header eventually returns 200, then overwrite the initial response with the final one.
                $response = Wait-ForLogicAppToComplete -LogicappUri $locationHeader -TimeoutMinutes 10
            }

            # Both async and non-async should eventually have a 200 status code.
            $response.StatusCode | Should -Be 200
        }
    }

}