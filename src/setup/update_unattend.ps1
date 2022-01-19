enum BootIndex{
    StandardCore = 1
    StandardDesktop = 2
    DatacenterCore = 3
    DatacenterDesktop = 4
}

# Set the location of the windows install.wim and the boot index to choose from
function Set-WindowsInstallWim{
    Param(
        [parameter(Mandatory)]
        [String]$WimPath,
        [parameter(Mandatory)]
        [BootIndex]$Index,
        [parameter(Mandatory)]
        [String]$UnattendXmlPath
    )
    [xml]$xml = Get-Content -Path $UnattendXmlPath
    $xml.unattend.settings.Where({$_.pass -eq 'windowsPE'}).component.where({$_.name -eq 'Microsoft-Windows-Setup'}).ImageInstall.OSImage.InstallFrom.path = $WimPath
    $xml.unattend.settings.Where({$_.pass -eq 'windowsPE'}).component.where({$_.name -eq 'Microsoft-Windows-Setup'}).ImageInstall.OSImage.InstallFrom.Metadata.value = [String]([int]$Index)
    $xml.Save($UnattendXmlPath)
}

# Sets the hostname of the host
function Set-Hostname{
    Param(
        [parameter(Mandatory)]
        [String]$Hostname,
        [parameter(Mandatory)]
        [String]$UnattendXmlPath
    )
    [xml]$xml = Get-Content -Path $UnattendXmlPath
    $xml.unattend.settings.Where({$_.pass -eq 'specialize'}).component[0].ComputerName = $Hostname
    $xml.Save($UnattendXmlPath)
}