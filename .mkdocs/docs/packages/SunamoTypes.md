# SunamoTypes

Types of .NET classes (will be removed later)

- **NuGet**: [$(@{Name=SunamoTypes; CsprojRel=SunamoTypes/SunamoTypes/SunamoTypes.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoTypes\README.md; Description=Types of .NET classes (will be removed later); ApiNamespace=SunamoTypes}.Name)](https://www.nuget.org/packages/SunamoTypes)
- **Source**: [GitHub](https://github.com/sunamo/SunamoTypes)
- **API reference**: [../../api/SunamoTypes.html](../../api/SunamoTypes.html)

---
Provides cached `System.Type` references for common .NET types, delegate types, and generic list types.

## Overview

SunamoTypes is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It eliminates repeated `typeof()` calls by exposing pre-cached `Type` references.

## Main Components

### Key Classes

- **Types** - Cached type references for primitive and basic .NET types (`int`, `string`, `DateTime`, `bool`, etc.)
- **TypesDelegates** - Cached type references for delegate types (`Action`, `Func<Task>`)
- **TypesList** - Cached type references for generic `List<T>` types (`List<long>`, `List<string>`)

## Installation

```bash
dotnet add package SunamoTypes
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoTypes
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

