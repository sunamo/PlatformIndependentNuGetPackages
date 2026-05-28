# SunamoStringJoinPairs

Concatenation of pairs on one line with two definable delimiters

- **NuGet**: [$(@{Name=SunamoStringJoinPairs; CsprojRel=SunamoStringJoinPairs/SunamoStringJoinPairs/SunamoStringJoinPairs.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoStringJoinPairs\README.md; Description=Concatenation of pairs on one line with two definable delimiters; ApiNamespace=SunamoStringJoinPairs}.Name)](https://www.nuget.org/packages/SunamoStringJoinPairs)
- **Source**: [GitHub](https://github.com/sunamo/SunamoStringJoinPairs)
- **API reference**: [../../api/SunamoStringJoinPairs.html](../../api/SunamoStringJoinPairs.html)

---
A lightweight .NET library for concatenating string pairs with two configurable delimiters.

## Overview

SunamoStringJoinPairs is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **SHJoinPairs** - Provides methods for joining string pairs with configurable delimiters.

### Key Methods

- `JoinPairs(params string[] parts)` - Joins pairs using semicolons as default delimiters.
- `JoinPairs(string firstDelimiter, string secondDelimiter, params string[] parts)` - Joins pairs using custom delimiters.

## Installation

```bash
dotnet add package SunamoStringJoinPairs
```

## Target Frameworks

`net10.0`, `net9.0`, `net8.0`

## Dependencies

None (standalone package).

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

