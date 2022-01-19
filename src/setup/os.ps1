
function Update-InstallWim{

    ## Inject Language to install.wim, Index two is Server Standard Desktop Experience
    Write-Host "Mounting install.wim..." -ForegroundColor Yellow
    Mount-WindowsImage -ImagePath "$($global:Config.BaseDir)\Public\Windows\2022\sources\install.wim" `
        -Path "$($global:Config.BaseDir)\Staging\WinInstallMount" -Index 2 -ErrorAction Stop

    Write-Host "Attempting to install en-GB in the install.wim..." -ForegroundColor Yellow
    Write-Host "Setting the WinPE background..." -ForegroundColor Yellow
    if (!(Test-Path -Path "$($global:Config.BaseDir)\Staging\WinInstallMount\Windows\en-GB")){
       # Dism /Image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Add-Package /PackagePath="$($global:Config.BaseDir)\Staging\lang_packs\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_en-gb.cab" /Quiet
        Add-WindowsPackage -Path "$($global:Config.BaseDir)\Staging\WinInstallMount" `
            -PackagePath "$($global:Config.BaseDir)\Staging\lang_packs\LanguagesAndOptionalFeatures\Microsoft-Windows-Server-Language-Pack_x64_en-gb.cab"
        DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb /Quiet
    }else{
        Write-Host "Skipping en-GB install as it is already in the image" -ForgroundColor Yellow
    }
    write-host "Copying SetupComplete.cmd and scripts to install.wim..." -ForgroundColor Yellow
    Copy-Item -Path "$($global:Config.BaseDir)\src\Artifacts\Scripts" -Destination "$($global:Config.BaseDir)\Staging\WinInstallMount\Windows\Setup\Scripts" -Recurse -Force
    write-host "Unmounting and saving changes to install.wim..." -ForgroundColor Yellow
    Dismount-WindowsImage -Path "$($global:Config.BaseDir)\Staging\WinInstallMount" -Save -ErrorAction Stop
}

function Update-BootWim{

    . "$($global:Config.BaseDir)\src\setup\helpers.ps1"
    ## Inject Language Pack into The windows Install
    Mount-WindowsImage -ImagePath "$($Config.BaseDir)\Public\Windows\2022\sources\boot.wim" `
        -Path "$($Config.BaseDir)\Staging\WinBootMount" -Index 1 -ErrorAction Stop | Out-Null
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\lp.cab"
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup_en-gb.cab"
    # Dism /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /add-package /packagepath:"D:\ISO\lang_packs\Windows Preinstallation Environment\x64\WinPE_OCs\en-gb\WinPE-Setup-Server_en-gb.cab"
    # DISM /image:"$($global:Config.BaseDir)\Staging\WinInstallMount" /Set-AllIntl:en-gb

    # This deletes the old winpe.jpg and replaces with a much improved image!
    Write-Host "Setting the WinPE background..." -ForegroundColor Yellow
    if (!(Test-Path -Path $Config.PE_BG_Path)){
        Invoke-WebRequest "https://static.wikia.nocookie.net/starwarsrebels/images/a/af/FulcrumReveal-FAtG.jpg/revision/latest?cb=20150303054212" `
            -outfile "$($Config.BaseDir)\Staging\WinBootMount\Windows\System32\setup.bmp"
    }
    Set-WinPEImg -Path $Config.PE_BG_Path -Destination "$($Config.BaseDir)\Staging\WinBootMount\Windows\System32\setup.bmp"
    Dismount-WindowsImage -Path "$($Config.BaseDir)\Staging\WinBootMount" -Save -ErrorAction Stop | Out-Null
}