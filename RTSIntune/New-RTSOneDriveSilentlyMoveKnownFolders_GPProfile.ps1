
function New-RTSOneDriveSilentlyMoveKnownFolders_GPProfile {

    #Get-InstalledModule Microsoft.Graph
    #Update-Module Microsoft.Graph
    #Connect-MSGraph 

    $tenantIdUrl = "https://graph.microsoft.com/v1.0/organization"

    try {
              $tenantId = (Invoke-MSGraphRequest -HttpMethod Get -Url  $tenantIdUrl).Value.id

         } catch {

              Write-Output "Failed to get tenant ID"
              Write-Error $_ -ErrorAction Continue

        }

    $deviceGPName = "RTS: Silently move Windows known folders to OneDrive"
    $newGPRequestUrl = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations" 
    $newGPRequestBodyJson = '{
                                "description":"",
                                "displayName":"RTS: Silently move Windows known folders to OneDrive"

                              }'

     try {
              $id = Invoke-MSGraphRequest -HttpMethod POST -Content $newGPRequestBodyJson -Url $newGPRequestUrl | Select id

          } catch {

              Write-Output "$deviceGPName - Failed to create Device Configuration Profile"
              Write-Error $_ -ErrorAction Continue

         }
        
     $newGPRequestUrl1 = "$newGPRequestUrl/$($id.id)/definitionValues" 
     $newGPRequestBodyJson1 = '{
                                  "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions(\u002739147fa2-6c5e-437b-8264-19b50b891709\u0027)",
                                  "presentationValues":  [
                               {
                                   "presentation@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions(\u002739147fa2-6c5e-437b-8264-19b50b891709\u0027)/presentations(\u0027fbefbbdf-5382-477c-8b6c-71f4a06e2805\u0027)",
                                   "value":  "0b27f34b-7ce7-4148-bb80-466d281afce0",
                                   "@odata.type":  "#microsoft.graph.groupPolicyPresentationValueText"
                               },
                               {
                                   "presentation@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions(\u002739147fa2-6c5e-437b-8264-19b50b891709\u0027)/presentations(\u002735c82072-a93b-4022-be14-8684c2f6fcc2\u0027)",
                                   "value":  "1",
                                   "@odata.type":  "#microsoft.graph.groupPolicyPresentationValueText"
                               }
                                                     ],
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