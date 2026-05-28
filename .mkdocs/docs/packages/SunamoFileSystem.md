# SunamoFileSystem

Overall working with filesystem

- **NuGet**: [$(@{Name=SunamoFileSystem; CsprojRel=SunamoFileSystem/SunamoFileSystem/SunamoFileSystem.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoFileSystem\README.md; Description=Overall working with filesystem; ApiNamespace=SunamoFileSystem}.Name)](https://www.nuget.org/packages/SunamoFileSystem)
- **Source**: [GitHub](https://github.com/sunamo/SunamoFileSystem)
- **API reference**: [../../api/SunamoFileSystem.html](../../api/SunamoFileSystem.html)

---
Overall working with filesystem

## Overview

SunamoFileSystem is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **AppPaths**
- **GetExtensionArgs**
- **FileSystemWatchers**
- **FS**

### Key Methods

- `GetStartupPath()`
- `GetFileInStartupPath()`
- `Start()`
- `Stop()`
- `IsAbsolutePath()`
- `CopyFolder()`
- `CreateUpfoldersPsysicallyUnlessThere()`
- `ExistsDirectory()`
- `CreateFoldersPsysicallyUnlessThere()`

## Installation

```bash
dotnet add package SunamoFileSystem
```

## Dependencies

- **Diacritics** (v3.3.29)
- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)

## Package Information

- **Package Name**: SunamoFileSystem
- **Version**: 25.10.3.4
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 54

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

