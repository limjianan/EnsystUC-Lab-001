@{
    AllNodes = @(
        @{
            Nodename = 'localhost'
            PSDscAllowDomainUser = $true
        }
    )

    NonNodeData = @{

        UserData = @'
UserName,Password,Dept,Title
Alastair,P@ssw0rd,Project Services,Manager
Mark,P@ssw0rd,Managed Services,Manager
Song,P@ssw0rd,Presales,Manager
Steve,P@ssw0rd,Sales,Manager
James,P@ssw0rd,Presales,Specialist
Neil,P@ssw0rd,Sales,Specialist
Jian,P@ssw0rd,Project Services,Specialist
Ashwin,P@ssw0rd,Operations,Specialist
'@

        RootOUs = 'EnsystUC'
        ChildOUs = 'Users','Computers','Role Groups','Resource Group','Admin','Service Accounts','ExchangeRelated'
        TestObjCount = 5

    }
}
