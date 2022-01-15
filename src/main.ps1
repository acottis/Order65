param (
    # Install options
    [switch]
    $Powershell = $false, # Install powershell in the PE
    [switch]
    $Nuke = $false # Wipe out the exisiting image and files
)

# Our base directory for all things PE
$base_dir = "D:\ISO\WinPE_amd64\"
$mount_dir = "$($base_dir)mount\"
$iso = "D:\ISO\WinPE_amd64.iso"
# Deployment and Imaging Tools Enviroment command line
$env = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat" 

# Config vars
$global:IMAGE_SERVER = "BESTPCGARGUNNOCK"
$global:IMAGE_SERVER_USER = "bot"
$global:IMAGE_SERVER_PASS = "iamabot"


if ($NUKE){
    # Ensure a flattened state
    Dism /cleanup-wim
    Dism /Unmount-Image /MountDir:$mount_dir /Discard
    
    if (Test-Path $base_dir) { Remove-Item -Path $base_dir -Recurse -ErrorAction Stop }
    if (Test-Path $iso) { Remove-Item -Path $iso -ErrorAction Stop }
    
    # Create the windowsPE files from the ADK
    cmd.exe /c """$env"" && copype amd64 $($base_dir)"

}

# Expand the boot.wim
DISM /mount-image /imagefile:"D:\ISO\WinPE_amd64\media\sources\boot.wim" /Index:1 /MountDir:$mount_dir

# WinPE-WMI > WinPE-NetFX > WinPE-Scripting before you install WinPE-PowerShell.
# Mininmum required for powershell
if ($POWERSHELL) {
    $base_package_dir = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\"
    Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"WinPE-WMI.cab"
    Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"WinPE-NetFX.cab"
    Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"WinPE-Scripting.cab"
    Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"WinPE-PowerShell.cab"
    # Do we need language packs? Looks like I dont
    # Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"en-gb\WinPE-WMI_en-gb.cab"
    # Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"en-gb\WinPE-PowerShell_en-gb.cab"
    # Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"en-gb\WinPE-NetFX_en-gb.cab"
    # Dism /Add-Package /Image:$mount_dir /PackagePath:$base_package_dir"en-gb\WinPE-Scripting_en-gb.cab"
}

# Loads some helper functions
. .\helpers.ps1
. .\config.ps1
# This deletes the old winpe.jpg and replaces with a much improved image!
Set-WinPEImg

# This deletes the old Startnet.cmd and replaces with our custom
Set-StartnetCmd

# Unmount the wim
DISM /Unmount-Image /MountDir:$mount_dir /Commit

# Create the ISO
cmd.exe /c """$env"" && Makewinpemedia /iso /f $($base_dir) $($iso)"

exit 0

# Boot vm
# TODO


################################
##Prepare Windows image

$mount_dir = "D:\Temp\MountWindows"

## Inject Language 
DISM /Mount-Image /imagefile:"D:\ISO\2022\sources\install.wim" /Index:1 /MountDir:$mount_dir
Dism /Image:$mount_dir /Add-Package /PackagePath="D:\ISO\lang_packs\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_en-gb.cab"
DISM /image:$mount_dir /Set-AllIntl:en-gb
DISM /Unmount-Image /MountDir:$mount_dir /Commit

## Inject Language Pack into The windows Install
DISM /Mount-Image /imagefile:"D:\ISO\2022\sources\boot.wim" /Index:2 /MountDir:$mount_dir
Dism /image:$mount_dir /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\lp.cab"
Dism /image:$mount_dir /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup_en-gb.cab"
Dism /image:$mount_dir /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup-Server_en-gb.cab"
DISM /image:$mount_dir /Set-AllIntl:en-gb
DISM /Unmount-Image /MountDir:$mount_dir /Commit