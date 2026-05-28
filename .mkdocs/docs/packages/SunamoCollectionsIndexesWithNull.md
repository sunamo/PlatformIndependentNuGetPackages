# SunamoCollectionsIndexesWithNull

To change from arrays to List<T> to create the required number of dummy
      elements in List<T>

- **NuGet**: [$(@{Name=SunamoCollectionsIndexesWithNull; CsprojRel=SunamoCollectionsIndexesWithNull/SunamoCollectionsIndexesWithNull/SunamoCollectionsIndexesWithNull.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionsIndexesWithNull\README.md; Description=To change from arrays to List<T> to create the required number of dummy
      elements in List<T>; ApiNamespace=SunamoCollectionsIndexesWithNull}.Name)](https://www.nuget.org/packages/SunamoCollectionsIndexesWithNull)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionsIndexesWithNull)
- **API reference**: [../../api/SunamoCollectionsIndexesWithNull.html](../../api/SunamoCollectionsIndexesWithNull.html)

---
Utility library for finding indexes of null or empty elements in collections.

## Overview

SunamoCollectionsIndexesWithNull is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CAIndexesWithNull** - Provides methods for finding indexes of null or empty elements in collections.

### Key Methods

- `IndexesWithNullOrEmpty(IList list)` - Returns indexes where elements are null or have empty string representation.
- `IndexesWithNull(IList list)` - Returns indexes where elements are null.

## Installation

```bash
dotnet add package SunamoCollectionsIndexesWithNull
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoCollectionsIndexesWithNull
- **Target Frameworks**: net10.0; net9.0; net8.0
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

