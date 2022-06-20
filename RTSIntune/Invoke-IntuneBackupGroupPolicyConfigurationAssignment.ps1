﻿function Invoke-IntuneBackupGroupPolicyConfigurationAssignment {
   
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Set the Microsoft Graph API endpoint
    if (-not ((Get-MSGraphEnvironment).SchemaVersion -eq $apiVersion)) {
        Update-MSGraphEnvironment -SchemaVersion $apiVersion -Quiet
        Connect-MSGraph -ForceNonInteractive -Quiet
    }

    # Create folder if not exists
    if (-not (Test-Path "$Path\Administrative Templates\Assignments")) {
        $null = New-Item -Path "$Path\Administrative Templates\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $groupPolicyConfigurations = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations" | Get-MSGraphAllPages

    foreach ($groupPolicyConfiguration in $groupPolicyConfigurations) {
        $assignments = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations/$($groupPolicyConfiguration.id)/assignments" | Get-MSGraphAllPages
        
        if ($assignments) {
            Write-Output "Backing Up - Administrative Templates - Assignments: $($groupPolicyConfiguration.displayName)"
            $fileName = ($groupPolicyConfiguration.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\Administrative Templates\Assignments\$fileName.json"
        }
    }
}
