param (
    # Install options
    [switch]
    $Powershell = $false, # Install powershell in the PE
    [switch]
    $Nuke = $false, # Wipe out the exisiting image and files
    [switch]
    $UpdateWinInstall = $false, # Wipe out the exisiting image and files
    [switch]
    $UpdateWinBoot = $false, # Wipe out the exisiting image and files
    [switch]
    $Sync = $false # Wipe out the exisiting image and files
)
$ErrorActionPreference = "Stop"
# Boot me out if I am not Admin
$current_principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$admin = $current_principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (!$admin) {
    Write-Error -Message "Cannot run this script without admin rights, exiting"
    Exit 5
}

# Our base directory for all things PE
$global:Config = Get-Content -Path $PSScriptRoot\config.json | ConvertFrom-Json
if (!($global:Config)){
    Write-Error -Message "Could not find global config at $($PSScriptRoot)\config.json"
    Exit 1
}

if ($Sync){
    . "$($global:Config.BaseDir)\src\setup\os.ps1"
    . "$($global:Config.BaseDir)\src\setup\pe.ps1"
    Write-Host "Starting PE Creation..." -ForegroundColor DarkGreen
    New-WinPE -Nuke $Nuke -Powershell $Powershell
    if ($UpdateWinInstall){
        Write-Host "Starting Win Install.wim Update..." -ForegroundColor DarkGreen
        Update-InstallWim
    }
    if ($UpdateWinBoot){
        Write-Host "Starting Win Boot.wim Update..." -ForegroundColor DarkGreen
        Update-BootWim
    }
}else{
    $job = Start-Job -Name "PE Creation" -ScriptBlock { 
        Param(
            [Parameter(Mandatory)]
            [PSCustomObject]$Config,
            [Parameter(Mandatory)]
            [bool]$Nuke,
            [Parameter(Mandatory)]
            [bool]$Powershell
        )
        . "$($Config.BaseDir)\src\setup\pe.ps1"
        New-WinPE -Nuke $Nuke -Powershell $Powershell
    } -Arg $Global:config, $Nuke, $Powershell
    Write-Host "Starting Job: $($job.Name)..." -ForegroundColor DarkGreen
    
    if ($UpdateWinInstall){
        $job = Start-Job -Name "Updating Install.Wim" -ScriptBlock { 
            Param(
                [Parameter(Mandatory)]
                [PSCustomObject]$config
            )
            . "$($global:Config.BaseDir)\src\setup\os.ps1"
            Update-InstallWim
        } -Arg $global:config
        Write-Host "Starting Job: $($job.name)..." -ForegroundColor DarkGreen
    }
    if ($UpdateWinBoot){
        $job = Start-Job -Name "Updating boot.Wim" -ScriptBlock { 
            Param(
                [Parameter(Mandatory)]
                [PSCustomObject]$config
            )
            . "$($global:Config.BaseDir)\src\setup\os.ps1"
            Update-BootWim
        } -Arg $global:config
        Write-Host "Starting Job: $($job.name)..." -ForegroundColor DarkGreen
    }
    # Wait until jobs finish
    Do{
        foreach($job in Get-Job){
            if ($job.State -eq "Completed" ){
                Receive-Job $job
                Write-Host "Job: $($job.name) completed sucessfully" -ForegroundColor Magenta
                Remove-Job $job
            }elseif ($job.State -ne "Running") {
                Receive-Job $job
                Write-Host "Job: $($job.name) WTF" -ForegroundColor Magenta
                Remove-Job $job
                # $job
                # Debug-Job $job
                # exit 1
            }else{}
        }  
    } while (Get-Job)

    # get-job | wait-job
    # get-job | remove-job
}