@{
    RootModule        = 'SystemInfo.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '4eec1e65-9a08-462e-8864-18b0d2b7f15e'
    Author            = 'Glad Khumalo'
    Copyright         = '(c) 2026 Glad Khumalo. All rights reserved.'
    Description       = 'Collect and export essential Windows system information.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Get-SystemInfo', 'Export-SystemInfoReport')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags       = @('Windows', 'SystemInformation', 'Administration', 'Automation')
            LicenseUri = 'https://github.com/gladkhumalo/System-Info-Script/blob/main/LICENSE'
            ProjectUri = 'https://github.com/gladkhumalo/System-Info-Script'
        }
    }
}
