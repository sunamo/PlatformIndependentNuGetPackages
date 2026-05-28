# SunamoFileIO

ReadAllText, WriteAllText etc. with some magic ability

- **NuGet**: [$(@{Name=SunamoFileIO; CsprojRel=SunamoFileIO/SunamoFileIO/SunamoFileIO.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoFileIO\README.md; Description=ReadAllText, WriteAllText etc. with some magic ability; ApiNamespace=SunamoFileIO}.Name)](https://www.nuget.org/packages/SunamoFileIO)
- **Source**: [GitHub](https://github.com/sunamo/SunamoFileIO)
- **API reference**: [../../api/SunamoFileIO.html](../../api/SunamoFileIO.html)

---
ReadAllText, WriteAllText etc. with some magic ability

## Overview

SunamoFileIO is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **FileList**
- **FileText**
- **CloudProvidersHelper**
- **EncodingHelper**
- **Chars**

### Key Methods

- `ReadAllLinesListAsync()`
- `ReadAllBytesListAsync()`
- `WriteAllLinesListAsync()`
- `WriteAllBytesListAsync()`
- `ReadAllText()`
- `WriteAllText()`
- `Init()`
- `OpenSyncAppIfNotRunning()`
- `PrintNamesForEncodingAsIsInSheet()`
- `DetectEncoding()`

## Installation

```bash
dotnet add package SunamoFileIO
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)

## Package Information

- **Package Name**: SunamoFileIO
- **Version**: 25.6.10.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 22

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

