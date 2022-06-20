
function Connect-RTSIntune {

    $global:userName = Read-Host "Enter the Global Admin user name" 
    $global:pWord = Read-Host -AsSecureString  "Enter the password of the Global Admin"  
    $global:credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList  $userName, $pWord

    try {
                Connect-MSGraph -Credential $credential

        } catch {

                Connect-MSGraph 
        }
}

function New-RTSOneDriveSyncSSO_ConfProfile {

    #Get-InstalledModule Microsoft.Graph
    #Update-Module Microsoft.Graph
    #Connect-MSGraph 

    [CmdletBinding()]

    $deviceGPName = "RTS: OneDrive Sync SSO"
    $newGPRequestUrl = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations" 
    $newGPRequestBodyJson = '{
                                "description":"",
                                "displayName":"RTS: OneDrive Sync SSO"

                              }'

     try {
              $id = Invoke-MSGraphRequest -HttpMethod POST -Content $newGPRequestBodyJson -Url $newGPRequestUrl | Select id

            } catch {

              Write-Output "$deviceGPName - Failed to create Device Configuration Profile"
              Write-Error $_ -ErrorAction Continue

            }
        
     $newGPRequestUrl1 = "$newGPRequestUrl/$($id.id)/definitionValues" 
     $newGPRequestBodyJson1 = '{
                                    "definition@odata.bind":  "https://graph.microsoft.com/beta/deviceManagement/groupPolicyDefinitions(\u002781c07ba0-7512-402d-b1f6-00856975cfab\u0027)",
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

