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

            $postResponse = Invoke-WebRequest -Method POST -Uri $env:LOGICAPPURI -Body $postBody -ContentType "application/json"
            $location = $postResponse.Headers.Location
        }

        It "Has responded with a 20x status code" {
            if ($location -ne $null)
            {
                $postResponse.StatusCode | Should -Be 202
                $result = Wait-ForLogicAppToComplete -LogicappUri $location -TimeoutMinutes 10
                $result.StatusCode | Should -Be 200
            }
            else {
                $postResponse.StatusCode | Should -Be 200
            }
        }
    }

}