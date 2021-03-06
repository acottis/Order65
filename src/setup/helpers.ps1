# Updates an ACL
function Update-AclFullAccess{
    param (
        [Parameter(Mandatory)]
        [String]
        $path
    )

    # Exit if path is not valid
    if (!(test-path $path)) { throw "$($path) cannot be found." }

    $acl = Get-Acl -Path $path
    # Set properties
    $identity = "BUILTIN\Administrators"
    $fileSystemRights = "FullControl"
    $type = "Allow"
    # Create new rule
    $fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
    $fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
    # Apply new rule
    $acl.SetAccessRule($fileSystemAccessRule)
    Set-Acl -Path $path -AclObject $acl

}

# Sets the PE image by changing the permissions of the original and deleting it
function Set-WinPEImg{
    param (
        [Parameter(mandatory)]
        [String]
        $Path,
        [Parameter(mandatory)]
        [String]
        $Destination
    )
    try{
        Update-AclFullAccess -path $Destination
        Remove-Item -path $Destination
    }catch{
        write-host "winpe.jpg already removed" -ForegroundColor DarkYellow
    }
    Copy-Item -Path $Path -Destination $Destination
}

function Set-StartnetCmd{

    param(
        [Parameter(mandatory)]
        [String]
        $Path,
        [Parameter(mandatory)]
        [String]
        $Destination
    )

    Update-AclFullAccess -path $Destination
    Remove-Item -Path $Destination

    Copy-Item -Path $Config.PE_Startnet_Path -Destination $Destination
    Add-Content -Path $Destination -Value "`r`n"
    Add-Content -Path $Destination -Value "net use Z: \\$($Config.Image_Server)\Public /user:$($Config.Image_Server_User) $($Config.Image_Server_Pass)"
    Add-Content -Path $Destination -Value "copy Z:\Scripts\Stage0.ps1 ."
    Add-Content -Path $Destination -Value "Powershell -ExecutionPolicy bypass -File `"%~dp0stage0.ps1`""
    Add-Content -Path $Destination -Value "Z:\Windows\2022\setup.exe -unattend:`"Unattend.xml`""
}