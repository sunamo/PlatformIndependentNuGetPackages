# SunamoTwoWayDictionary

Dictionary where every key is value and vice versa

- **NuGet**: [$(@{Name=SunamoTwoWayDictionary; CsprojRel=SunamoTwoWayDictionary/SunamoTwoWayDictionary/SunamoTwoWayDictionary.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoTwoWayDictionary\README.md; Description=Dictionary where every key is value and vice versa; ApiNamespace=SunamoTwoWayDictionary}.Name)](https://www.nuget.org/packages/SunamoTwoWayDictionary)
- **Source**: [GitHub](https://github.com/sunamo/SunamoTwoWayDictionary)
- **API reference**: [../../api/SunamoTwoWayDictionary.html](../../api/SunamoTwoWayDictionary.html)

---
A bidirectional dictionary for .NET that maintains forward and reverse mappings, allowing lookup in both directions.

## Overview

SunamoTwoWayDictionary is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **TwoWayDictionary<TKey, TValue>** - A dictionary maintaining bidirectional mapping between keys and values

### Key Methods

- `Add(TKey key, TValue value)` - Adds a key-value pair to both forward and reverse dictionaries

## Installation

```bash
dotnet add package SunamoTwoWayDictionary
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoTwoWayDictionary
- **Target Frameworks**: net10.0; net9.0; net8.0
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

