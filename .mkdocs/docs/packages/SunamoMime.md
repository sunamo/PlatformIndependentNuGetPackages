# SunamoMime

For processing MIME types

- **NuGet**: [$(@{Name=SunamoMime; CsprojRel=SunamoMime/SunamoMime/SunamoMime.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoMime\README.md; Description=For processing MIME types; ApiNamespace=SunamoMime}.Name)](https://www.nuget.org/packages/SunamoMime)
- **Source**: [GitHub](https://github.com/sunamo/SunamoMime)
- **API reference**: [../../api/SunamoMime.html](../../api/SunamoMime.html)

---
A .NET library for determining MIME types and file formats from byte arrays.

## Overview

SunamoMime is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It uses file signature analysis (magic bytes) with built-in WEBP detection and delegates to [FileSignatures](https://github.com/neilharvey/FileSignatures) for other formats.

## Main Components

### Key Classes

- **SunamoMimeHelper** - Helper class for determining MIME types and file formats from byte arrays.

### Key Methods

- `Init()` - Initializes known MIME type signatures.
- `FileType(byte[] array)` - Determines the file type from a byte array by analyzing file signatures.

## Installation

```bash
dotnet add package SunamoMime
```

## Dependencies

- **FileSignatures** (v6.1.1)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoMime
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

