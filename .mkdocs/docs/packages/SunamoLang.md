# SunamoLang

Support for language, independent of translating solution

- **NuGet**: [$(@{Name=SunamoLang; CsprojRel=SunamoLang/SunamoLang/SunamoLang.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoLang\README.md; Description=Support for language, independent of translating solution; ApiNamespace=SunamoLang}.Name)](https://www.nuget.org/packages/SunamoLang)
- **Source**: [GitHub](https://github.com/sunamo/SunamoLang)
- **API reference**: [../../api/SunamoLang.html](../../api/SunamoLang.html)

---
Platform-independent language support library for .NET applications. Provides localization utilities, XLF (XLIFF) file processing, Czech language helpers, and culture management.

## Overview

SunamoLang is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CountryLang** - Language-to-country code mapping
- **LocaleHelperLang** - Locale conversion operations
- **AppLang** - Application language settings model
- **AppLangHelper** - Language settings and culture management
- **AppLangConverter** - AppLang to/from string conversion
- **CzechHelper** - Czech language text processing
- **TranslateDictionary** - Translation key-value storage with auto-reload
- **XlfResourcesH** - XLF resource loading and processing
- **ResourcesDuo** - Strongly-typed resource manager

## Installation

```bash
dotnet add package SunamoLang
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoLang
- **Target Frameworks**: net10.0, net9.0, net8.0
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

