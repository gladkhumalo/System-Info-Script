BeforeAll {
    $modulePath = Join-Path -Path $PSScriptRoot -ChildPath '../src/SystemInfo.psd1'
    Import-Module -Name $modulePath -Force
}

Describe 'Get-SystemInfo' {
    BeforeEach {
        InModuleScope SystemInfo {
            Mock Get-CimInstance {
                if ($ClassName -eq 'Win32_OperatingSystem') {
                    return [pscustomobject]@{
                        Caption               = 'Microsoft Windows Test'
                        Version               = '10.0.99999'
                        TotalVisibleMemorySize = 16777216
                        FreePhysicalMemory    = 4194304
                        LastBootUpTime         = [datetime]'2026-09-09T06:00:00Z'
                    }
                }

                if ($ClassName -eq 'Win32_Processor') {
                    return [pscustomobject]@{ Name = 'Test CPU' }
                }

                if ($ClassName -eq 'Win32_LogicalDisk') {
                    return [pscustomobject]@{
                        DeviceID = 'C:'
                        FreeSpace = 50GB
                        Size      = 100GB
                    }
                }
            }

            Mock Get-NetIPAddress {
                @(
                    [pscustomobject]@{ IPAddress = '192.0.2.10'; InterfaceAlias = 'Ethernet' }
                    [pscustomobject]@{ IPAddress = '127.0.0.1'; InterfaceAlias = 'Loopback' }
                    [pscustomobject]@{ IPAddress = '169.254.10.20'; InterfaceAlias = 'APIPA' }
                )
            }

            Mock Get-Date { [datetime]'2026-09-11T12:00:00Z' }
        }
    }

    It 'returns a structured report with converted values' {
        InModuleScope SystemInfo {
            $result = Get-SystemInfo

            $result.PSObject.TypeNames | Should -Contain 'GladKhumalo.SystemInfo.Report'
            $result.OperatingSystem.Name | Should -Be 'Microsoft Windows Test'
            $result.CPU | Should -Contain 'Test CPU'
            $result.Memory.TotalGB | Should -Be 16
            $result.Memory.FreeGB | Should -Be 4
            $result.Disks[0].Drive | Should -Be 'C:'
            $result.Disks[0].FreeGB | Should -Be 50
            $result.Uptime.Days | Should -Be 2
            $result.Uptime.Hours | Should -Be 6
        }
    }

    It 'excludes loopback and automatic private addresses' {
        InModuleScope SystemInfo {
            $result = Get-SystemInfo

            $result.NetworkAddresses.Count | Should -Be 1
            $result.NetworkAddresses[0].Address | Should -Be '192.0.2.10'
            $result.NetworkAddresses[0].InterfaceName | Should -Be 'Ethernet'
        }
    }

    It 'queries fixed local disks only' {
        InModuleScope SystemInfo {
            Get-SystemInfo | Out-Null

            Should -Invoke Get-CimInstance -Times 1 -ParameterFilter {
                $ClassName -eq 'Win32_LogicalDisk' -and $Filter -eq 'DriveType=3'
            }
        }
    }
}

Describe 'Export-SystemInfoReport' {
    It 'writes valid JSON that preserves report data' {
        $path = Join-Path -Path $TestDrive -ChildPath 'report.json'
        $report = [pscustomobject]@{
            ComputerName = 'TEST-PC'
            Memory       = [pscustomobject]@{ TotalGB = 16 }
        }

        $report | Export-SystemInfoReport -Path $path
        $exported = Get-Content -Path $path -Raw | ConvertFrom-Json

        $exported.ComputerName | Should -Be 'TEST-PC'
        $exported.Memory.TotalGB | Should -Be 16
    }

    It 'reports an error for an invalid destination' {
        $invalidPath = Join-Path -Path $TestDrive -ChildPath 'missing/report.json'

        { [pscustomobject]@{ Value = 1 } | Export-SystemInfoReport -Path $invalidPath } |
            Should -Throw
    }
}
