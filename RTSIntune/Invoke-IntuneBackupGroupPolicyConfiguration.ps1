
function Invoke-IntuneBackupGroupPolicyConfiguration {
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $false)]
        [ValidateSet("v1.0", "Beta")]
        [string]$ApiVersion = "Beta"
    )
   
    # Create folder if not exists
    if (-not (Test-Path "$Path\Administrative Templates")) {
        $null = New-Item -Path "$Path\Administrative Templates" -ItemType Directory
    }

    # Get all Group Policy Configurations
    $groupPolicyConfigurations = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations" | Get-MSGraphAllPages

    foreach ($groupPolicyConfiguration in $groupPolicyConfigurations) {
        $groupPolicyDefinitionValues = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations/$($groupPolicyConfiguration.id)/definitionValues" | Get-MSGraphAllPages
        $groupPolicyBackupValues = @()

        foreach ($groupPolicyDefinitionValue in $groupPolicyDefinitionValues) {
            $groupPolicyDefinition = Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations/$($groupPolicyConfiguration.id)/definitionValues/$($groupPolicyDefinitionValue.id)/definition"
            $groupPolicyPresentationValues = (Invoke-MSGraphRequest -HttpMethod GET -Url "deviceManagement/groupPolicyConfigurations/$($groupPolicyConfiguration.id)/definitionValues/$($groupPolicyDefinitionValue.id)/presentationValues?`$expand=presentation").Value | Select-Object -Property * -ExcludeProperty lastModifiedDateTime, createdDateTime
            $groupPolicyBackupValue = @{
                "enabled" = $groupPolicyDefinitionValue.enabled
                "definition@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($groupPolicyDefinition.id)')"
            }

            if ($groupPolicyPresentationValues.value) {
                $groupPolicyBackupValue."presentationValues" = @()
                foreach ($groupPolicyPresentationValue in $groupPolicyPresentationValues) {
                    $groupPolicyBackupValue."presentationValues" +=
                        @{
                            "@odata.type" = $groupPolicyPresentationValue.'@odata.type'
                            "value" = $groupPolicyPresentationValue.value
                            "presentation@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($groupPolicyDefinition.id)')/presentations('$($groupPolicyPresentationValue.presentation.id)')"
                        }
                }
            } elseif ($groupPolicyPresentationValues.values) {
                $groupPolicyBackupValue."presentationValues" = @(
                    @{
                        "@odata.type" = $groupPolicyPresentationValues.'@odata.type'
                        "values" = @(
                            foreach ($groupPolicyPresentationValue in $groupPolicyPresentationValues.values) {
                                @{
                                    "name" = $groupPolicyPresentationValue.name
                                    "value" = $groupPolicyPresentationValue.value
                                }
                            }
                        )
                        "presentation@odata.bind" = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions('$($groupPolicyDefinition.id)')/presentations('$($groupPolicyPresentationValues.presentation.id)')"
                    }
                )
            }

            $groupPolicyBackupValues += $groupPolicyBackupValue
        }

        Write-Output "Backing Up - Administrative Template: $($groupPolicyConfiguration.displayName)"
        $fileName = ($groupPolicyConfiguration.displayName).Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $groupPolicyBackupValues | ConvertTo-Json -Depth 5 | Out-File -LiteralPath "$path\Administrative Templates\$fileName.json"
    }
}
