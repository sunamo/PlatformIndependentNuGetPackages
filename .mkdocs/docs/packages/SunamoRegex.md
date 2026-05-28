# SunamoRegex

Regex and wildcards helpers

- **NuGet**: [$(@{Name=SunamoRegex; CsprojRel=SunamoRegex/SunamoRegex/SunamoRegex.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoRegex\README.md; Description=Regex and wildcards helpers; ApiNamespace=SunamoRegex}.Name)](https://www.nuget.org/packages/SunamoRegex)
- **Source**: [GitHub](https://github.com/sunamo/SunamoRegex)
- **API reference**: [../../api/SunamoRegex.html](../../api/SunamoRegex.html)

---
Regex and wildcard helpers for .NET applications.

## Overview

SunamoRegex is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It includes precompiled regular expressions for common validation tasks and a wildcard pattern matching engine built on top of the .NET Regex class.

## Key Classes

- **RegexHelper** - Static helper with precompiled regexes for email, URI, phone number, HTML tag, color code, and GUID validation.
- **Wildcard** - Converts wildcard patterns (`*` and `?`) to regular expressions and provides matching functionality.
- **WildcardHelper** - Detects whether a string contains wildcard characters.

## Installation

```bash
dotnet add package SunamoRegex
```

## Target Frameworks

`net10.0;net9.0;net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**
- **xunit**

## License

MIT

