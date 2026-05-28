# SunamoFtp

Base classes and infrastructure for FTP clients

- **NuGet**: [$(@{Name=SunamoFtp; CsprojRel=SunamoFtp/SunamoFtp/SunamoFtp.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoFtp\README.md; Description=Base classes and infrastructure for FTP clients; ApiNamespace=SunamoFtp.Base}.Name)](https://www.nuget.org/packages/SunamoFtp)
- **Source**: [GitHub](https://github.com/sunamo/SunamoFtp)
- **API reference**: [../../api/SunamoFtp.Base.html](../../api/SunamoFtp.Base.html)

---
Base classes and infrastructure for FTP clients

## Overview

SunamoFtp is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **FtpHelper**
- **PathSelector**
- **FTP**
- **FtpDllWrapper**
- **FtpNet**
- **CustomFtpCommands**

### Key Methods

- `setRemoteHost()`
- `getRemoteHost()`
- `setRemotePort()`
- `getRemotePort()`
- `setRemoteUser()`
- `OnNewStatusNewFolder()`
- `OnUploadingNewStatus()`
- `OnNewStatus()`
- `UploadFiles()`
- `GetActualPath()`

## Installation

```bash
dotnet add package SunamoFtp
```

## Dependencies

- **Ftp.dll** (v2.0.25070.2003)
- **System.Formats.Asn1** (v9.0.3)
- **System.Net.Http** (v4.3.4)
- **System.Text.Encodings.Web** (v9.0.3)
- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)

## Package Information

- **Package Name**: SunamoFtp
- **Version**: 25.6.7.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 24

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

