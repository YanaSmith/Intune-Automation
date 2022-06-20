function Invoke-IntuneBackupDeviceCompliancePolicyAssignment {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

       # Create folder if not exists
    if (-not (Test-Path "$Path\Device Compliance Policies\Assignments")) {
        $null = New-Item -Path "$Path\Device Compliance Policies\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $deviceCompliancePolicies = Get-DeviceManagement_DeviceCompliancePolicies | Get-MSGraphAllPages

    foreach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
        $assignments = Get-DeviceManagement_DeviceCompliancePolicies_Assignments -DeviceCompliancePolicyId $deviceCompliancePolicy.id 
        if ($assignments) {
            Write-Output "Backing Up - Device Compliance Policy - Assignments: $($deviceCompliancePolicy.displayName)"
            $fileName = ($deviceCompliancePolicy.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\Device Compliance Policies\Assignments\$fileName.json"
        }
    }
}
