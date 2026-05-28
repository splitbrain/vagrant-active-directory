param
(
    [string]$hostName,
    [string]$domainName,
    [string]$domainNetbiosName,
    [string]$safeModePass
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

Time-Step "configure_ad" { & "$scripts\configure_ad.ps1" $domainName $domainNetbiosName $safeModePass }
Time-Step "certificate"  { & "$scripts\certificate.ps1" $hostName $domainName }
