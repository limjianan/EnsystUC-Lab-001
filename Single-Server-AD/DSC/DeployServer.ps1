configuration deployServer
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,


        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
    $netbios=$DomainName.split(“.”)[0]
    $storagePass=ConvertTo-SecureString -String $storageKey -AsPlainText -Force
    Import-DscResource -ModuleName xActiveDirectory, PSDesiredStateConfiguration, xPendingReboot, cChoco, 
    Import-DSCResource -Module xSystemSecurity
    [System.Management.Automation.PSCredential]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

         WindowsFeature RSAT-ADDS
        {
            Ensure = 'Present'
            Name = 'RSAT-ADDS'
        }
 
        xIEEsc EnableIEEscAdmin
        {
            IsEnabled = $false
            UserRole  = "Administrators"
        }
 
	cChocoInstaller installChoco
        {
            InstallDir = "C:\ProgramData\chocolatey"
        }

        cChocoPackageInstaller notepadplusplus {
            Name = "notepadplusplus"
            Ensure = 'Present'
	    DependsOn = "[cChocoInstaller]installChoco"
        }

    }
}