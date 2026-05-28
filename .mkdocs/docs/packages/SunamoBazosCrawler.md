# SunamoBazosCrawler

parsing of advertisements from bazos.cz/.sk

- **NuGet**: [$(@{Name=SunamoBazosCrawler; CsprojRel=SunamoBazosCrawler/SunamoBazosCrawler/SunamoBazosCrawler.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoBazosCrawler\README.md; Description=parsing of advertisements from bazos.cz/.sk; ApiNamespace=SunamoBazosCrawler}.Name)](https://www.nuget.org/packages/SunamoBazosCrawler)
- **Source**: [GitHub](https://github.com/sunamo/SunamoBazosCrawler)
- **API reference**: [../../api/SunamoBazosCrawler.html](../../api/SunamoBazosCrawler.html)

---
Parsing of advertisements from bazos.cz/.sk

## Overview

SunamoBazosCrawler is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It crawls and parses dating advertisements from the Bazos website.

## Main Components

### Key Classes

- **BazosCrawlerHelper** - Helper class for crawling and parsing dating advertisements from Bazos website
- **DatingAd** - Represents a dating advertisement with Title, Description, Price, and Location

### Key Methods

- `BazosCrawlerHelper.ParseFromOnline(url, downloadContentFunc)` - Parses dating advertisements from the specified URL

## Installation

```bash
dotnet add package SunamoBazosCrawler
```

## Dependencies

- **HtmlAgilityPack** (v1.12.4)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Target Frameworks

- net10.0
- net9.0
- net8.0

## Package Information

- **Package Name**: SunamoBazosCrawler
- **License**: MIT
- **Authors**: www.sunamo.cz

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