function New-RTSM365Windows10DefaultPolicy_ConfProfile {

    [CmdletBinding()]

    $displayName = "M365: Windows 10 Default Policy"
    $jsonFile = @"
{
    "@odata.type":  "#microsoft.graph.windows10GeneralConfiguration",
    "id":  "79a2d463-1e56-4b5f-85f4-bee330ad9282",
    "lastModifiedDateTime":  "\/Date(1600391855131)\/",
    "roleScopeTagIds":  [
                            "0"
                        ],
    "supportsScopeTags":  true,
    "deviceManagementApplicabilityRuleOsEdition":  null,
    "deviceManagementApplicabilityRuleOsVersion":  null,
    "deviceManagementApplicabilityRuleDeviceMode":  null,
    "createdDateTime":  "\/Date(1598901896013)\/",
    "description":  "{\"windowsUpdateForBusinessConfigurationId \":\"f1d0eb97-93ed-4f86-aad4-1523942ee4fa\",\"windows10EndpointProtectionConfigurationId\":\"5752b198-0a05-41a7-8910-b3618caf27bd\"}",
    "displayName":  "M365: Windows 10 Default Policy",
    "version":  4,
    "taskManagerBlockEndTask":  false,
    "energySaverOnBatteryThresholdPercentage":  null,
    "energySaverPluggedInThresholdPercentage":  null,
    "powerLidCloseActionOnBattery":  "notConfigured",
    "powerLidCloseActionPluggedIn":  "notConfigured",
    "powerButtonActionOnBattery":  "notConfigured",
    "powerButtonActionPluggedIn":  "notConfigured",
    "powerSleepButtonActionOnBattery":  "notConfigured",
    "powerSleepButtonActionPluggedIn":  "notConfigured",
    "powerHybridSleepOnBattery":  "notConfigured",
    "powerHybridSleepPluggedIn":  "notConfigured",
    "windows10AppsForceUpdateSchedule":  null,
    "enableAutomaticRedeployment":  false,
    "microsoftAccountSignInAssistantSettings":  "notConfigured",
    "authenticationAllowSecondaryDevice":  false,
    "authenticationWebSignIn":  "notConfigured",
    "authenticationPreferredAzureADTenantDomainName":  null,
    "cryptographyAllowFipsAlgorithmPolicy":  false,
    "displayAppListWithGdiDPIScalingTurnedOn":  [

                                                ],
    "displayAppListWithGdiDPIScalingTurnedOff":  [

                                                 ],
    "enterpriseCloudPrintDiscoveryEndPoint":  null,
    "enterpriseCloudPrintOAuthAuthority":  null,
    "enterpriseCloudPrintOAuthClientIdentifier":  null,
    "enterpriseCloudPrintResourceIdentifier":  null,
    "enterpriseCloudPrintDiscoveryMaxLimit":  null,
    "enterpriseCloudPrintMopriaDiscoveryResourceIdentifier":  null,
    "experienceDoNotSyncBrowserSettings":  "notConfigured",
    "messagingBlockSync":  false,
    "messagingBlockMMS":  false,
    "messagingBlockRichCommunicationServices":  false,
    "printerNames":  [

                     ],
    "printerDefaultName":  null,
    "printerBlockAddition":  false,
    "searchBlockDiacritics":  false,
    "searchDisableAutoLanguageDetection":  false,
    "searchDisableIndexingEncryptedItems":  false,
    "searchEnableRemoteQueries":  false,
    "searchDisableUseLocation":  false,
    "searchDisableLocation":  false,
    "searchDisableIndexerBackoff":  false,
    "searchDisableIndexingRemovableDrive":  false,
    "searchEnableAutomaticIndexSizeManangement":  false,
    "searchBlockWebResults":  false,
    "findMyFiles":  "notConfigured",
    "securityBlockAzureADJoinedDevicesAutoEncryption":  false,
    "diagnosticsDataSubmissionMode":  "userDefined",
    "oneDriveDisableFileSync":  false,
    "systemTelemetryProxyServer":  null,
    "edgeTelemetryForMicrosoft365Analytics":  "notConfigured",
    "inkWorkspaceAccess":  "notConfigured",
    "inkWorkspaceAccessState":  "notConfigured",
    "inkWorkspaceBlockSuggestedApps":  false,
    "smartScreenEnableAppInstallControl":  false,
    "smartScreenAppInstallControl":  "notConfigured",
    "personalizationDesktopImageUrl":  null,
    "personalizationLockScreenImageUrl":  null,
    "bluetoothAllowedServices":  [

                                 ],
    "bluetoothBlockAdvertising":  false,
    "bluetoothBlockPromptedProximalConnections":  false,
    "bluetoothBlockDiscoverableMode":  false,
    "bluetoothBlockPrePairing":  false,
    "edgeBlockAutofill":  false,
    "edgeBlocked":  false,
    "edgeCookiePolicy":  "userDefined",
    "edgeBlockDeveloperTools":  false,
    "edgeBlockSendingDoNotTrackHeader":  false,
    "edgeBlockExtensions":  false,
    "edgeBlockInPrivateBrowsing":  false,
    "edgeBlockJavaScript":  false,
    "edgeBlockPasswordManager":  false,
    "edgeBlockAddressBarDropdown":  false,
    "edgeBlockCompatibilityList":  false,
    "edgeClearBrowsingDataOnExit":  false,
    "edgeAllowStartPagesModification":  false,
    "edgeDisableFirstRunPage":  false,
    "edgeBlockLiveTileDataCollection":  false,
    "edgeSyncFavoritesWithInternetExplorer":  false,
    "edgeFavoritesListLocation":  null,
    "edgeBlockEditFavorites":  false,
    "edgeNewTabPageURL":  null,
    "edgeHomeButtonConfiguration":  null,
    "edgeHomeButtonConfigurationEnabled":  false,
    "edgeOpensWith":  "notConfigured",
    "edgeBlockSideloadingExtensions":  false,
    "edgeRequiredExtensionPackageFamilyNames":  [

                                                ],
    "edgeBlockPrinting":  false,
    "edgeFavoritesBarVisibility":  "notConfigured",
    "edgeBlockSavingHistory":  false,
    "edgeBlockFullScreenMode":  false,
    "edgeBlockWebContentOnNewTabPage":  false,
    "edgeBlockTabPreloading":  false,
    "edgeBlockPrelaunch":  false,
    "edgeShowMessageWhenOpeningInternetExplorerSites":  "notConfigured",
    "edgePreventCertificateErrorOverride":  false,
    "edgeKioskModeRestriction":  "notConfigured",
    "edgeKioskResetAfterIdleTimeInMinutes":  null,
    "cellularBlockDataWhenRoaming":  false,
    "cellularBlockVpn":  false,
    "cellularBlockVpnWhenRoaming":  false,
    "cellularData":  "allowed",
    "defenderRequireRealTimeMonitoring":  true,
    "defenderRequireBehaviorMonitoring":  false,
    "defenderRequireNetworkInspectionSystem":  false,
    "defenderScanDownloads":  false,
    "defenderScheduleScanEnableLowCpuPriority":  false,
    "defenderDisableCatchupQuickScan":  false,
    "defenderDisableCatchupFullScan":  false,
    "defenderScanScriptsLoadedInInternetExplorer":  false,
    "defenderBlockEndUserAccess":  false,
    "defenderSignatureUpdateIntervalInHours":  null,
    "defenderMonitorFileActivity":  "userDefined",
    "defenderDaysBeforeDeletingQuarantinedMalware":  null,
    "defenderScanMaxCpu":  null,
    "defenderScanArchiveFiles":  false,
    "defenderScanIncomingMail":  false,
    "defenderScanRemovableDrivesDuringFullScan":  false,
    "defenderScanMappedNetworkDrivesDuringFullScan":  false,
    "defenderScanNetworkFiles":  false,
    "defenderRequireCloudProtection":  true,
    "defenderCloudBlockLevel":  "notConfigured",
    "defenderCloudExtendedTimeout":  null,
    "defenderCloudExtendedTimeoutInSeconds":  null,
    "defenderPromptForSampleSubmission":  "promptBeforeSendingPersonalData",
    "defenderScheduledQuickScanTime":  null,
    "defenderScanType":  "userDefined",
    "defenderSystemScanSchedule":  "userDefined",
    "defenderScheduledScanTime":  null,
    "defenderPotentiallyUnwantedAppAction":  null,
    "defenderPotentiallyUnwantedAppActionSetting":  "userDefined",
    "defenderSubmitSamplesConsentType":  "sendSafeSamplesAutomatically",
    "defenderBlockOnAccessProtection":  false,
    "defenderDetectedMalwareActions":  null,
    "defenderFileExtensionsToExclude":  [

                                        ],
    "defenderFilesAndFoldersToExclude":  [

                                         ],
    "defenderProcessesToExclude":  [

                                   ],
    "lockScreenAllowTimeoutConfiguration":  false,
    "lockScreenBlockActionCenterNotifications":  false,
    "lockScreenBlockCortana":  false,
    "lockScreenBlockToastNotifications":  false,
    "lockScreenTimeoutInSeconds":  null,
    "lockScreenActivateAppsWithVoice":  "notConfigured",
    "passwordBlockSimple":  false,
    "passwordExpirationDays":  null,
    "passwordMinimumLength":  null,
    "passwordMinutesOfInactivityBeforeScreenTimeout":  5,
    "passwordMinimumCharacterSetCount":  4,
    "passwordPreviousPasswordBlockCount":  null,
    "passwordRequired":  false,
    "passwordRequireWhenResumeFromIdleState":  false,
    "passwordRequiredType":  "alphanumeric",
    "passwordSignInFailureCountBeforeFactoryReset":  null,
    "passwordMinimumAgeInDays":  null,
    "privacyAdvertisingId":  "notConfigured",
    "privacyAutoAcceptPairingAndConsentPrompts":  false,
    "privacyDisableLaunchExperience":  false,
    "privacyBlockInputPersonalization":  false,
    "privacyBlockPublishUserActivities":  false,
    "privacyBlockActivityFeed":  false,
    "activateAppsWithVoice":  "notConfigured",
    "startBlockUnpinningAppsFromTaskbar":  false,
    "startMenuAppListVisibility":  "userDefined",
    "startMenuHideChangeAccountSettings":  false,
    "startMenuHideFrequentlyUsedApps":  false,
    "startMenuHideHibernate":  false,
    "startMenuHideLock":  false,
    "startMenuHidePowerButton":  false,
    "startMenuHideRecentJumpLists":  false,
    "startMenuHideRecentlyAddedApps":  false,
    "startMenuHideRestartOptions":  false,
    "startMenuHideShutDown":  false,
    "startMenuHideSignOut":  false,
    "startMenuHideSleep":  false,
    "startMenuHideSwitchAccount":  false,
    "startMenuHideUserTile":  false,
    "startMenuLayoutEdgeAssetsXml":  null,
    "startMenuLayoutXml":  null,
    "startMenuMode":  "userDefined",
    "startMenuPinnedFolderDocuments":  "notConfigured",
    "startMenuPinnedFolderDownloads":  "notConfigured",
    "startMenuPinnedFolderFileExplorer":  "notConfigured",
    "startMenuPinnedFolderHomeGroup":  "notConfigured",
    "startMenuPinnedFolderMusic":  "notConfigured",
    "startMenuPinnedFolderNetwork":  "notConfigured",
    "startMenuPinnedFolderPersonalFolder":  "notConfigured",
    "startMenuPinnedFolderPictures":  "notConfigured",
    "startMenuPinnedFolderSettings":  "notConfigured",
    "startMenuPinnedFolderVideos":  "notConfigured",
    "settingsBlockSettingsApp":  false,
    "settingsBlockSystemPage":  false,
    "settingsBlockDevicesPage":  false,
    "settingsBlockNetworkInternetPage":  false,
    "settingsBlockPersonalizationPage":  false,
    "settingsBlockAccountsPage":  false,
    "settingsBlockTimeLanguagePage":  false,
    "settingsBlockEaseOfAccessPage":  false,
    "settingsBlockPrivacyPage":  false,
    "settingsBlockUpdateSecurityPage":  false,
    "settingsBlockAppsPage":  false,
    "settingsBlockGamingPage":  false,
    "windowsSpotlightBlockConsumerSpecificFeatures":  false,
    "windowsSpotlightBlocked":  true,
    "windowsSpotlightBlockOnActionCenter":  false,
    "windowsSpotlightBlockTailoredExperiences":  false,
    "windowsSpotlightBlockThirdPartyNotifications":  false,
    "windowsSpotlightBlockWelcomeExperience":  false,
    "windowsSpotlightBlockWindowsTips":  false,
    "windowsSpotlightConfigureOnLockScreen":  "notConfigured",
    "networkProxyApplySettingsDeviceWide":  false,
    "networkProxyDisableAutoDetect":  false,
    "networkProxyAutomaticConfigurationUrl":  null,
    "networkProxyServer":  null,
    "accountsBlockAddingNonMicrosoftAccountEmail":  false,
    "antiTheftModeBlocked":  false,
    "bluetoothBlocked":  false,
    "cameraBlocked":  false,
    "connectedDevicesServiceBlocked":  false,
    "certificatesBlockManualRootCertificateInstallation":  false,
    "copyPasteBlocked":  false,
    "cortanaBlocked":  false,
    "deviceManagementBlockFactoryResetOnMobile":  false,
    "deviceManagementBlockManualUnenroll":  false,
    "safeSearchFilter":  "userDefined",
    "edgeBlockPopups":  false,
    "edgeBlockSearchSuggestions":  false,
    "edgeBlockSearchEngineCustomization":  false,
    "edgeBlockSendingIntranetTrafficToInternetExplorer":  false,
    "edgeSendIntranetTrafficToInternetExplorer":  false,
    "edgeRequireSmartScreen":  true,
    "edgeEnterpriseModeSiteListLocation":  null,
    "edgeFirstRunUrl":  null,
    "edgeSearchEngine":  null,
    "edgeHomepageUrls":  [

                         ],
    "edgeBlockAccessToAboutFlags":  false,
    "smartScreenBlockPromptOverride":  false,
    "smartScreenBlockPromptOverrideForFiles":  false,
    "webRtcBlockLocalhostIpAddress":  false,
    "internetSharingBlocked":  false,
    "settingsBlockAddProvisioningPackage":  false,
    "settingsBlockRemoveProvisioningPackage":  false,
    "settingsBlockChangeSystemTime":  false,
    "settingsBlockEditDeviceName":  false,
    "settingsBlockChangeRegion":  false,
    "settingsBlockChangeLanguage":  false,
    "settingsBlockChangePowerSleep":  false,
    "locationServicesBlocked":  false,
    "microsoftAccountBlocked":  false,
    "microsoftAccountBlockSettingsSync":  false,
    "nfcBlocked":  false,
    "resetProtectionModeBlocked":  false,
    "screenCaptureBlocked":  false,
    "storageBlockRemovableStorage":  false,
    "storageRequireMobileDeviceEncryption":  false,
    "usbBlocked":  false,
    "voiceRecordingBlocked":  false,
    "wiFiBlockAutomaticConnectHotspots":  false,
    "wiFiBlocked":  false,
    "wiFiBlockManualConfiguration":  false,
    "wiFiScanInterval":  null,
    "wirelessDisplayBlockProjectionToThisDevice":  false,
    "wirelessDisplayBlockUserInputFromReceiver":  false,
    "wirelessDisplayRequirePinForPairing":  false,
    "windowsStoreBlocked":  false,
    "appsAllowTrustedAppsSideloading":  "notConfigured",
    "windowsStoreBlockAutoUpdate":  false,
    "developerUnlockSetting":  "notConfigured",
    "sharedUserAppDataAllowed":  false,
    "appsBlockWindowsStoreOriginatedApps":  false,
    "windowsStoreEnablePrivateStoreOnly":  false,
    "storageRestrictAppDataToSystemVolume":  false,
    "storageRestrictAppInstallToSystemVolume":  false,
    "gameDvrBlocked":  false,
    "experienceBlockDeviceDiscovery":  false,
    "experienceBlockErrorDialogWhenNoSIM":  false,
    "experienceBlockTaskSwitcher":  false,
    "logonBlockFastUserSwitching":  false,
    "tenantLockdownRequireNetworkDuringOutOfBoxExperience":  false,
    "appManagementMSIAllowUserControlOverInstall":  false,
    "appManagementMSIAlwaysInstallWithElevatedPrivileges":  false,
    "dataProtectionBlockDirectMemoryAccess":  false,
    "appManagementPackageFamilyNamesToLaunchAfterLogOn":  [

                                                          ],
    "uninstallBuiltInApps":  false,
    "configureTimeZone":  null,
    "deviceConfigurationId":  "79a2d463-1e56-4b5f-85f4-bee330ad9282",
    "deviceConfigurationODataType":  "microsoft.graph.windows10GeneralConfiguration",
    "windows10GeneralConfigurationReferenceUrl":  "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations/79a2d463-1e56-4b5f-85f4-bee330ad9282"
}

"@


    $requestBodyObject = $jsonFile | ConvertFrom-Json
    $requestBodyObject.displayName = $displayName

    $requestBody = $requestBodyObject | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version | ConvertTo-Json
    
     try {
            $id = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceConfigurations" -ErrorAction Stop | Select id
            Write-Host "Successfully Created Device Configuration Profile $displayName" -ForegroundColor Green

          } catch {

             Write-Host "$deviceConfigurationDisplayName - Failed to restore Device Configuration" -ForegroundColor Magenta
             Write-Error $_ -ErrorAction Continue
          }

    $assignToAll = Read-Host "Would you like to assign the profile to all licensed usesr? Y/N"
    $assignToAll = ($assignToAll).ToUpper()

    if ($assignToAll -eq 'Y'){

    
       $assignementUrl = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($id.id)/assignments"
       $assignementRequestBodyJson = '{
                                    "@odata.type": "#microsoft.graph.deviceConfigurationAssignment",
                                    "target":{"@odata.type": "#microsoft.graph.allLicensedUsersAssignmentTarget"}
                                 }'

        try {
               $null = Invoke-MSGraphRequest -HttpMethod POST -Content $assignementRequestBodyJson -Url $assignementUrl -ErrorAction Stop
               Write-Host "Device Configuration Profile '$displayName' is successfully created and assigned to all licensed users" -ForegroundColor Green

             } catch {

               Write-Host "Failed to configure assignment(s)" -ForegroundColor Magenta
               Write-Error $_ -ErrorAction Continue

             }

        } else { 

          Write-Host "Profile '$displayName' is created but not assigned" -ForegroundColor Yellow
     }
}

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

