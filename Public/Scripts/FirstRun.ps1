# # Setup oemlogo.bmp
# $ahsoka_bmp = "https://styles.redditmedia.com/t5_2oczgo/styles/communityIcon_h3k5uf2rhpz41.png"
# Invoke-WebRequest $ahsoka_bmp -outfile "C:\Windows\System32\oemlogo.bmp"

# Helper function to check if software is installed
function Test-Install{
    Param(
        [Parameter(Mandatory)]
        [String]$DisplayName
    )
    if (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Where-Object Displayname -like $DisplayName){
        return $true
    }else{
        return $false
    }
}
# Install Puppet
if (!(Test-Install -DisplayName "Puppet Agent*")){
    # Map ISO Drive
    $IMAGE_SERVER = "BESTPCGARGUNNOCK"
    $Port = 445
    $creds = New-Object pscredential("bot", (ConvertTo-SecureString "iamabot" -AsPlainText -Force))
    if (!(Test-NetConnection "$($IMAGE_SERVER)" -Port $Port)){
        throw "Cannot connect to $($IMAGE_SERVER) on Port $($Port)... TODO ALERTING HERE"
        exit 1
    }
    Write-Host "Mapping \\$($IMAGE_SERVER)\Public to X" -ForegroundColor DarkGreen
    New-PSDrive -Name X -Root "\\$($IMAGE_SERVER)\Public" -PSProvider FileSystem -Credential $creds -Scope Script | Out-Null
    Write-Host "Copying puppet installer to C:\Windows\Temp" -ForegroundColor DarkGreen
    Copy-Item -Path X:\Windows\Software\puppet-agent-x64.msi -Destination C:\Windows\Temp
    Write-Host "Starting the Puppet Install..." -ForegroundColor DarkGreen
    Start-Process msiexec -ArgumentList "/qn","/norestart","/i C:\Windows\Temp\puppet-agent-x64.msi PUPPET_MASTER_SERVER=puppet" -NoNewWindow -Wait
    if (!(Test-Install -DisplayName "Puppet Agent*")) {
        throw "Puppet agent not found, cant contine..."
        exit 1
    }
}else{
    Write-Host "Puppet Already Installed, Exiting.." -ForegroundColor DarkGreen
    exit 0
}

