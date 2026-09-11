# Changelog

All notable changes to this project are documented here. This project follows [Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-09-11

### Added

- Reusable `Get-SystemInfo` and `Export-SystemInfoReport` module commands
- PowerShell module manifest
- Structured pipeline output through `-PassThru`
- Pester unit tests for collection, filtering, conversion, and JSON export
- CI testing on PowerShell 7 and Windows PowerShell 5.1
- Release, build, and license badges

### Changed

- Converted the original script into a friendly wrapper around reusable functions
- Expanded usage, testing, structure, privacy, and contribution documentation
- Extended static analysis to the wrapper, module, and tests

### Security

- Continued to exclude loopback and APIPA addresses from reports
- Documented the sensitivity of generated system reports

[1.0.0]: https://github.com/gladkhumalo/System-Info-Script/releases/tag/v1.0.0
