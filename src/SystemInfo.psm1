function Get-SystemInfo {
    <#
    .SYNOPSIS
    Collects system information from the local Windows computer.

    .OUTPUTS
    PSCustomObject containing computer, operating-system, CPU, memory, disk,
    network, and uptime information.
    #>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param()

    $operatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
    $processors = @(Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop)
    $disks = @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop)
    $networkAddresses = @(
        Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop |
            Where-Object {
                $_.IPAddress -notlike '169.254.*' -and
                $_.IPAddress -ne '127.0.0.1'
            }
    )
    $uptime = (Get-Date) - [datetime]$operatingSystem.LastBootUpTime

    [pscustomobject]@{
        PSTypeName       = 'GladKhumalo.SystemInfo.Report'
        CollectedAt      = Get-Date
        ComputerName     = $env:COMPUTERNAME
        OperatingSystem  = [pscustomobject]@{
            Name    = $operatingSystem.Caption
            Version = $operatingSystem.Version
        }
        CPU              = @($processors.Name)
        Memory           = [pscustomobject]@{
            TotalGB = [math]::Round($operatingSystem.TotalVisibleMemorySize / 1MB, 2)
            FreeGB  = [math]::Round($operatingSystem.FreePhysicalMemory / 1MB, 2)
        }
        Disks            = @(
            $disks | ForEach-Object {
                [pscustomobject]@{
                    Drive   = $_.DeviceID
                    FreeGB  = [math]::Round($_.FreeSpace / 1GB, 2)
                    TotalGB = [math]::Round($_.Size / 1GB, 2)
                }
            }
        )
        NetworkAddresses = @(
            $networkAddresses | ForEach-Object {
                [pscustomobject]@{
                    Address       = $_.IPAddress
                    InterfaceName = $_.InterfaceAlias
                }
            }
        )
        Uptime           = [pscustomobject]@{
            Days  = $uptime.Days
            Hours = $uptime.Hours
        }
    }
}

function Export-SystemInfoReport {
    <#
    .SYNOPSIS
    Exports a system-information report as JSON.

    .PARAMETER InputObject
    Report returned by Get-SystemInfo.

    .PARAMETER Path
    Destination JSON file.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [psobject]$InputObject,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    process {
        $InputObject |
            ConvertTo-Json -Depth 5 |
            Set-Content -Path $Path -Encoding utf8 -ErrorAction Stop
    }
}

Export-ModuleMember -Function Get-SystemInfo, Export-SystemInfoReport
