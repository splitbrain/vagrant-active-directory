param
(
    [string]$domainName = "example.local",
    [string]$domainNetbiosName = "EXAMPLE",
    [string]$safeModePass = "Admin123#"
)

Install-ADDSForest `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode WinThreshold `
-DomainName "$domainName" `
-DomainNetbiosName "$domainNetbiosName" `
-ForestMode WinThreshold `
-InstallDns `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion `
-SysvolPath "C:\Windows\SYSVOL" `
-SafeModeAdministratorPassword (ConvertTo-SecureString "$safeModePass" -AsPlainText -Force) `
-Force
