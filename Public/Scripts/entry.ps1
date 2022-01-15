Set-ExecutionPolicy Unrestricted

# Setup oemlogo.bmp
$ahsoka_bmp = "https://styles.redditmedia.com/t5_2oczgo/styles/communityIcon_h3k5uf2rhpz41.png"
Invoke-WebRequest $ahsoka_bmp -outfile "C:\Windows\System32\oemlogo.bmp"

# Map ISO Drive
$IMAGE_SERVER = "BESTPCGARGUNNOCK"
$creds = New-Object pscredential("bot", (ConvertTo-SecureString "iamabot" -AsPlainText -Force))
New-PSDrive -Name Z -Root "\\$($IMAGE_SERVER)\ISO\Software" -PSProvider FileSystem -Credential $creds
# Install Puppet
msiexec /qn /norestart /i Z:\puppet-agent-x64.msi PUPPET_MASTER_SERVER=puppet

if (!(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | `
    Where-Object Displayname -like "Puppet Agent*")){
    throw "Puppet agent not found, cant contine... TODO ALERTING HERE"
    exit 1
}