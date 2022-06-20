function Invoke-IntuneRestoreDeviceConfigurationAssignment {
   
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [bool]$RestoreById = $false,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

  
    # Get all policies with assignments
    $deviceConfigurations = Get-ChildItem -Path "$Path\Device Configurations\Assignments"
    foreach ($deviceConfiguration in $deviceConfigurations) {
        $deviceConfigurationAssignments = Get-Content -LiteralPath $deviceConfiguration.FullName | ConvertFrom-Json

        # Create the base requestBody
        $requestBody = @{
            assignments = @()
        }
        
        # Add assignments to restore to the request body
        foreach ($deviceConfigurationAssignment in $deviceConfigurationAssignments) {
            $requestBody.assignments += @{
                "target" = $deviceConfigurationAssignment.target
            }
        }

        # Convert the PowerShell object to JSON
        $requestBody = $requestBody | ConvertTo-Json -Depth 3

        # Get the Device Configuration we are restoring the assignments for
        try {
            if ($restoreById) {
                $deviceConfigurationObject = Get-DeviceManagement_DeviceConfigurations -DeviceConfigurationId $deviceConfigurationAssignments[0].deviceConfigurationId
            }
            else {
                $deviceConfigurationObject = Get-DeviceManagement_DeviceConfigurations | Get-MSGraphAllPages | Where-Object displayName -eq "$($deviceConfiguration.BaseName)"
                if (-not ($deviceConfigurationObject)) {
                    Write-Warning "Error retrieving Intune Device Configuration for $($deviceConfiguration.FullName). Skipping assignment restore"
                    continue
                }
            }
        }
        catch {
            Write-Output "Error retrieving Intune Device Configuration for $($deviceConfiguration.FullName). Skipping assignment restore"
            Write-Error $_ -ErrorAction Continue
            continue
        }

        # Restore the assignments
        try {
            $null = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceConfigurations/$($deviceConfigurationObject.id)/assign" -ErrorAction Stop
            Write-Output "$($deviceConfigurationObject.displayName) - Successfully restored Device Configuration Assignment(s)"
        }
        catch {
            Write-Output "$($deviceConfigurationObject.displayName) - Failed to restore Device Configuration Assignment(s)"
            Write-Error $_ -ErrorAction Continue
        }
    }
}
