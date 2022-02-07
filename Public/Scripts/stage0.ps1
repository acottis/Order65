. Z:\Scripts\UpdateUnattended.ps1
$serial = Get-CimInstance -ClassName Win32_BIOS | `
    Select-Object -Expand SerialNumber
$facts = Get-Content -Path "Z:\Configs\$($serial).json" | ConvertFrom-Json
# Update Unattend.xml
Copy-Item "Z:\Configs\Unattend.xml" .
$unattend = "Unattend.xml"
Write-Host "Updating Unattend.xml..." -ForegroundColor DarkGreen
Set-Hostname -Hostname $facts.hostname -UnattendXmlPath $unattend
Set-WindowsInstallWim -WimPath $facts.wim_path -Flavour $facts.flavour  -UnattendXmlPath $unattend