# SunamoStringSubstring

Methods for gets parts of the strings

- **NuGet**: [$(@{Name=SunamoStringSubstring; CsprojRel=SunamoStringSubstring/SunamoStringSubstring/SunamoStringSubstring.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoStringSubstring\README.md; Description=Methods for gets parts of the strings; ApiNamespace=SunamoStringSubstring}.Name)](https://www.nuget.org/packages/SunamoStringSubstring)
- **Source**: [GitHub](https://github.com/sunamo/SunamoStringSubstring)
- **API reference**: [../../api/SunamoStringSubstring.html](../../api/SunamoStringSubstring.html)

---
Provides helper methods for safe substring operations in .NET.

## Overview

SunamoStringSubstring is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **SHSubstring** - Static methods for safe substring extraction with bounds checking.
- **SubstringArgs** - Configuration for controlling substring edge-case behavior.

### Key Methods

- `SubstringStart()` - Substring from start index to end.
- `SubstringIfAvailableStart()` - Safe substring from start index.
- `Substring()` - Substring between two indices with configurable behavior.
- `SubstringIfAvailable()` - Safe substring of specified length from beginning.

## Installation

```bash
dotnet add package SunamoStringSubstring
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoStringSubstring
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

