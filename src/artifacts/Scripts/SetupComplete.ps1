$IMAGE_SERVER = "BESTPCGARGUNNOCK"
$Port = 445
$creds = New-Object pscredential("bot", (ConvertTo-SecureString "iamabot" -AsPlainText -Force))
if (!(Test-NetConnection "$($IMAGE_SERVER)" -Port $Port)){
    throw "Cannot connect to $($IMAGE_SERVER) on Port $($Port)... TODO ALERTING HERE"
    exit 1
}
New-PSDrive -Name Z -Root "\\$($IMAGE_SERVER)\Public" -PSProvider FileSystem -Credential $creds -Scope Script | Out-Null
Copy-Item -Path Z:\Scripts\FirstRun.ps1 -Destination "$($PSScriptRoot)\FirstRun.ps1"
# Run the file
. "$($PSScriptRoot)\FirstRun.ps1"

@{
    role = "DC"
} | ConvertTo-JSON | Out-File C:\ProgramData\PuppetLabs\facter\facts.d\facts.json -Encoding ascii