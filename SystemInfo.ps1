<#
.SYNOPSIS
Collects system information from a Windows machine.

.DESCRIPTION
Retrieves CPU, RAM, disk, OS, network info, and uptime.
Optionally exports the collected report to a JSON file.

.PARAMETER ExportPath
Optional path where the JSON report will be saved.
#>

[CmdletBinding()]
param(
    [string]$ExportPath
)

Write-Host "===== SYSTEM INFORMATION =====" -ForegroundColor Cyan

# Computer Name
$ComputerName = $env:COMPUTERNAME
Write-Host "`nComputer Name: $ComputerName"

# Operating System
$OS = Get-CimInstance Win32_OperatingSystem
Write-Host "OS: $($OS.Caption)"
Write-Host "Version: $($OS.Version)"

# CPU Info
$CPU = Get-CimInstance Win32_Processor
Write-Host "`nCPU: $($CPU.Name -join ', ')"

# RAM Info
$TotalRAM = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
$FreeRAM = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)

Write-Host "Total RAM: $TotalRAM GB"
Write-Host "Free RAM: $FreeRAM GB"

# Disk Info
Write-Host "`nDisk Information:"
$Disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

foreach ($disk in $Disks) {
    $FreeSpace = [math]::Round($disk.FreeSpace / 1GB, 2)
    $TotalSpace = [math]::Round($disk.Size / 1GB, 2)

    Write-Host "Drive $($disk.DeviceID): $FreeSpace GB free of $TotalSpace GB"
}

# Network Info
Write-Host "`nNetwork Information:"
$IP = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "169.*" }

foreach ($ipaddr in $IP) {
    Write-Host "IP Address: $($ipaddr.IPAddress)"
}

# System Uptime
$Uptime = (Get-Date) - $OS.LastBootUpTime
Write-Host "`nSystem Uptime: $($Uptime.Days) days, $($Uptime.Hours) hours"

$Report = [pscustomobject]@{
    ComputerName    = $ComputerName
    OperatingSystem = [pscustomobject]@{
        Name    = $OS.Caption
        Version = $OS.Version
    }
    CPU             = @($CPU.Name)
    Memory          = [pscustomobject]@{
        TotalGB = $TotalRAM
        FreeGB  = $FreeRAM
    }
    Disks           = @($Disks | ForEach-Object {
        [pscustomobject]@{
            Drive   = $_.DeviceID
            FreeGB  = [math]::Round($_.FreeSpace / 1GB, 2)
            TotalGB = [math]::Round($_.Size / 1GB, 2)
        }
    })
    NetworkAddresses = @($IP | ForEach-Object {
        [pscustomobject]@{
            Address       = $_.IPAddress
            InterfaceName = $_.InterfaceAlias
        }
    })
    Uptime          = [pscustomobject]@{
        Days  = $Uptime.Days
        Hours = $Uptime.Hours
    }
}

if ($ExportPath) {
    $Report | ConvertTo-Json -Depth 4 | Set-Content -Path $ExportPath -Encoding utf8
    Write-Host "Report exported to: $ExportPath" -ForegroundColor Green
}

Write-Host "`n===== END OF REPORT =====" -ForegroundColor Cyan