function New-RTSEndPointprotectionPolicy {

    [CmdletBinding()]

    $displayName = "RTS: Endpoint Protection policy for Windows 10 devices"
    $jsonFile = @"
{
    "@odata.type":  "#microsoft.graph.windows10EndpointProtectionConfiguration",
    "id":  "249436ec-e6ac-46ee-85c8-3da89abc0f39",
    "lastModifiedDateTime":  "\/Date(1632511200831)\/",
    "roleScopeTagIds":  [
                            "0"
                        ],
    "supportsScopeTags":  true,
    "deviceManagementApplicabilityRuleOsEdition":  null,
    "deviceManagementApplicabilityRuleOsVersion":  null,
    "deviceManagementApplicabilityRuleDeviceMode":  null,
    "createdDateTime":  "\/Date(1632511200831)\/",
    "description":  null,
    "displayName":  "RTS: Endpoint Protection policy for Windows 10 devices",
    "version":  1,
    "dmaGuardDeviceEnumerationPolicy":  "deviceDefault",
    "userRightsAccessCredentialManagerAsTrustedCaller":  null,
    "userRightsAllowAccessFromNetwork":  null,
    "userRightsBlockAccessFromNetwork":  null,
    "userRightsActAsPartOfTheOperatingSystem":  null,
    "userRightsLocalLogOn":  null,
    "userRightsDenyLocalLogOn":  null,
    "userRightsBackupData":  null,
    "userRightsChangeSystemTime":  null,
    "userRightsCreateGlobalObjects":  null,
    "userRightsCreatePageFile":  null,
    "userRightsCreatePermanentSharedObjects":  null,
    "userRightsCreateSymbolicLinks":  null,
    "userRightsCreateToken":  null,
    "userRightsDebugPrograms":  null,
    "userRightsRemoteDesktopServicesLogOn":  null,
    "userRightsDelegation":  null,
    "userRightsGenerateSecurityAudits":  null,
    "userRightsImpersonateClient":  null,
    "userRightsIncreaseSchedulingPriority":  null,
    "userRightsLoadUnloadDrivers":  null,
    "userRightsLockMemory":  null,
    "userRightsManageAuditingAndSecurityLogs":  null,
    "userRightsManageVolumes":  null,
    "userRightsModifyFirmwareEnvironment":  null,
    "userRightsModifyObjectLabels":  null,
    "userRightsProfileSingleProcess":  null,
    "userRightsRemoteShutdown":  null,
    "userRightsRestoreData":  null,
    "userRightsTakeOwnership":  null,
    "xboxServicesEnableXboxGameSaveTask":  false,
    "xboxServicesAccessoryManagementServiceStartupMode":  "manual",
    "xboxServicesLiveAuthManagerServiceStartupMode":  "manual",
    "xboxServicesLiveGameSaveServiceStartupMode":  "manual",
    "xboxServicesLiveNetworkingServiceStartupMode":  "manual",
    "localSecurityOptionsBlockMicrosoftAccounts":  false,
    "localSecurityOptionsBlockRemoteLogonWithBlankPassword":  false,
    "localSecurityOptionsDisableAdministratorAccount":  false,
    "localSecurityOptionsAdministratorAccountName":  null,
    "localSecurityOptionsDisableGuestAccount":  false,
    "localSecurityOptionsGuestAccountName":  null,
    "localSecurityOptionsAllowUndockWithoutHavingToLogon":  false,
    "localSecurityOptionsBlockUsersInstallingPrinterDrivers":  false,
    "localSecurityOptionsBlockRemoteOpticalDriveAccess":  false,
    "localSecurityOptionsFormatAndEjectOfRemovableMediaAllowedUser":  "notConfigured",
    "localSecurityOptionsMachineInactivityLimit":  null,
    "localSecurityOptionsMachineInactivityLimitInMinutes":  null,
    "localSecurityOptionsDoNotRequireCtrlAltDel":  false,
    "localSecurityOptionsHideLastSignedInUser":  false,
    "localSecurityOptionsHideUsernameAtSignIn":  false,
    "localSecurityOptionsLogOnMessageTitle":  null,
    "localSecurityOptionsLogOnMessageText":  null,
    "localSecurityOptionsAllowPKU2UAuthenticationRequests":  false,
    "localSecurityOptionsAllowRemoteCallsToSecurityAccountsManagerHelperBool":  false,
    "localSecurityOptionsAllowRemoteCallsToSecurityAccountsManager":  null,
    "localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedClients":  "none",
    "localSecurityOptionsMinimumSessionSecurityForNtlmSspBasedServers":  "none",
    "lanManagerAuthenticationLevel":  "lmAndNltm",
    "lanManagerWorkstationDisableInsecureGuestLogons":  false,
    "localSecurityOptionsClearVirtualMemoryPageFile":  false,
    "localSecurityOptionsAllowSystemToBeShutDownWithoutHavingToLogOn":  false,
    "localSecurityOptionsAllowUIAccessApplicationElevation":  false,
    "localSecurityOptionsVirtualizeFileAndRegistryWriteFailuresToPerUserLocations":  false,
    "localSecurityOptionsOnlyElevateSignedExecutables":  false,
    "localSecurityOptionsAdministratorElevationPromptBehavior":  "notConfigured",
    "localSecurityOptionsStandardUserElevationPromptBehavior":  "notConfigured",
    "localSecurityOptionsSwitchToSecureDesktopWhenPromptingForElevation":  false,
    "localSecurityOptionsDetectApplicationInstallationsAndPromptForElevation":  false,
    "localSecurityOptionsAllowUIAccessApplicationsForSecureLocations":  false,
    "localSecurityOptionsUseAdminApprovalMode":  false,
    "localSecurityOptionsUseAdminApprovalModeForAdministrators":  false,
    "localSecurityOptionsInformationShownOnLockScreen":  "notConfigured",
    "localSecurityOptionsInformationDisplayedOnLockScreen":  "notConfigured",
    "localSecurityOptionsDisableClientDigitallySignCommunicationsIfServerAgrees":  false,
    "localSecurityOptionsClientDigitallySignCommunicationsAlways":  false,
    "localSecurityOptionsClientSendUnencryptedPasswordToThirdPartySMBServers":  false,
    "localSecurityOptionsDisableServerDigitallySignCommunicationsAlways":  false,
    "localSecurityOptionsDisableServerDigitallySignCommunicationsIfClientAgrees":  false,
    "localSecurityOptionsRestrictAnonymousAccessToNamedPipesAndShares":  false,
    "localSecurityOptionsDoNotAllowAnonymousEnumerationOfSAMAccounts":  false,
    "localSecurityOptionsAllowAnonymousEnumerationOfSAMAccountsAndShares":  false,
    "localSecurityOptionsDoNotStoreLANManagerHashValueOnNextPasswordChange":  false,
    "localSecurityOptionsSmartCardRemovalBehavior":  "lockWorkstation",
    "defenderSecurityCenterDisableAppBrowserUI":  null,
    "defenderSecurityCenterDisableFamilyUI":  null,
    "defenderSecurityCenterDisableHealthUI":  null,
    "defenderSecurityCenterDisableNetworkUI":  null,
    "defenderSecurityCenterDisableVirusUI":  null,
    "defenderSecurityCenterDisableAccountUI":  null,
    "defenderSecurityCenterDisableClearTpmUI":  null,
    "defenderSecurityCenterDisableHardwareUI":  null,
    "defenderSecurityCenterDisableNotificationAreaUI":  null,
    "defenderSecurityCenterDisableRansomwareUI":  null,
    "defenderSecurityCenterDisableSecureBootUI":  null,
    "defenderSecurityCenterDisableTroubleshootingUI":  null,
    "defenderSecurityCenterDisableVulnerableTpmFirmwareUpdateUI":  null,
    "defenderSecurityCenterOrganizationDisplayName":  null,
    "defenderSecurityCenterHelpEmail":  null,
    "defenderSecurityCenterHelpPhone":  null,
    "defenderSecurityCenterHelpURL":  null,
    "defenderSecurityCenterNotificationsFromApp":  "notConfigured",
    "defenderSecurityCenterITContactDisplay":  "notConfigured",
    "windowsDefenderTamperProtection":  "notConfigured",
    "firewallBlockStatefulFTP":  null,
    "firewallIdleTimeoutForSecurityAssociationInSeconds":  null,
    "firewallPreSharedKeyEncodingMethod":  "deviceDefault",
    "firewallIPSecExemptionsNone":  false,
    "firewallIPSecExemptionsAllowNeighborDiscovery":  false,
    "firewallIPSecExemptionsAllowICMP":  false,
    "firewallIPSecExemptionsAllowRouterDiscovery":  false,
    "firewallIPSecExemptionsAllowDHCP":  false,
    "firewallCertificateRevocationListCheckMethod":  "deviceDefault",
    "firewallMergeKeyingModuleSettings":  null,
    "firewallPacketQueueingMethod":  "deviceDefault",
    "firewallProfileDomain":  null,
    "firewallProfilePublic":  null,
    "firewallProfilePrivate":  null,
    "defenderAdobeReaderLaunchChildProcess":  "notConfigured",
    "defenderAttackSurfaceReductionExcludedPaths":  [

                                                    ],
    "defenderOfficeAppsOtherProcessInjectionType":  "userDefined",
    "defenderOfficeAppsOtherProcessInjection":  "userDefined",
    "defenderOfficeCommunicationAppsLaunchChildProcess":  "notConfigured",
    "defenderOfficeAppsExecutableContentCreationOrLaunchType":  "block",
    "defenderOfficeAppsExecutableContentCreationOrLaunch":  "enable",
    "defenderOfficeAppsLaunchChildProcessType":  "block",
    "defenderOfficeAppsLaunchChildProcess":  "enable",
    "defenderOfficeMacroCodeAllowWin32ImportsType":  "userDefined",
    "defenderOfficeMacroCodeAllowWin32Imports":  "userDefined",
    "defenderScriptObfuscatedMacroCodeType":  "userDefined",
    "defenderScriptObfuscatedMacroCode":  "userDefined",
    "defenderScriptDownloadedPayloadExecutionType":  "block",
    "defenderScriptDownloadedPayloadExecution":  "enable",
    "defenderPreventCredentialStealingType":  "notConfigured",
    "defenderProcessCreationType":  "userDefined",
    "defenderProcessCreation":  "userDefined",
    "defenderUntrustedUSBProcessType":  "userDefined",
    "defenderUntrustedUSBProcess":  "userDefined",
    "defenderUntrustedExecutableType":  "userDefined",
    "defenderUntrustedExecutable":  "userDefined",
    "defenderEmailContentExecutionType":  "block",
    "defenderEmailContentExecution":  "enable",
    "defenderAdvancedRansomewareProtectionType":  "auditMode",
    "defenderGuardMyFoldersType":  "enable",
    "defenderGuardedFoldersAllowedAppPaths":  [

                                              ],
    "defenderAdditionalGuardedFolders":  [

                                         ],
    "defenderNetworkProtectionType":  "enable",
    "defenderExploitProtectionXml":  null,
    "defenderExploitProtectionXmlFileName":  null,
    "defenderSecurityCenterBlockExploitProtectionOverride":  false,
    "defenderBlockPersistenceThroughWmiType":  "userDefined",
    "appLockerApplicationControl":  "notConfigured",
    "deviceGuardLocalSystemAuthorityCredentialGuardSettings":  "notConfigured",
    "deviceGuardEnableVirtualizationBasedSecurity":  false,
    "deviceGuardEnableSecureBootWithDMA":  false,
    "deviceGuardSecureBootWithDMA":  "notConfigured",
    "deviceGuardLaunchSystemGuard":  "notConfigured",
    "smartScreenEnableInShell":  false,
    "smartScreenBlockOverrideForFiles":  false,
    "applicationGuardEnabled":  false,
    "applicationGuardEnabledOptions":  "notConfigured",
    "applicationGuardBlockFileTransfer":  "notConfigured",
    "applicationGuardBlockNonEnterpriseContent":  false,
    "applicationGuardAllowPersistence":  false,
    "applicationGuardForceAuditing":  false,
    "applicationGuardBlockClipboardSharing":  "notConfigured",
    "applicationGuardAllowPrintToPDF":  false,
    "applicationGuardAllowPrintToXPS":  false,
    "applicationGuardAllowPrintToLocalPrinters":  false,
    "applicationGuardAllowPrintToNetworkPrinters":  false,
    "applicationGuardAllowVirtualGPU":  false,
    "applicationGuardAllowFileSaveOnHost":  false,
    "applicationGuardAllowCameraMicrophoneRedirection":  null,
    "applicationGuardCertificateThumbprints":  [

                                               ],
    "bitLockerAllowStandardUserEncryption":  true,
    "bitLockerDisableWarningForOtherDiskEncryption":  true,
    "bitLockerEnableStorageCardEncryptionOnMobile":  false,
    "bitLockerEncryptDevice":  true,
    "bitLockerRecoveryPasswordRotation":  "notConfigured",
    "defenderDisableScanArchiveFiles":  null,
    "defenderAllowScanArchiveFiles":  null,
    "defenderDisableBehaviorMonitoring":  null,
    "defenderAllowBehaviorMonitoring":  null,
    "defenderDisableCloudProtection":  null,
    "defenderAllowCloudProtection":  null,
    "defenderEnableScanIncomingMail":  null,
    "defenderEnableScanMappedNetworkDrivesDuringFullScan":  null,
    "defenderDisableScanRemovableDrivesDuringFullScan":  null,
    "defenderAllowScanRemovableDrivesDuringFullScan":  null,
    "defenderDisableScanDownloads":  null,
    "defenderAllowScanDownloads":  null,
    "defenderDisableIntrusionPreventionSystem":  null,
    "defenderAllowIntrusionPreventionSystem":  null,
    "defenderDisableOnAccessProtection":  null,
    "defenderAllowOnAccessProtection":  null,
    "defenderDisableRealTimeMonitoring":  null,
    "defenderAllowRealTimeMonitoring":  null,
    "defenderDisableScanNetworkFiles":  null,
    "defenderAllowScanNetworkFiles":  null,
    "defenderDisableScanScriptsLoadedInInternetExplorer":  null,
    "defenderAllowScanScriptsLoadedInInternetExplorer":  null,
    "defenderBlockEndUserAccess":  null,
    "defenderAllowEndUserAccess":  null,
    "defenderScanMaxCpuPercentage":  null,
    "defenderCheckForSignaturesBeforeRunningScan":  null,
    "defenderCloudBlockLevel":  null,
    "defenderCloudExtendedTimeoutInSeconds":  null,
    "defenderDaysBeforeDeletingQuarantinedMalware":  null,
    "defenderDisableCatchupFullScan":  null,
    "defenderDisableCatchupQuickScan":  null,
    "defenderEnableLowCpuPriority":  null,
    "defenderFileExtensionsToExclude":  [

                                        ],
    "defenderFilesAndFoldersToExclude":  [

                                         ],
    "defenderProcessesToExclude":  [

                                   ],
    "defenderPotentiallyUnwantedAppAction":  null,
    "defenderScanDirection":  null,
    "defenderScanType":  null,
    "defenderScheduledQuickScanTime":  null,
    "defenderScheduledScanDay":  null,
    "defenderScheduledScanTime":  null,
    "defenderSignatureUpdateIntervalInHours":  null,
    "defenderSubmitSamplesConsentType":  null,
    "defenderDetectedMalwareActions":  null,
    "firewallRules":  [

                      ],
    "bitLockerSystemDrivePolicy":  {
                                       "encryptionMethod":  null,
                                       "startupAuthenticationRequired":  true,
                                       "startupAuthenticationBlockWithoutTpmChip":  false,
                                       "startupAuthenticationTpmUsage":  "allowed",
                                       "startupAuthenticationTpmPinUsage":  "allowed",
                                       "startupAuthenticationTpmKeyUsage":  "allowed",
                                       "startupAuthenticationTpmPinAndKeyUsage":  "allowed",
                                       "minimumPinLength":  null,
                                       "prebootRecoveryEnableMessageAndUrl":  false,
                                       "prebootRecoveryMessage":  null,
                                       "prebootRecoveryUrl":  null,
                                       "recoveryOptions":  {
                                                               "blockDataRecoveryAgent":  false,
                                                               "recoveryPasswordUsage":  "allowed",
                                                               "recoveryKeyUsage":  "allowed",
                                                               "hideRecoveryOptions":  false,
                                                               "enableRecoveryInformationSaveToStore":  false,
                                                               "recoveryInformationToStore":  "passwordOnly",
                                                               "enableBitLockerAfterRecoveryInformationToStore":  true
                                                           }
                                   },
    "bitLockerFixedDrivePolicy":  {
                                      "encryptionMethod":  null,
                                      "requireEncryptionForWriteAccess":  false,
                                      "recoveryOptions":  {
                                                              "blockDataRecoveryAgent":  false,
                                                              "recoveryPasswordUsage":  "allowed",
                                                              "recoveryKeyUsage":  "allowed",
                                                              "hideRecoveryOptions":  false,
                                                              "enableRecoveryInformationSaveToStore":  false,
                                                              "recoveryInformationToStore":  "passwordAndKey",
                                                              "enableBitLockerAfterRecoveryInformationToStore":  false
                                                          }
                                  },
    "bitLockerRemovableDrivePolicy":  {
                                          "encryptionMethod":  null,
                                          "requireEncryptionForWriteAccess":  false,
                                          "blockCrossOrganizationWriteAccess":  false
                                      },
    "deviceConfigurationId":  "249436ec-e6ac-46ee-85c8-3da89abc0f39",
    "deviceConfigurationODataType":  "microsoft.graph.windows10EndpointProtectionConfiguration",
    "windows10EndpointProtectionConfigurationReferenceUrl":  "https://graph.microsoft.com/Beta/deviceManagement/deviceConfigurations/249436ec-e6ac-46ee-85c8-3da89abc0f39"
}
"@


    $requestBodyObject = $jsonFile | ConvertFrom-Json
    $requestBodyObject.displayName = $displayName

    $requestBody = $requestBodyObject | Select-Object -Property * -ExcludeProperty id, createdDateTime, lastModifiedDateTime, version | ConvertTo-Json
    
     try {
            $id = Invoke-MSGraphRequest -HttpMethod POST -Content $requestBody.toString() -Url "deviceManagement/deviceConfigurations" -ErrorAction Stop | Select id
            Write-Host "Successfully Created Device Configuration Profile $displayName" -ForegroundColor Green

          } catch {

             Write-Host "$deviceConfigurationDisplayName - Failed to restore Device Configuration" -ForegroundColor Magenta
             Write-Error $_ -ErrorAction Continue
          }

    $assignToAll = Read-Host "Would you like to assign the profile to all licensed usesr? Y/N"
    $assignToAll = ($assignToAll).ToUpper()

    if ($assignToAll -eq 'Y'){

    
       $assignementUrl = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations/$($id.id)/assignments"
       $assignementRequestBodyJson = '{
                                    "@odata.type": "#microsoft.graph.deviceConfigurationAssignment",
                                    "target":{"@odata.type": "#microsoft.graph.allLicensedUsersAssignmentTarget"}
                                 }'

        try {
               $null = Invoke-MSGraphRequest -HttpMethod POST -Content $assignementRequestBodyJson -Url $assignementUrl -ErrorAction Stop
               Write-Host "Device Configuration Profile '$displayName' is successfully created and assigned to all licensed users" -ForegroundColor Green

             } catch {

               Write-Host "Failed to configure assignment(s)" -ForegroundColor Magenta
               Write-Error $_ -ErrorAction Continue

             }

        } else { 

          Write-Host "Profile '$displayName' is created but not assigned" -ForegroundColor Yellow
     }
}

      

