# Load .env file environment variables
if (-not (Get-Module -ListAvailable -Name Set-PsEnv)) {
    Install-Module -Name Set-PsEnv -Force
}
Set-PsEnv

# Inlcude the utility files
. "$PSScriptRoot\GetLogicAppActionResult.ps1"

# Variables
$resourceGroupName = $Env:RESOURCEGROUPNAME
$logicAppName = $Env:LOGICAPPNAME
$logicAppUri = $Env:LOGICAPPURI
$uniqueId = New-Guid

Describe "Logic App Integration Tests | UniqueId: $uniqueId" {

    Context "Trigger the logic app" {

        $postBody = @{
            "location"="London"
            "uniqueid"="$uniqueId";
        } | ConvertTo-Json

        $postHeaders = @{
            "Accept"="application/json"
            "Content-Type"="application/json"
        } 

        $request = Invoke-RestMethod -Method 'POST' -Uri $logicAppUri -Body $postBody -Headers $postHeaders
    }

}