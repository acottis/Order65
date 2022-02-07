Param(
    [Parameter(Mandatory)]    
    [String]$Hostname,
    [ValidateSet(1,2)]
    [Int]$Generation = 2,
    [Int]$Memory = 2,
    [Int]$Cores = 2,
    [Int]$VhdSize = 20,
    [String]$OS = "Windows2022",
    [String]$Flavour = "StandardDesktop",
    [String]$Role = "DC",
    [String]$NetSwitch = "External",
    [switch]$Force
)
$ErrorActionPreference = "Stop"

# Boot me out if I am not Admin
$current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$admin = $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$admin) {
    Write-Error -Message "Cannot run this script without admin rights, exiting"
    Exit 5
}

if ($Force){
    Stop-VM -name $Hostname -force -ErrorAction SilentlyContinue
    Remove-VM -Name $Hostname -force -ErrorAction SilentlyContinue
    Remove-Item -Path "$($CONFIG.HyperVRoot)\$($Hostname)\" -Recurse -force -ErrorAction SilentlyContinue
}

# $switches = Get-VMSwitch | -Expand Select-Object Name

$CONFIG = Get-Content -Path $PSScriptRoot\config.json | ConvertFrom-Json
if (!($CONFIG)){
    Write-Error -Message "Could not find global config at $($PSScriptRoot)\config.json"
    Exit 1
}

$vm = New-VM -Name $hostname `
    -Generation $generation `
    -NewVHDPath "$($CONFIG.HyperVRoot)\$($hostname)\system.vhdx" `
    -NewVHDSizeBytes "$($VhdSize)GB" `
    -MemoryStartupBytes "$($memory)GB" `
    -SwitchName $NetSwitch `
    -Path "$($CONFIG.HyperVRoot)"
Set-VMProcessor -VM $vm -Count $Cores
$dvd = Add-VMDvdDrive -Path D:\DEPLOY\Staging\WinPE_amd64.iso -vm $vm -Passthru
Set-VMFirmware -vm $vm -FirstBootDevice $dvd

# Get the serial number
$serial = Get-CimInstance -Namespace root/virtualization/v2 -ClassName Msvm_VirtualSystemSettingData | Where-Object VirtualSystemIdentifier -eq $vm.id | Select-Object -Last 1 | Select-Object -Expand BIOSSerialNumber

# Create JSON from the API facts
$json = @{
    hostname = $hostname
    os = $os
    role = $role
    flavour = $flavour
    wim_path = "Z:\Windows\2022\sources\install.wim"
} | ConvertTo-Json -EnumsAsStrings

# Write the JSON to file
$json | Out-File -FilePath "$($CONFIG.BaseDir)\Public\Configs\$($serial).json"

Start-VM -Name $vm.name

# Output back to rust web server
Write-Output $vm | Select-Object Name, Id, CPUUsage, MemoryAssigned, `
    Uptime, Status, State, ProcessorCount | `
    ConvertTo-Json -EnumsAsStrings -Compress
