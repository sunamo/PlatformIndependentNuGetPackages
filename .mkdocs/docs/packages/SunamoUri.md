# SunamoUri

For working with URL (Uniform Resource Locator / Identifier)

- **NuGet**: [$(@{Name=SunamoUri; CsprojRel=SunamoUri/SunamoUri/SunamoUri.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoUri\README.md; Description=For working with URL (Uniform Resource Locator / Identifier); ApiNamespace=SunamoUri}.Name)](https://www.nuget.org/packages/SunamoUri)
- **Source**: [GitHub](https://github.com/sunamo/SunamoUri)
- **API reference**: [../../api/SunamoUri.html](../../api/SunamoUri.html)

---
A .NET library for working with URLs (Uniform Resource Locators / Identifiers). Provides comprehensive URI manipulation, encoding/decoding, query string parsing, and URL sanitization utilities.

## Overview

SunamoUri is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### QSHelper

Query string helper class for parsing and manipulating URL query strings.

- `GetParameter()` - Get a parameter value from a URI (returns null if not found)
- `GetParameterSE()` - Get a parameter value from a URI (returns empty string if not found)
- `GetQS()` - Build a query string URL from parameters
- `GetNormalizeQS()` - Normalize a query string by sorting parameters
- `ParseQs()` - Parse a query string into a dictionary
- `RemoveQs()` - Remove the query string from a URI

### UH (URI Helper)

Main URI helper class with methods for URL manipulation.

- `RemovePrefixHttpOrHttps()` - Remove HTTP/HTTPS protocol prefix
- `AppendHttpIfNotExists()` / `AppendHttpsIfNotExists()` - Ensure protocol prefix
- `GetHost()` - Extract host name from a URI
- `GetFileName()` - Extract file name from a URI
- `GetDirectoryName()` - Extract directory path from a URI
- `GetUriSafeString()` - Convert text to a URI-safe slug
- `UrlEncode()` / `UrlDecode()` - URL encoding/decoding
- `Combine()` - Combine URI segments
- `IsValidUriAndDomainIs()` - Validate URI and check domain
- `KeepOnlyHostAndProtocol()` - Extract host and protocol only
- `SanitizeKeepOnlyHost()` - Sanitize URI to host name only

## Installation

```bash
dotnet add package SunamoUri
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- **CaseDotNet** (v0.3.36) - Case conversion utilities
- **Diacritics** (v4.1.4) - Diacritics removal
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2) - Logging abstractions

## Package Information

- **Authors**: www.sunamo.cz
- **License**: MIT
- **Repository**: [GitHub](https://github.com/sunamo/SunamoUri)

## Related Packages

This package is part of the [Sunamo package ecosystem](https://www.nuget.org/profiles/sunamo). For more information about related packages, visit the main repository.

