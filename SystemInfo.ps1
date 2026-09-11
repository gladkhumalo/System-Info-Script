<#
.SYNOPSIS
Displays system information for the local Windows computer.

.DESCRIPTION
Uses the SystemInfo module to collect CPU, memory, disk, operating-system,
network, and uptime information. The report can optionally be exported to JSON.

.PARAMETER ExportPath
Optional path where the JSON report will be saved.

.PARAMETER PassThru
Returns the structured report object to the pipeline.

.EXAMPLE
.\SystemInfo.ps1

.EXAMPLE
.\SystemInfo.ps1 -ExportPath .\SystemInfo.json

.EXAMPLE
$report = .\SystemInfo.ps1 -PassThru
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]
    [string]$ExportPath,

    [switch]$PassThru
)

$modulePath = Join-Path -Path $PSScriptRoot -ChildPath 'src/SystemInfo.psd1'
Import-Module -Name $modulePath -Force -ErrorAction Stop

try {
    $report = Get-SystemInfo
}
catch {
    Write-Error "Unable to collect system information: $($_.Exception.Message)"
    return
}

if (-not $PassThru) {
    Write-Host '===== SYSTEM INFORMATION =====' -ForegroundColor Cyan
    Write-Host "`nComputer Name: $($report.ComputerName)"
    Write-Host "OS: $($report.OperatingSystem.Name)"
    Write-Host "Version: $($report.OperatingSystem.Version)"
    Write-Host "`nCPU: $($report.CPU -join ', ')"
    Write-Host "Total RAM: $($report.Memory.TotalGB) GB"
    Write-Host "Free RAM: $($report.Memory.FreeGB) GB"

    Write-Host "`nDisk Information:"
    foreach ($disk in $report.Disks) {
        Write-Host "Drive $($disk.Drive): $($disk.FreeGB) GB free of $($disk.TotalGB) GB"
    }

    Write-Host "`nNetwork Information:"
    foreach ($address in $report.NetworkAddresses) {
        Write-Host "IP Address: $($address.Address) ($($address.InterfaceName))"
    }

    Write-Host "`nSystem Uptime: $($report.Uptime.Days) days, $($report.Uptime.Hours) hours"
}

if ($ExportPath) {
    try {
        $report | Export-SystemInfoReport -Path $ExportPath
        Write-Host "Report exported to: $ExportPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Unable to export the report to '$ExportPath': $($_.Exception.Message)"
        return
    }
}

if ($PassThru) {
    $report
}
else {
    Write-Host "`n===== END OF REPORT =====" -ForegroundColor Cyan
}
