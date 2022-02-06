$IMAGE_SERVER = "BESTPCGARGUNNOCK"
$Port = 445
$creds = New-Object pscredential("bot", (ConvertTo-SecureString "iamabot" -AsPlainText -Force))
if (!(Test-NetConnection "$($IMAGE_SERVER)" -Port $Port)){
    throw "Cannot connect to $($IMAGE_SERVER) on Port $($Port)... TODO ALERTING HERE"
    exit 1
}
New-PSDrive -Name Z -Root "\\$($IMAGE_SERVER)\Deploy" -PSProvider FileSystem -Credential $creds -Scope Script | Out-Null
Copy-Item -Path Z:\Scripts\entry.ps1 -Destination "$($PSScriptRoot)\entry.ps1"
. "$($PSScriptRoot)\entry.ps1"

@{
    role = "DC"
} | ConvertTo-JSON | Out-File C:\ProgramData\PuppetLabs\facter\facts.d\facts.json -Encoding ascii