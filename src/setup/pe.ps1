
function New-WinPE{
    param (
        # Install options
        [Parameter(Mandatory)]
        [bool]$Powershell, # Install powershell in the PE
        [Parameter(Mandatory)]
        [bool]$Nuke # Wipe out the exisiting image and files
    )

    . "$($Config.BaseDir)\src\setup\pe.ps1"
    . "$($Config.BaseDir)\src\setup\helpers.ps1"

    $PE_File_Dir = "$($Config.BaseDir)\Staging\WinPE_amd64"
    $PE_ISO_Path = "$($Config.BaseDir)\Staging\WinPE_amd64.iso"
    $WinPE_OCs_Path = "$($Config.ADK_PATH)\Windows Preinstallation Environment\amd64\WinPE_OCs"
    $AssessAndDeployKitEnvPath = "$($Config.ADK_PATH)\Deployment Tools\DandISetEnv.bat"
    # Deployment and Imaging Tools Enviroment command line
    
    # Force Remove old artifacts
    if ($Nuke){
        # Ensure a flattened state
        Write-Host "Cleaning up old images..." -ForegroundColor Yellow
        Clear-WindowsCorruptMountPoint
        DISM /Cleanup-Wim /Quiet
        # Write-Host "Unmounting old images..." -ForegroundColor Yellow
        # DISM /Unmount-Image /MountDir:"$($PE_File_Dir)\mount" /Discard /Quiet
        # DISM /Unmount-Image /MountDir:"$($Config.BaseDir)\Staging\WinInstallMount" /Discard /Quiet
        
        if (Test-Path $PE_File_Dir ) { Remove-Item -Path $PE_File_Dir  -Recurse -ErrorAction Stop }
        if (Test-Path $PE_ISO_Path) { Remove-Item -Path $PE_ISO_Path -ErrorAction Stop }
        
        # Create the windowsPE files from the ADK
        Write-Host "Create the WinPE Folder and WIM to $($PE_File_Dir)..." -ForegroundColor Yellow
        cmd.exe /c """$($AssessAndDeployKitEnvPath)"" && copype amd64 $($PE_File_Dir)" | Out-Null
    }
    
    # Expand the boot.wim
    Write-Host "Expanding PE boot.wim from $($PE_File_Dir)\media\sources\boot.wim..." -ForegroundColor Yellow
    DISM /Mount-Image /imagefile:"$($PE_File_Dir)\media\sources\boot.wim" /Index:1 /MountDir:"$($PE_File_Dir)\mount" /Quiet
    
    Write-Host "Changing the efisys.bin to the one without the press any key..." -ForegroundColor Yellow
    Copy-Item -Path $PE_File_Dir\fwfiles\efisys.bin -Destination $PE_File_Dir\fwfiles\efisys.bin.bak
    Copy-Item -Path "$($Config.ADK_PATH)\Deployment Tools\amd64\Oscdimg\efisys_noprompt.bin" -Destination $PE_File_Dir\fwfiles\efisys.bin
    # WinPE-WMI > WinPE-NetFX > WinPE-Scripting before you install WinPE-PowerShell.
    # Mininmum required for powershell
    if ($Powershell) {
        Write-Host "Installing WMI to the WinPE..." -ForegroundColor Yellow
        Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:"$($WinPE_OCs_Path)\WinPE-WMI.cab" /Quiet
        Write-Host "Installing NetFX to the WinPE..." -ForegroundColor Yellow
        Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:"$($WinPE_OCs_Path)\WinPE-NetFX.cab" /Quiet
        Write-Host "Installing Scripting to the WinPE..." -ForegroundColor Yellow
        Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:"$($WinPE_OCs_Path)\WinPE-Scripting.cab" /Quiet
        Write-Host "Installing Powershell to the WinPE..." -ForegroundColor Yellow
        Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:"$($WinPE_OCs_Path)\WinPE-PowerShell.cab" /Quiet
        # Do we need language packs? Looks like I dont
        # Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:$base_package_dir"en-gb\WinPE-WMI_en-gb.cab"
        # Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:$base_package_dir"en-gb\WinPE-PowerShell_en-gb.cab"
        # Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:$base_package_dir"en-gb\WinPE-NetFX_en-gb.cab"
        # Dism /Add-Package /Image:"$($PE_File_Dir)\mount" /PackagePath:$base_package_dir"en-gb\WinPE-Scripting_en-gb.cab"
    }
    
    # This deletes the old winpe.jpg and replaces with a much improved image!
    Write-Host "Setting the WinPE background..." -ForegroundColor Yellow
    if (!(Test-Path -Path $Config.PE_BG_Path)){
        Invoke-WebRequest "https://static.wikia.nocookie.net/starwarsrebels/images/a/af/FulcrumReveal-FAtG.jpg/revision/latest?cb=20150303054212" `
            -outfile "$($PE_File_Dir)\mount\Windows\System32\winpe.jpg"
    }
    Set-WinPEImg -Path $Config.PE_BG_Path -Destination "$($PE_File_Dir)\mount\Windows\System32\winpe.jpg"
    
    # This deletes the old Startnet.cmd and replaces with our custom
    Write-Host "Setting the WinPE startnet.cmd..." -ForegroundColor Yellow
    Set-StartnetCmd -Path $($Config.PE_Startnet_Path) -Destination "$($PE_File_Dir)\mount\Windows\System32\startnet.cmd"
    
    # Unmount the wim
    Write-Host "Unmounting WinPE boot.wim..." -ForegroundColor Yellow
    DISM /Unmount-Image /MountDir:"$($PE_File_Dir)\mount" /Commit /Quiet
    
    # Create the ISO
    cmd.exe /c """$($AssessAndDeployKitEnvPath)"" && Makewinpemedia /iso /f $($PE_File_Dir) $($PE_ISO_Path) 2>NUL" | Out-Null
}