# Disable Defender real-time monitoring and exclude the AD/Vagrant hot paths.
# Removing the Windows-Defender feature on Server 2025 costs ~8 min of CBS work;
# this achieves nearly the same end-state in seconds. The kernel filter driver
# remains active (Tamper Protection blocks unloading it), so feature installs
# still pay a scan cost — but it's far less than the removal cost.
Set-MpPreference -DisableRealtimeMonitoring $true
Add-MpPreference -ExclusionPath "C:\Windows\NTDS", "C:\Windows\SYSVOL", "C:\vagrant", "C:\tmp"
