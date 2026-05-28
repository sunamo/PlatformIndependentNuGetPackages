# SunamoPaths

Paths for internal use of sunamo's projects

- **NuGet**: [$(@{Name=SunamoPaths; CsprojRel=SunamoPaths/SunamoPaths/SunamoPaths.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoPaths\README.md; Description=Paths for internal use of sunamo's projects; ApiNamespace=SunamoPaths}.Name)](https://www.nuget.org/packages/SunamoPaths)
- **Source**: [GitHub](https://github.com/sunamo/SunamoPaths)
- **API reference**: [../../api/SunamoPaths.html](../../api/SunamoPaths.html)

---
Paths for internal use of sunamo's projects.

## Overview

SunamoPaths is part of the Sunamo package ecosystem, providing modular, platform-independent path utilities for .NET development. It defines default paths used across the sunamo project infrastructure, including Visual Studio project roots, document folders, and comparison test file helpers.

## Main Components

### Key Classes

- **DefaultPaths** - Central repository of path constants and static fields for the sunamo project infrastructure (VS root, project folders, documents, sync archives, etc.)
- **CompareFilesPaths** - Helper for constructing file paths used in file comparison operations
- **CompareTwoFilesHelper** - Helper for constructing paths to text and HTML comparison test files

### Key Methods

- `CompareFilesPaths.GetFile()` - Gets a comparison file path by extension type and index
- `CompareTwoFilesHelper.Txt()` - Gets a text comparison file path by index
- `CompareTwoFilesHelper.Html()` - Gets an HTML comparison file path by index
- `DefaultPaths.IsIgnored()` - Checks whether a path matches known ignore patterns

## Installation

```bash
dotnet add package SunamoPaths
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoPaths
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0; net9.0; net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

