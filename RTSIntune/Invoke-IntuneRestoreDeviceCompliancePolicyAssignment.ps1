﻿function Invoke-IntuneRestoreDeviceCompliancePolicyAssignment {
   
    
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
    $deviceCompliancePolicies = Get-ChildItem -Path "$Path\Device Compliance Policies\Assignments"
    foreach ($deviceCompliancePolicy in $deviceCompliancePolicies) {
        $deviceCompliancePolicyAssignments = Get-Content -LiteralPath $deviceCompliancePolicy.FullName | ConvertFrom-Json
        $deviceCompliancePolicyId = ($deviceCompliancePolicyAssignments[0]).id.Split("_")[0]

        # Create the base requestBody
        $requestBody = @{
            assignments = @()
        }

        # Add assignments to restore to the request body
        foreach ($deviceCompliancePolicyAssignment in $deviceCompliancePolicyAssignments) {
            $requestBody.assignments += @{
                "target" = $deviceCompliancePolicyAssignment.target
            }
        }

        # Convert the PowerShell object to JSON
        $requestBody = $requestBody | ConvertTo-Json -Depth 3

        # Get the Device Compliance Policy we are restoring the assignments for
        try {
            if ($restoreById) {
                $deviceCompliancePolicyObject = Get-DeviceManagement_DeviceCompliancePolicies -DeviceCompliancePolicyId $deviceCompliancePolicyId
            }
            else {
                $deviceCompliancePolicyObject = Get-DeviceManagement_DeviceCompliancePolicies | Get-MSGraphAllPages | Where-Object displayName -eq "$($deviceCompliancePolicy.BaseName)"
                if (-not ($deviceCompliancePolicyObject)) {
                    Write-Warning "Error retrieving Intune Compliance Policy for $($deviceCompliancePolicy.FullName). Skipping assignment restore"
                    continue
                }
            }
        }
        catch {
            Write-Output "Error retrieving Intune Device Compliance Policy for $($deviceCompliancePolicy.FullName). Skipping assignment restore"
            Write-Error $_ -ErrorAction Continue
            continue
        }

        # Restore the assignments
        try {
            $null = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceCompliancePolicies/$($deviceCompliancePolicyObject.id)/assign" -ErrorAction Stop
            Write-Output "$($deviceCompliancePolicyObject.displayName) - Successfully restored Device Compliance Policy Assignment(s)"
        }
        catch {
            Write-Output "$($deviceCompliancePolicyObject.displayName) - Failed to restore Device Compliance Policy Assignment(s)"
            Write-Error $_ -ErrorAction Continue
        }
    }
}
