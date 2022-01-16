param (
    # Install options
    [switch]
    $Powershell = $false, # Install powershell in the PE
    [switch]
    $Nuke = $false, # Wipe out the exisiting image and files
    [switch]
    $UpdateWinInstall = $false # Wipe out the exisiting image and files
)

# Our base directory for all things PE
$global:Config = Get-Content -Path config.json | ConvertFrom-Json
# Load our functions
. .\setup_helpers.ps1
. .\setup_pe.ps1
# Create our PE
Write-Host "Starting PE Creation..." -ForegroundColor DarkGreen
New-WinPE -Nuke $Nuke -Powershell $Powershell

. .\setup_os.ps1
Write-Host "Starting Windows Image customization..." -ForegroundColor DarkGreen
Update-InstallWim -UpdateWinInstall $UpdateWinInstall

# Copy answer file to Network Image
Write-Host "Copying answer file to Image..." -ForegroundColor DarkGreen
Copy-Item -Path .\artifacts\Unattend.xml -Destination ..\Public\Windows\2022\Unattend.xml