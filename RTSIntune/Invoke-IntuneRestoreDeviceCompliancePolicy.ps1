function Invoke-IntuneRestoreDeviceCompliancePolicy {
    
    [CmdletBinding()] 

    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )

    # Get all Device Compliance Policies
    $deviceCompliancePolicies = Get-ChildItem -Path "$Path\Device Compliance Policies" -File
    foreach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
        $deviceCompliancePolicyContent = Get-Content -LiteralPath $deviceCompliancePolicy.FullName -Raw
        $deviceCompliancePolicyDisplayName = ($deviceCompliancePolicyContent | ConvertFrom-Json).displayName

        # Remove properties that are not available for creating a new configuration
        $requestBodyObject = $deviceCompliancePolicyContent | ConvertFrom-Json
        $requestBody = $requestBodyObject | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime | ConvertTo-Json

        # If missing, adds a default required block scheduled action to the compliance policy request body, as this value is not returned when retrieving compliance policies.
        $requestBodyObject = $requestBody | ConvertFrom-Json
        if (-not ($requestBodyObject.scheduledActionsForRule)) {
            $scheduledActionsForRule = @(
                @{
                    ruleName = "PasswordRequired"
                    scheduledActionConfigurations = @(
                        @{
                            actionType = "block"
                            gracePeriodHours = 0
                            notificationTemplateId = ""
                        }
                    )
                }
            )
            $requestBodyObject | Add-Member -NotePropertyName scheduledActionsForRule -NotePropertyValue $scheduledActionsForRule
            
            # Update the request body reflecting the changes
            $requestBody = $requestBodyObject | ConvertTo-Json -Depth 4
        }

        # Restore the Device Compliance Policy
        try {
            $null = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceCompliancePolicies" -ErrorAction Stop
            Write-Output "$deviceCompliancePolicyDisplayName - Successfully restored Device Compliance Policy"
        }
        catch {
            Write-Output "$deviceCompliancePolicyDisplayName - Failed to restore Device Compliance Policy"
            Write-Error $_ -ErrorAction Continue
        }
    }
}
