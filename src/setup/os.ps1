
function Update-InstallWim{
    ## Inject Language to install.wim, Index two is Server Standard Desktop Experience
    Write-Host "Mounting install.wim..." -ForegroundColor Yellow
    DISM /Mount-Image /imagefile:"$($global:Config.BaseDir)\Public\Windows\2022\sources\install.wim" /Index:2 /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Quiet
    
    Write-Host "Attempting to install en-GB in the install.wim..." -ForegroundColor Yellow
    if (!(Test-Path -Path "$($global:Config.BaseDir)\Staging\WinInstallMount\Windows\en-GB")){
        Dism /Image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Add-Package /PackagePath="$($global:Config.BaseDir)\Staging\lang_packs\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_en-gb.cab" /Quiet
        DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb /Quiet
    }else{
        Write-Host "Skipping en-GB install as it is already in the image" -ForgroundColor Yellow
    }
    write-host "Copying SetupComplete.cmd and scripts to install.wim..." -ForgroundColor Yellow
    Copy-Item -Path "$($global:Config.BaseDir)\src\Artifacts\Scripts" -Destination "$($global:Config.BaseDir)\Staging\WinInstallMount\Windows\Setup\Scripts" -Recurse -Force
    write-host "Unmounting and saving changes to install.wim..." -ForgroundColor Yellow
    DISM /Unmount-Image /MountDir:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Commit /quiet
}

function Update-BootWim{

    . .\setup\helpers.ps1
    ## Inject Language Pack into The windows Install
    DISM /Mount-Image /imagefile:"$($global:Config.BaseDir)\Public\Windows\2022\sources\boot.wim" /Index:1 /MountDir:"$($global:Config.BaseDir)\Staging\WinBootMount"
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\lp.cab"
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup_en-gb.cab"
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup-Server_en-gb.cab"
    # DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb

    # This deletes the old winpe.jpg and replaces with a much improved image!
    Write-Host "Setting the WinPE background..." -ForegroundColor Yellow
    if (!(Test-Path -Path $Config.PE_BG_Path)){
        Invoke-WebRequest "https://static.wikia.nocookie.net/starwarsrebels/images/a/af/FulcrumReveal-FAtG.jpg/revision/latest?cb=20150303054212" `
            -outfile "$($global:Config.BaseDir)\Staging\WinBootMount\Windows\System32\setup.bmp"
    }
    Set-WinPEImg -Path $Config.PE_BG_Path -Destination "$($global:Config.BaseDir)\Staging\WinBootMount\Windows\System32\setup.bmp"
    DISM /Unmount-Image /MountDir:"$($global:Config.BaseDir)\Staging\WinBootMount" /Commit
}