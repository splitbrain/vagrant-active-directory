param
(
    [string]$domainName
)

$scripts = "C:\vagrant\scripts"

function Time-Step {
    param([string]$Label, [scriptblock]$Block)
    $start = Get-Date
    Write-Output "[$($start.ToString('HH:mm:ss'))] BEGIN $Label"
    & $Block
    $elapsed = (Get-Date) - $start
    Write-Output "[$((Get-Date).ToString('HH:mm:ss'))] END   $Label ($([math]::Round($elapsed.TotalSeconds, 1))s)"
}

Time-Step "install_adexplorer" { & "$scripts\install_adexplorer.ps1" }
Time-Step "password_policy"    { & "$scripts\password_policy.ps1" $domainName }
Time-Step "importusers"        { & "$scripts\importusers.ps1" $domainName }
