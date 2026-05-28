# SunamoRandom

Generate random objects and values

- **NuGet**: [$(@{Name=SunamoRandom; CsprojRel=SunamoRandom/SunamoRandom/SunamoRandom.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoRandom\README.md; Description=Generate random objects and values; ApiNamespace=SunamoRandom}.Name)](https://www.nuget.org/packages/SunamoRandom)
- **Source**: [GitHub](https://github.com/sunamo/SunamoRandom)
- **API reference**: [../../api/SunamoRandom.html](../../api/SunamoRandom.html)

---
A lightweight .NET library for generating random values of various types including integers, floats, bytes, strings, booleans, DateTimes, and enum values.

## Overview

SunamoRandom is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **RandomHelper** - Core static class with methods for generating random primitives, strings, and collection elements
- **RandomHelperList** - Generates lists of random numbers with specified digit lengths
- **RandomStringHelper** - Generates random strings with configurable alphanumeric and special character composition

### Key Methods

- `RandomInt()`, `RandomInt2()` - Random integers with various bound options
- `RandomFloat()` - Random floats with configurable precision
- `RandomByte()`, `RandomBytes()` - Random bytes and byte arrays
- `RandomString()`, `RandomStringWithoutSpecial()` - Random strings with character type control
- `RandomBool()` - Random boolean values
- `RandomDateTime()` - Random DateTime values
- `RandomEnum<T>()` - Random enum values
- `RandomElementOfCollectionT<T>()` - Random element from a typed collection
- `RandomColorPart()` - Random color component bytes

## Installation

```bash
dotnet add package SunamoRandom
```

## Target Frameworks

`net10.0`, `net9.0`, `net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## License

MIT

