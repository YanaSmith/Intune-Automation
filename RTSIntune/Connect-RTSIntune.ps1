
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