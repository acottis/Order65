param (
    # Install options
    [switch]
    $Powershell = $false, # Install powershell in the PE
    [switch]
    $Nuke = $false, # Wipe out the exisiting image and files
    [switch]
    $UpdateWinInstall = $false, # Wipe out the exisiting image and files
    [switch]
    $UpdateWinBoot = $false, # Wipe out the exisiting image and files
    [switch]
    $DeployISO = $false # Wipe out the exisiting image and files
)

# Our base directory for all things PE
$global:Config = Get-Content -Path config.json | ConvertFrom-Json
# Load our functions
. .\setup\pe.ps1
. .\setup\update_unattend.ps1

# Update Unattend.xml
Write-Host "Updating Unattend.xml..." -ForegroundColor DarkGreen
Set-Hostname -Hostname "Coruscant" -UnattendXmlPath $PSScriptRoot\artifacts\Unattend.xml
Set-WindowsInstallWim -WimPath "Z:\Windows\2022\sources\install.wim" -Index StandardCore -UnattendXmlPath $PSScriptRoot\artifacts\Unattend.xml

# Create our PE
$job = Start-Job -Name "PE Creation" -ScriptBlock { 
    Param(
        [Parameter(Mandatory)]
        [String]$ScriptRoot,
        [Parameter(Mandatory)]
        [PSCustomObject]$config,
        [Parameter(Mandatory)]
        [String]$Nuke,
        [Parameter(Mandatory)]
        [PSCustomObject]$Powershell
    )
    . $ScriptRoot\setup\pe.ps1
    . $ScriptRoot\setup\helpers.ps1
    New-WinPE -Nuke $Nuke -Powershell $Powershell
} -Arg $PSScriptRoot, $global:config, $Nuke, $Powershell
Write-Host "Starting Job: $($job.name)..." -ForegroundColor DarkGreen

if ($UpdateWinInstall){
    $job = Start-Job -Name "Updating Install.Wim" -ScriptBlock { 
        Param(
            [Parameter(Mandatory)]
            [String]$ScriptRoot,
            [Parameter(Mandatory)]
            [PSCustomObject]$config
        )
        . $ScriptRoot\setup\os.ps1
        Update-InstallWim
    } -Arg $PSScriptRoot, $global:config
    Write-Host "Starting Job: $($job.name)..." -ForegroundColor DarkGreen
}else{
    Write-Host "Skipping Windows Image customization..." -ForegroundColor DarkGreen
}
if ($UpdateWinBoot){
    . .\setup\os.ps1
    Write-Host "Starting Windows Boot customization..." -ForegroundColor DarkGreen
    Start-Job -ScriptBlock {  Update-BootWim }
}else{
    Write-Host "Skipping Windows Boot customization..." -ForegroundColor DarkGreen
}


Get-Job | Wait-Job
Receive-Job $job
Get-Job | Remove-Job

exit 0

# Copy answer file to Network Image
Write-Host "Copying answer file to Image..." -ForegroundColor DarkGreen
try{
    Copy-Item -Path .\artifacts\Unattend.xml -Destination ..\Public\Windows\2022\Unattend.xml
}catch{
    exit 1
}