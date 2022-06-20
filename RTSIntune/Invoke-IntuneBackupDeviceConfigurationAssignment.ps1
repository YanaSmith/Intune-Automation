
function Invoke-IntuneBackupDeviceConfigurationAssignment {
   
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Create folder if not exists
    if (-not (Test-Path "$Path\Device Configurations\Assignments")) {
        $null = New-Item -Path "$Path\Device Configurations\Assignments" -ItemType Directory
    }

    # Get all assignments from all policies
    $deviceConfigurations = Get-DeviceManagement_DeviceConfigurations | Get-MSGraphAllPages

    foreach ($deviceConfiguration in $deviceConfigurations) {
        $assignments = Get-DeviceManagement_DeviceConfigurations_Assignments -DeviceConfigurationId $deviceConfiguration.id 
        if ($assignments) {
            Write-Output "Backing Up - Device Configuration - Assignments: $($deviceConfiguration.displayName)"
            $fileName = ($deviceConfiguration.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
            $assignments | ConvertTo-Json | Out-File -LiteralPath "$path\Device Configurations\Assignments\$fileName.json"
        }
    }
}
