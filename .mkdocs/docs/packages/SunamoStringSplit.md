# SunamoStringSplit

Methods for splitting strings

- **NuGet**: [$(@{Name=SunamoStringSplit; CsprojRel=SunamoStringSplit/SunamoStringSplit/SunamoStringSplit.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoStringSplit\README.md; Description=Methods for splitting strings; ApiNamespace=SunamoStringSplit}.Name)](https://www.nuget.org/packages/SunamoStringSplit)
- **Source**: [GitHub](https://github.com/sunamo/SunamoStringSplit)
- **API reference**: [../../api/SunamoStringSplit.html](../../api/SunamoStringSplit.html)

---
A .NET library providing comprehensive methods for splitting strings using various delimiters and strategies.

## Overview

SunamoStringSplit is part of the Sunamo package ecosystem, providing modular, platform-independent string splitting utilities for .NET development.

## Key Features

- Split strings by characters, strings, whitespace, or punctuation
- Split with or without removing empty entries
- Split into a specific number of parts (from start or end)
- Split while keeping delimiters in the result
- Split and filter by regex patterns
- Split by character indexes
- Split by letter count

## Main Methods

- `Split()` - Split by string delimiters with various options
- `SplitChar()` / `SplitCharList()` - Split by character delimiters
- `SplitNone()` / `SplitNoneChar()` - Split without removing empty entries
- `SplitByWhiteSpaces()` - Split by all Unicode whitespace characters
- `SplitBySpaceAndPunctuationChars()` - Split by space and punctuation
- `SplitByNewLines()` - Split by newline characters
- `SplitAndKeepDelimiters()` - Split while preserving delimiters
- `SplitAndReturnRegexMatches()` - Split and filter by regex
- `SplitByIndex()` / `SplitByIndexes()` - Split at specific positions
- `SplitByLetterCount()` - Split into equal-length segments
- `SplitToParts()` - Split into a specific number of parts
- `SplitToPartsFromEnd()` - Split into parts from the end
- `SplitToIntList()` - Split and parse to integers

## Installation

```bash
dotnet add package SunamoStringSplit
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- Microsoft.Extensions.Logging.Abstractions

## License

MIT

