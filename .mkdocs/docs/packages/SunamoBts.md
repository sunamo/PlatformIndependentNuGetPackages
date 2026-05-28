# SunamoBts

Advanced working with base .NET type (parsing etc.)

- **NuGet**: [$(@{Name=SunamoBts; CsprojRel=SunamoBts/SunamoBts/SunamoBts.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoBts\README.md; Description=Advanced working with base .NET type (parsing etc.); ApiNamespace=SunamoBts}.Name)](https://www.nuget.org/packages/SunamoBts)
- **Source**: [GitHub](https://github.com/sunamo/SunamoBts)
- **API reference**: [../../api/SunamoBts.html](../../api/SunamoBts.html)

---
Advanced utilities for working with base .NET types including parsing, conversion, and type system operations.

## Overview

SunamoBts is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It focuses on safe parsing of primitive types with fallback values, type conversions between numeric types, and common boolean/string operations.

## Main Components

### BTS (Basic Type System)

Core class providing:
- **Parsing methods** - `ParseInt`, `ParseFloat`, `ParseDouble`, `ParseBool`, `ParseByte`, `ParseShort` with default value support
- **TryParse methods** - `TryParseInt`, `TryParseBool`, `TryParseByte`, `TryParseDateTime`, `TryParseUint` with safe fallbacks
- **Type validation** - `IsInt`, `IsFloat`, `IsDouble`, `IsLong`, `IsBool`, `IsByte`, `IsDateTime`
- **Conversions** - `BoolToInt`, `IntToBool`, `BoolToString`, `StringToBool`, `FromHex`
- **Stream utilities** - `StreamFromString`, `StringFromStream`
- **Date formatting** - `SameLengthAllDateTimes`, `SameLengthAllDates`, `SameLengthAllTimes`, `UsaDateTimeToString`
- **Byte operations** - `ConvertFromUtf8ToBytes`, `ConvertFromBytesToUtf8`, `ClearEndingsBytes`
- **Collection casting** - `CastArrayObjectToString`, `CastCollectionStringToInt`, `CastCollectionShortToInt`
- **Type introspection** - `GetMaxValueForType`, `GetMinValueForType`, `MethodForParse<T>`

### CAToNumber (Collection Array To Number)

Utility class for converting collections and arrays to numeric types:
- `ToNumber<T>` - Generic conversion with parse method delegate, default value, and length validation
- `ToIntTruncating`, `ToIntWithLengthValidation`, `ToIntWithLengthValidationAndOffset` - Specialized integer conversion with various options

## Installation

```bash
dotnet add package SunamoBts
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## License

MIT

