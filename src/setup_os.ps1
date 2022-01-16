
function Update-InstallWim{
    Param(
        [bool]
        $UpdateWindowsInstall = $false # Wipe out the exisiting image and files
    )
    ## Inject Language to install.wim, Index two is Server Standard Desktop Experience
    DISM /Mount-Image /imagefile:"$($global:Config.BaseDir)\Public\Windows\2022\sources\install.wim" /Index:2 /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount"
    Dism /Image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Add-Package /PackagePath="$($global:Config.BaseDir)\Staging\lang_packs\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_en-gb.cab"
    DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb
    DISM /Unmount-Image /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Commit
}

function Update-BootWim{
    ## Inject Language Pack into The windows Install
    DISM /Mount-Image /imagefile:"D:\ISO\2022\sources\boot.wim" /Index:2 /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount"
    Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\lp.cab"
    Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup_en-gb.cab"
    Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup-Server_en-gb.cab"
    DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb
    DISM /Unmount-Image /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Commit
}