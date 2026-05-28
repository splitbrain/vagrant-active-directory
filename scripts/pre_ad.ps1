$scripts = "C:\vagrant\scripts"

function Time-Step {
    param([string]$Label, [scriptblock]$Block)
    $start = Get-Date
    Write-Output "[$($start.ToString('HH:mm:ss'))] BEGIN $Label"
    & $Block
    $elapsed = (Get-Date) - $start
    Write-Output "[$((Get-Date).ToString('HH:mm:ss'))] END   $Label ($([math]::Round($elapsed.TotalSeconds, 1))s)"
}

Time-Step "disable_defender"     { & "$scripts\disable_defender.ps1" }
Time-Step "disable_wu"           { & "$scripts\disable_wu.ps1" }
Time-Step "disable_rdp_nla"      { & "$scripts\disable_rdp_nla.ps1" }
Time-Step "install_ad"           { & "$scripts\install_ad.ps1" }
