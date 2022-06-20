function Invoke-IntuneRestoreDeviceConfiguration {
   
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Get all device configurations
    $deviceConfigurations = Get-ChildItem -Path "$path\Device Configurations"
    
    foreach ($deviceConfiguration in $deviceConfigurations) {
        $deviceConfigurationContent = Get-Content -LiteralPath $deviceConfiguration.FullName -Raw
        $deviceConfigurationDisplayName = ($deviceConfigurationContent | ConvertFrom-Json).displayName

        # Remove properties that are not available for creating a new configuration
        $requestBodyObject = $deviceConfigurationContent | ConvertFrom-Json
        # Set SupportsScopeTags to $false, because $true currently returns an HTTP Status 400 Bad Request error.
        if ($requestBodyObject.supportsScopeTags) {
            $requestBodyObject.supportsScopeTags = $false
        }

        $requestBodyObject.PSObject.Properties | Foreach-Object {
            if ($null -ne $_.Value) {
                if ($_.Value.GetType().Name -eq "DateTime") {
                    $_.Value = (Get-Date -Date $_.Value -Format s) + "Z"
                }
            }
        }

        $requestBody = $requestBodyObject | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version | ConvertTo-Json

        # Restore the device configuration
        try {
            $null = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceConfigurations" -ErrorAction Stop
            Write-Output "$deviceConfigurationDisplayName - Successfully restored Device Configuration"
        }
        catch {
            Write-Output "$deviceConfigurationDisplayName - Failed to restore Device Configuration"
            Write-Error $_ -ErrorAction Continue
        }
    }
}