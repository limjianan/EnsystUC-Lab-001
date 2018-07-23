configuration deployExchange
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

    Import-DscResource -ModuleName xActiveDirectory, xStorage, xNetworking, PSDesiredStateConfiguration, xPendingReboot,cChoco,xExchange
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    $Interface=Get-NetAdapter|Where-Object Name -Like "Ethernet*"|Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

       #Installs Required Components for Exchange (note: there is 1 planned automatic reboot)
        WindowsFeature ASHTTP
        {
            Ensure = 'Present'
            Name = 'AS-HTTP-Activation'
        }
        WindowsFeature DesktopExp
        {
            Ensure = 'Present'
            Name = 'Desktop-Experience'
        }
         WindowsFeature NetFW45
        {
            Ensure = 'Present'
            Name = 'NET-Framework-45-Features'
        }
           WindowsFeature RPCProxy
        {
            Ensure = 'Present'
            Name = 'RPC-over-HTTP-proxy'
        }
            WindowsFeature RSATClus
        {
            Ensure = 'Present'
            Name = 'RSAT-Clustering'
        }
            WindowsFeature RSATClusCmd
        {
            Ensure = 'Present'
            Name = 'RSAT-Clustering-CmdInterface'
        }
            WindowsFeature RSATClusMgmt
        {
            Ensure = 'Present'
            Name = 'RSAT-Clustering-Mgmt'
        }
           WindowsFeature RSATClusPS
        {
            Ensure = 'Present'
            Name = 'RSAT-Clustering-PowerShell'
        }
           WindowsFeature WebConsole
        {
            Ensure = 'Present'
            Name = 'Web-Mgmt-Console'
        }
            WindowsFeature WAS
        {
            Ensure = 'Present'
            Name = 'WAS-Process-Model'
        }
            WindowsFeature WebAsp
        {
            Ensure = 'Present'
            Name = 'Web-Asp-Net45'
        }
           WindowsFeature WBA
        {
            Ensure = 'Present'
            Name = 'Web-Basic-Auth'
        }
           WindowsFeature WCA
        {
            Ensure = 'Present'
            Name = 'Web-Client-Auth'
        }
          WindowsFeature WDA
        {
            Ensure = 'Present'
            Name = 'Web-Digest-Auth'
        }
          WindowsFeature WDB
        {
            Ensure = 'Present'
            Name = 'Web-Dir-Browsing'
        }
           WindowsFeature WDC
        {
            Ensure = 'Present'
            Name = 'Web-Dyn-Compression'
        }
           WindowsFeature WebHttp
        {
            Ensure = 'Present'
            Name = 'Web-Http-Errors'
        }
           WindowsFeature WebHttpLog
        {
            Ensure = 'Present'
            Name = 'Web-Http-Logging'
        }
           WindowsFeature WebHttpRed
        {
            Ensure = 'Present'
            Name = 'Web-Http-Redirect'
        }
          WindowsFeature WebHttpTrac
        {
            Ensure = 'Present'
            Name = 'Web-Http-Tracing'
        }
          WindowsFeature WebISAPI
        {
            Ensure = 'Present'
            Name = 'Web-ISAPI-Ext'
        }
          WindowsFeature WebISAPIFilt
        {
            Ensure = 'Present'
            Name = 'Web-ISAPI-Filter'
        }
            WindowsFeature WebLgcyMgmt
        {
            Ensure = 'Present'
            Name = 'Web-Lgcy-Mgmt-Console'
        }
            WindowsFeature WebMetaDB
        {
            Ensure = 'Present'
            Name = 'Web-Metabase'
        }
            WindowsFeature WebMgmtSvc
        {
            Ensure = 'Present'
            Name = 'Web-Mgmt-Service'
        }
           WindowsFeature WebNet45
        {
            Ensure = 'Present'
            Name = 'Web-Net-Ext45'
        }
            WindowsFeature WebReq
        {
            Ensure = 'Present'
            Name = 'Web-Request-Monitor'
        }
             WindowsFeature WebSrv
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }
              WindowsFeature WebStat
        {
            Ensure = 'Present'
            Name = 'Web-Stat-Compression'
        }
               WindowsFeature WebStatCont
        {
            Ensure = 'Present'
            Name = 'Web-Static-Content'
        }
               WindowsFeature WebWindAuth
        {
            Ensure = 'Present'
            Name = 'Web-Windows-Auth'
        }
              WindowsFeature WebWMI
        {
            Ensure = 'Present'
            Name = 'Web-WMI'
        }
              WindowsFeature WebIF
        {
            Ensure = 'Present'
            Name = 'Windows-Identity-Foundation'
        }
              WindowsFeature RSATADDS
        {
            Ensure = 'Present'
            Name = 'RSAT-ADDS'
        }
	cChocoInstaller installChoco
        { 
            InstallDir = "C:\choco"
        }

        cChocoFeature allowGlobalConfirmation {
            FeatureName = "allowGlobalConfirmation"
            Ensure = 'Present'
	    DependsOn = "[cChocoInstaller]installChoco"
        }

        cChocoPackageInstaller ucma4 {
            FeatureName = "ucma4"
            Ensure = 'Present'
	    DependsOn = "[cChocoInstaller]installChoco"
        }

        cChocoPackageInstaller vcredist2013 {
            FeatureName = "vcredist2013"
            Ensure = 'Present'
	    DependsOn = "[cChocoInstaller]installChoco"
        }


        xWaitforDisk Disk2
        {
            DiskNumber = 2
            RetryIntervalSec =$RetryIntervalSec
            RetryCount = $RetryCount
        }

        xDisk ADDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }
