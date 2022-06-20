﻿function Invoke-IntuneBackupDeviceCompliancePolicy {
   
    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Create folder if not exists
    if (-not (Test-Path "$Path\Device Compliance Policies")) {
        $null = New-Item -Path "$Path\Device Compliance Policies" -ItemType Directory
    }

    # Get all Device Compliance Policies
    $deviceCompliancePolicies = Get-DeviceManagement_DeviceCompliancePolicies | Get-MSGraphAllPages
    
    foreach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
        Write-Output "Backing Up - Device Compliance Policy: $($deviceCompliancePolicy.displayName)"
        $fileName = ($deviceCompliancePolicy.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $deviceCompliancePolicy | ConvertTo-Json | Out-File -LiteralPath "$path\Device Compliance Policies\$fileName.json"
    }
}
