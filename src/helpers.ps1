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