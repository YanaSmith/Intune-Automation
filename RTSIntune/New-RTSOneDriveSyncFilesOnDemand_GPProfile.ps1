function New-RTSOneDriveSyncFilesOnDemand_GPProfile{

    #Get-InstalledModule Microsoft.Graph
    #Update-Module Microsoft.Graph
    #Connect-MSGraph 

    [CmdletBinding()]

    $deviceGPName = "RTS: OneDrive Sync Files On Demand"
    $newGPRequestUrl = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations" 
    $newGPRequestBodyJson = '{
                                "description":"",
                                "displayName":"RTS: OneDrive Sync Files On Demand"

                              }'

     try {
              $id = Invoke-MSGraphRequest -HttpMethod POST -Content $newGPRequestBodyJson -Url $newGPRequestUrl | Select id

            } catch {

              Write-Output "$deviceGPName - Failed to create Device Configuration Profile $deviceGPName "
              Write-Error $_ -ErrorAction Continue

            }
        
     $newGPRequestUrl1 = "$newGPRequestUrl/$($id.id)/definitionValues" 
     $newGPRequestBodyJson1 = '{
                                    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions(\u002761b07a01-7e60-4127-b086-f6b32458a5c5\u0027)",
                                    "enabled":  true

                                }'

        try {

              $id1 = Invoke-MSGraphRequest -HttpMethod POST -Content $newGPRequestBodyJson1 -Url $newGPRequestUrl1

            } catch {

              Write-Error $_ -ErrorAction Continue

            }
        
       
       $assignToAll = Read-Host "Would you like to assign the profile to all licensed users? Y/N"
       $assignToAll = ($assignToAll).ToUpper() 

       if ($assignToAll -eq 'Y'){

           $newGPRequestUrl2 = "$newGPRequestUrl/$($id.id)/assignments"
           $newGPRequestBodyJson2 = '{
                                        "@odata.type": "#microsoft.graph.groupPolicyConfigurationAssignment",
                                        "target":{"@odata.type": "#microsoft.graph.allLicensedUsersAssignmentTarget"}
                                     }'

            try {
                   Invoke-MSGraphRequest -HttpMethod POST -Content $newGPRequestBodyJson2 -Url $newGPRequestUrl2 | Out-Null 
                   Write-Host "Device Configuration Profile '$deviceGPName' is successfully created and assigned to all licensed users" -ForegroundColor Green

                 } catch {

                   Write-Error $_ -ErrorAction Continue

                }

        } else { 

              Write-Host "Profile '$deviceGPName' is created but not assigned" -ForegroundColor Yellow

       }
}