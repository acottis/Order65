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
# Create our PE
Write-Host "Starting PE Creation..." -ForegroundColor DarkGreen
New-WinPE -Nuke $Nuke -Powershell $Powershell

if ($UpdateWinInstall){
    . .\setup\os.ps1
    Write-Host "Starting Windows Image customization..." -ForegroundColor DarkGreen
    Update-InstallWim
}else{
    Write-Host "Skipping Windows Image customization..." -ForegroundColor DarkGreen
}
if ($UpdateWinBoot){
    . .\setup\os.ps1
    Write-Host "Starting Windows Boot customization..." -ForegroundColor DarkGreen
    Update-BootWim
}else{
    Write-Host "Skipping Windows Boot customization..." -ForegroundColor DarkGreen
}


# Copy answer file to Network Image
Write-Host "Copying answer file to Image..." -ForegroundColor DarkGreen
try{
    Copy-Item -Path .\artifacts\Unattend.xml -Destination ..\Public\Windows\2022\Unattend.xml
    exit 0
}catch{
    exit 1
}