# SunamoDotNetZip

.NET 9 fork for DotNetZip because have high security vulnerability

- **NuGet**: [$(@{Name=SunamoDotNetZip; CsprojRel=SunamoDotNetZip/SunamoDotNetZip/SunamoDotNetZip.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoDotNetZip\README.md; Description=.NET 9 fork for DotNetZip because have high security vulnerability; ApiNamespace=Ionic.Zip}.Name)](https://www.nuget.org/packages/SunamoDotNetZip)
- **Source**: [GitHub](https://github.com/sunamo/SunamoDotNetZip)
- **API reference**: [../../api/Ionic.Zip.html](../../api/Ionic.Zip.html)

---
.NET 9 fork for DotNetZip because have high security vulnerability

## Overview

SunamoDotNetZip is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **BZip2InputStream**
- **BZip2OutputStream**
- **ParallelBZip2OutputStream**
- **ComHelper**

### Key Methods

- `Reset()`
- `WriteBits()`
- `WriteByte()`
- `WriteInt()`
- `Flush()`
- `Fill()`
- `CompressAndWrite()`
- `MatchesSig()`
- `IsZipFile()`
- `IsZipFileWithExtract()`

## Installation

```bash
dotnet add package SunamoDotNetZip
```

## Dependencies

- **System.Security.Permissions** (v9.0.3)
- **System.Text.Encoding.CodePages** (v9.0.3)
- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)
- **DotNet.ReproducibleBuilds** (v1.2.25)

## Package Information

- **Package Name**: SunamoDotNetZip
- **Version**: 25.6.16.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 60

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

