function Set-WinPEImg{
    $jpg_location = "$($mount_dir)Windows\System32\winpe.jpg"
    try{
        Update-AclFullAccess -path $jpg_location
        Remove-Item -path $jpg_location
    }catch{
        write-host "winpe.jpg already removed" -ForegroundColor Green
    }
    $ahsoka_jpg = "https://static.wikia.nocookie.net/starwarsrebels/images/a/af/FulcrumReveal-FAtG.jpg/revision/latest?cb=20150303054212"
    Invoke-WebRequest $ahsoka_jpg -outfile $jpg_location
}

function Set-StartnetCmd{
    $startnetcmd = "$($mount_dir)Windows\System32\startnet.cmd"
    Update-AclFullAccess -path $startnetcmd
    Remove-Item -Path $startnetcmd

    Copy-Item -Path .\artifacts\startnet.cmd -destination $startnetcmd
    Add-Content -Path $startnetcmd -Value "`r`nnet use Z: \\$($IMAGE_SERVER)\ISO /user:$($IMAGE_SERVER_USER) $($IMAGE_SERVER_PASS)"
    Add-Content -Path $startnetcmd -Value "`r`nZ:\2022\setup.exe -unattend:`"Z:\2022\Unattend.xml`""

    # New-PSDrive -Name Z -Root "\\$($IMAGE_SERVER)\ISO" -PSProvider FileSystem -Credential $creds
}