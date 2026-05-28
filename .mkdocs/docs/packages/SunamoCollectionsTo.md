# SunamoCollectionsTo

For easier creation and transfer of collections between each other

- **NuGet**: [$(@{Name=SunamoCollectionsTo; CsprojRel=SunamoCollectionsTo/SunamoCollectionsTo/SunamoCollectionsTo.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionsTo\README.md; Description=For easier creation and transfer of collections between each other; ApiNamespace=SunamoCollectionsTo}.Name)](https://www.nuget.org/packages/SunamoCollectionsTo)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionsTo)
- **API reference**: [../../api/SunamoCollectionsTo.html](../../api/SunamoCollectionsTo.html)

---
Provides helper methods for easier creation and conversion of collections between each other.

## Overview

SunamoCollectionsTo is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CollectionsHelperTo** - Static helper class for collection conversions.

### Key Methods

- `ToList<T>(params T[])` - Converts an array of elements to a List.
- `ToArray<T>(params T[])` - Returns the provided elements as an array.
- `ToListString(params object[])` - Converts an array of objects to a List of strings.

## Installation

```bash
dotnet add package SunamoCollectionsTo
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoCollectionsTo
- **Version**: 26.4.6.4
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the LICENSE file for details.

