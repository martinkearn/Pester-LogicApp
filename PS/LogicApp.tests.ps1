# Invoke with Invoke-Pester -Output Detailed LogicApp.tests.ps1

# Include the utility file
. "$PSScriptRoot\GetLogicAppActionResult.ps1"

Describe "Logic App Integration Tests | UniqueId: $uniqueId" {

    BeforeAll {
        # Load .env file environment variables
        if (-not (Get-Module -ListAvailable -Name Set-PsEnv)) {
            Install-Module -Name Set-PsEnv -Force
        }
        Set-PsEnv

        # Variables
        $uniqueId = New-Guid
    }

    Context "Host machine has the environment variables setup correctly" {
        It "Expects LOGICAPPURI environment variables to be setup" {
            $env:LOGICAPPURI | Should -Not -BeNullOrEmpty
        }
        It "Expects LOGICAPPNAME environment variables to be setup" {
            $env:LOGICAPPNAME | Should -Not -BeNullOrEmpty
        }
        It "Expects RESOURCEGROUPNAME environment variables to be setup" {
            $env:RESOURCEGROUPNAME | Should -Not -BeNullOrEmpty
        }
    }

    Context "Trigger the logic app" {

        $postBody = @{
            "location"="London"
            "uniqueid"="$uniqueId";
        } | ConvertTo-Json

        $postHeaders = @{
            "Accept"="application/json"
            "Content-Type"="application/json"
        } 

        $request = Invoke-RestMethod -Method 'POST' -Uri $env:LOGICAPPURI -Body $postBody -Headers $postHeaders
    }

}