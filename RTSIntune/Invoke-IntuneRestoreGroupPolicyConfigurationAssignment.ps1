function Invoke-IntuneRestoreGroupPolicyConfigurationAssignment {
   
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
    $groupPolicyConfigurations = Get-ChildItem -Path "$Path\Administrative Templates\Assignments"
    foreach ($groupPolicyConfiguration in $groupPolicyConfigurations) {
        $groupPolicyConfigurationAssignments = Get-Content -LiteralPath $groupPolicyConfiguration.FullName | ConvertFrom-Json
        $groupPolicyConfigurationId = ($groupPolicyConfigurationAssignments[0]).id.Split("_")[0]

        # Create the base requestBody
        $requestBody = @{
            assignments = @()
        }
        
        # Add assignments to restore to the request body
        foreach ($groupPolicyConfigurationAssignment in $groupPolicyConfigurationAssignments) {
            $requestBody.assignments += @{
                "target" = $groupPolicyConfigurationAssignment.target
            }
        }

        # Convert the PowerShell object to JSON
        $requestBody = $requestBody | ConvertTo-Json -Depth 3

        # Get the Group Policy Configuration we are restoring the assignments for
        try {
            if ($restoreById) {
                $groupPolicyConfigurationObject = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations/$groupPolicyConfigurationId"
            }
            else {
                $groupPolicyConfigurationObject = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations" | Get-MSGraphAllPages | Where-Object displayName -eq "$($groupPolicyConfiguration.BaseName)"
                if (-not ($groupPolicyConfigurationObject)) {
                    Write-Warning "Error retrieving Intune Administrative Template for $($groupPolicyConfiguration.FullName). Skipping assignment restore"
                    continue
                }
            }
        }
        catch {
            Write-Output "Error retrieving Intune Administrative Template for $($groupPolicyConfiguration.FullName). Skipping assignment restore"
            Write-Error $_ -ErrorAction Continue
            continue
        }

        # Restore the assignments
        try {
            $null = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/groupPolicyConfigurations/$($groupPolicyConfigurationObject.id)/assign" -ErrorAction Stop
            Write-Output "$($groupPolicyConfigurationObject.displayName) - Successfully restored Administrative Template Assignment(s)"
        }
        catch {
            Write-Output "$($groupPolicyConfigurationObject.displayName) - Failed to restore Administrative Template Assignment(s)"
            Write-Error $_ -ErrorAction Continue
        }
    }
}