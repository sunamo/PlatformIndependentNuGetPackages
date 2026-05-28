# SunamoLaTeX

Conversion of unicode characters into text symbols

- **NuGet**: [$(@{Name=SunamoLaTeX; CsprojRel=SunamoLaTeX/SunamoLaTeX/SunamoLaTeX.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoLaTeX\README.md; Description=Conversion of unicode characters into text symbols; ApiNamespace=SunamoLaTeX}.Name)](https://www.nuget.org/packages/SunamoLaTeX)
- **Source**: [GitHub](https://github.com/sunamo/SunamoLaTeX)
- **API reference**: [../../api/SunamoLaTeX.html](../../api/SunamoLaTeX.html)

---
A .NET library for converting LaTeX symbol notation to Unicode characters. Maps over 2400 LaTeX commands to their corresponding Unicode equivalents.

## Overview

SunamoLaTeX is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

### Key Classes

- **LatexHelper** - Provides static methods for LaTeX-to-Unicode conversion.

### Key Methods

- `ConvertToUnicode(string latexText)` - Converts LaTeX text to Unicode by replacing LaTeX symbols with their Unicode equivalents.

## Installation

```bash
dotnet add package SunamoLaTeX
```

## Usage

```csharp
using SunamoLaTeX;

string unicode = LatexHelper.ConvertToUnicode("\\alpha + \\beta = \\gamma");
// Result: "α + β = γ"
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoLaTeX
- **Target Frameworks**: `net10.0;net9.0;net8.0`
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the [main repository](https://github.com/sunamo/PlatformIndependentNuGetPackages).

## License

See the repository root for license information.