<#
        cDiskNoRestart ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
        }
#>
  
        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCreds
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
	        DependsOn = "[xDisk]ADDataDisk"
        }
		        xWaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            DomainUserCredential = $DomainCreds
            RetryCount = $RetryCount
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[xADDomain]FirstDS"
        }


        ### OUs ###
        $DomainRoot = "DC=$($DomainName -replace '\.',',DC=')"
        $DependsOn_OU = @()

        ForEach ($RootOU in $ConfigurationData.NonNodeData.RootOUs) {

            xADOrganizationalUnit "OU_$RootOU"
            {
                Name = $RootOU
                Path = $DomainRoot
                ProtectedFromAccidentalDeletion = $true
                Description = "OU for $RootOU"
                Credential = $DomainCred
                Ensure = 'Present'
                DependsOn = '[xADRecycleBin]RecycleBin'
            }

            ForEach ($ChildOU in $ConfigurationData.NonNodeData.ChildOUs) {

                xADOrganizationalUnit "OU_$($RootOU)_$ChildOU"
                {
                    Name = $ChildOU
                    Path = "OU=$RootOU,$DomainRoot"
                    ProtectedFromAccidentalDeletion = $true
                    Credential = $DomainCred
                    Ensure = 'Present'
                    DependsOn = "[xADOrganizationalUnit]OU_$RootOU"
                }

                $DependsOn_OU += "[xADOrganizationalUnit]OU_$($RootOU)_$ChildOU"
            }

        }


        ### USERS ###
        $DependsOn_User = @()
        $Users = $ConfigurationData.NonNodeData.UserData | ConvertFrom-CSV
        ForEach ($User in $Users) {

            xADUser "NewADUser_$($User.UserName)"
            {
                DomainName = $DomainName
                Ensure = 'Present'
                UserName = $User.UserName
                JobTitle = $User.Title
                Path = "OU=Users,OU=$($User.Dept),$DomainRoot"
                Enabled = $true
                Password = New-Object -TypeName PSCredential -ArgumentList 'JustPassword', (ConvertTo-SecureString -String $User.Password -AsPlainText -Force)
                DependsOn = $DependsOn_OU
            }
            $DependsOn_User += "[xADUser]NewADUser_$($User.UserName)"
        }

        1..$ConfigurationData.NonNodeData.TestObjCount | ForEach-Object {

            xADUser "NewADUser_$_"
            {
                DomainName = $DomainName
                Ensure = 'Present'
                UserName = "TestUser$_"
                Enabled = $false  # Must specify $false if disabled and no password
                DependsOn = '[xADRecycleBin]RecycleBin'
            }

        }


        ### GROUPS ###
        ForEach ($RootOU in $ConfigurationData.NonNodeData.RootOUs) {
            xADGroup "NewADGroup_$RootOU"
            {
                GroupName = "G_$RootOU"
                GroupScope = 'Global'
                Description = "Global group for $RootOU"
                Category = 'Security'
                Members = ($Users | Where-Object {$_.Dept -eq $RootOU}).UserName
                Path = "OU=Groups,OU=$RootOU,$DomainRoot"
                Ensure = 'Present'
                DependsOn = $DependsOn_User
            }
        }

        1..$ConfigurationData.NonNodeData.TestObjCount | ForEach-Object {

            xADGroup "NewADGroup_$_"
            {
                GroupName = "TestGroup$_"
                GroupScope = 'Global'
                Category = 'Security'
                Members = "TestUser$_"
                Ensure = 'Present'
                DependsOn = "[xADUser]NewADUser_$_"
            }

        }
   }
}