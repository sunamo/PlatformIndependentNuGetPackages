# SunamoXliffParser

Just fork from https://www.nuget.org/packages/fmdev.XliffParser, due to .NET 5+

- **NuGet**: [$(@{Name=SunamoXliffParser; CsprojRel=SunamoXliffParser/SunamoXliffParser/SunamoXliffParser.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoXliffParser\README.md; Description=Just fork from https://www.nuget.org/packages/fmdev.XliffParser, due to .NET 5+; ApiNamespace=SunamoXliffParser}.Name)](https://www.nuget.org/packages/SunamoXliffParser)
- **Source**: [GitHub](https://github.com/sunamo/SunamoXliffParser)
- **API reference**: [../../api/SunamoXliffParser.html](../../api/SunamoXliffParser.html)

---
A .NET library for parsing, modifying, and exporting XLIFF (XML Localization Interchange File Format) documents. Fork of [fmdev.XliffParser](https://www.nuget.org/packages/fmdev.XliffParser) updated for .NET 8+.

## Overview

SunamoXliffParser is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **XlfDocument** - Main entry point for loading and manipulating XLIFF files
- **XlfFile** - Represents a file element within an XLIFF document
- **XlfTransUnit** - Represents a single translation unit with source, target, and metadata
- **ResXEntry** - Represents a single ResX resource entry
- **ResXFile** - Utility for reading and writing ResX resource files
- **UpdateResult** - Contains results of an XLIFF update operation

### Key Methods

- `XlfDocument.Update()` - Updates XLIFF data from a ResX source file
- `XlfDocument.SaveAsResX()` - Exports XLIFF as a ResX file
- `XlfDocument.UpdateFromSource()` - Updates from the associated source file
- `XlfFile.AddTransUnit()` - Adds a new translation unit
- `XlfFile.Export()` - Exports filtered translation units
- `ResXFile.Read()` - Reads entries from a ResX file
- `ResXFile.Write()` - Writes entries to a ResX file

## Installation

```bash
dotnet add package SunamoXliffParser
```

## Dependencies

- **ResXResourceReader.NetStandard** (v1.3.0)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoXliffParser
- **Target Frameworks**: net10.0;net9.0;net8.0
- **License**: MIT
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

