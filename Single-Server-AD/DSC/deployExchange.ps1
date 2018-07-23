configuration deployExchange
{
   param
   (
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,


        [string]$storageKey,
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
    $netbios=$DomainName.split(“.”)[0]
    Import-DscResource -ModuleName xActiveDirectory, StorageDsc, xNetworking, PSDesiredStateConfiguration, xPendingReboot,cChoco,xExchange
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainName}\$($Admincreds.UserName)", $Admincreds.Password)
    [System.Management.Automation.PSCredential ]$storageCredential = New-Object System.Management.Automation.PSCredential ("AZure\limjafile", $storageKey)

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
            InstallDir = "C:\ProgramData\chocolatey"
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

        xDisk ExchangeDataDisk {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        xPendingReboot PriorNext {
            Name = "PriorNext"
            DependsOn = "[xDisk]ExchangeDataDisk"
        }
        File ExchangeISODownload {
            DestinationPath = "C:\ExchangeInstall"
            Credential = $storageCredential
            Ensure = "Present"
            SourcePath = "\\limjafile.file.core.windows.net\software\ExchangeServer2016-x64-cu10.iso"
            Type = "File"
        }

        MountImage ExchangeISO {
            imagePath = "C:\ExchangeInstall\ExchangeServer2016-x64-cu10.iso"
            DriveLetter = "S"
        }

        WaitForVolume WaitForISO {
        DriveLetter      = 'S'
        RetryIntervalSec = $RetryIntervalSec
        RetryCount       = $RetryCount
        }

        #Checks if a reboot is needed before installing Exchange
        xPendingReboot BeforeExchangeInstall
        {
            Name      = "BeforeExchangeInstall"
            DependsOn  = '[File]ExchangeBinaries'
        }

        #Does the Exchange install. Verify directory with exchange binaries
        xExchInstall InstallExchange
        {
            Path       = "C:\Exch\Setup.exe"
            Arguments  = "/mode:Install /role:Mailbox /OrganizationName:""$netbios"" /Iacceptexchangeserverlicenseterms"
            Credential = $DomainCreds
            DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
        }

        #Sees if a reboot is required after installing Exchange
        xPendingReboot AfterExchangeInstall
        {
            Name      = "AfterExchangeInstall"
            DependsOn = '[xExchInstall]InstallExchange'
        }
    }
}