# Invoke with Invoke-Pester -Output Detailed LogicApp.tests.ps1

BeforeAll { 
    . $PSScriptRoot/Utilities.ps1

    # Set a unique Id for teh test. This is so we can track the logic app run that this test generates
    $uniqueId = New-Guid
    Write-Host "UniqueId for test is $uniqueId"
}

BeforeDiscovery {
    # Load environment variables from local .env file by using Set-PsEnv
    if (-not (Get-Module -ListAvailable -Name Set-PsEnv)) {
        Install-Module -Name Set-PsEnv -Force
    }
    Set-PsEnv 
}

Describe "Logic App Integration Tests" {

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

Context "Trigger the logic app" {

    BeforeAll {
        $postBody = @{
            location = "London"
            uniqueid = "$uniqueId"
        } | ConvertTo-Json
        $response = Invoke-WebRequest -Method POST -Uri $env:LOGICAPPURI -Body $postBody -ContentType "application/json"
    }

    It "Has sucessfully completed" {
        # If async responses are enabled on the Logic App, we expect an initial 202 with a header called 'location' containing a uri to get final status which will eventually be 200. Otherwise we just expect a 200 response
        if ($response.Headers.Location -ne $null)
        {
            Write-Host "This Logic App is configured for async responses. It will take longer to get the final response."
            $response.StatusCode | Should -Be 202
            $response = Wait-ForLogicAppToComplete -LogicappUri $response.Headers.Location -TimeoutMinutes 10
        }

        # Both async and non-async should eventually have a 200 status code.
        $response.StatusCode | Should -Be 200
    }

}

    Context "Check the result of the logic app" {
        
        BeforeAll {
        }

        It "Is a forecast for GB" {
        }

        It "Is a forecast for London" {
        }
    }

}