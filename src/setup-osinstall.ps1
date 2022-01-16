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