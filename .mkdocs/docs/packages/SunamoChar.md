# SunamoChar

Methods for advanced working with char data type

- **NuGet**: [$(@{Name=SunamoChar; CsprojRel=SunamoChar/SunamoChar/SunamoChar.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoChar\README.md; Description=Methods for advanced working with char data type; ApiNamespace=SunamoChar}.Name)](https://www.nuget.org/packages/SunamoChar)
- **Source**: [GitHub](https://github.com/sunamo/SunamoChar)
- **API reference**: [../../api/SunamoChar.html](../../api/SunamoChar.html)

---
Methods for advanced working with the char data type including Unicode character detection, classification, and string manipulation.

## Overview

SunamoChar is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CharHelper** - Main helper class for character operations
- **GeneralCharService** - Service for handling general character operations
- **LetterAndDigitCharService** - Service providing letter and digit character lists
- **LetterAndDigitKeyCodeService** - Service providing letter and digit key codes
- **SpecialCharsService** - Service providing special character definitions
- **SpecialKeyCodeServices** - Service providing special character key codes
- **WhitespaceCharService** - Service for handling whitespace characters

### Key Methods

- `CharHelper.SplitSpecial()` - Splits text by special delimiters including Unicode generic characters
- `CharHelper.IsSpecialChar()` - Checks if a character is whitespace or punctuation
- `CharHelper.IsUnicodeChar()` - Classifies a character into Unicode character type categories
- `CharHelper.OnlyAccepted()` - Filters text to keep only characters matching a predicate
- `CharHelper.OnlyDigits()` - Extracts only digit characters from text

## Installation

```bash
dotnet add package SunamoChar
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Package Information

- **Package Name**: SunamoChar
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

