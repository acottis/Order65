param (
    # Install options
    [switch]
    $Powershell = $false, # Install powershell in the PE
    [switch]
    $Nuke = $false # Wipe out the exisiting image and files
)

# Load our functions
. .\helpers.ps1
. .\setup_pe.ps1
# Create our PE
Write-Host "Starting PE Creation..." -ForegroundColor Blue
New-WinPE -Nuke $Nuke -Powershell $Powershell

# Copy answer file to Network Image
Write-Host "Copying answer file to Image..." -ForegroundColor Blue
Copy-Item -Path .\artifacts\Unattend.xml -Destination ..\Public\Windows\2022\Unattend.xml