# Invoke with Invoke-Pester -Output Detailed LogicApp.tests.ps1

BeforeDiscovery {
    # Include the utility file
    . "$PSScriptRoot\GetLogicAppActionResult.ps1"

    $uniqueId = New-Guid
}

Describe "Logic App Integration Tests | UniqueId: $uniqueId" {
    Context "Host machine has the environment variables setup correctly" {
        It "Expects LOGICAPPURI environment variables to be setup" {
            $env:LOGICAPPURI | Should -Not -BeNullOrEmpty
        }
    }

    Context "Trigger the logic app and test the results" {
        BeforeAll { 
            $postBody = @{
                location = "London"
                uniqueid = $uniqueId
            } | ConvertTo-Json

            $response = Invoke-WebRequest -Method POST -Uri $env:LOGICAPPURI -Body $postBody -ContentType "application/json"
        }

        It "Post request completed with 200" {
            $response.StatusCode | Should -Be 200
        }
    }

}