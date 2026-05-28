# SunamoTextOutputGenerator

Generating string output in various formats

- **NuGet**: [$(@{Name=SunamoTextOutputGenerator; CsprojRel=SunamoTextOutputGenerator/SunamoTextOutputGenerator/SunamoTextOutputGenerator.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoTextOutputGenerator\README.md; Description=Generating string output in various formats; ApiNamespace=SunamoTextOutputGenerator}.Name)](https://www.nuget.org/packages/SunamoTextOutputGenerator)
- **Source**: [GitHub](https://github.com/sunamo/SunamoTextOutputGenerator)
- **API reference**: [../../api/SunamoTextOutputGenerator.html](../../api/SunamoTextOutputGenerator.html)

---
Generating string output in various formats.

## Overview

SunamoTextOutputGenerator is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It offers fluent text generation for headers, lists, paragraphs, dictionaries, and percentage distributions.

## Main Components

### Key Classes

- **TextOutputGenerator** - Main class for building formatted text output with headers, lists, paragraphs, and dictionary formatting.
- **TextOutputGeneratorStatic** - Static helper methods for generating text output from collections and dictionaries.
- **TextBuilder** - Text builder with StringBuilder and List modes, supporting undo capability.
- **TextGenerator** - Static utilities for generating text with percentage distribution.
- **CompareCollectionsResults** - Collection comparison result with text output generation.
- **NpmBashBuilder** - Builder for generating npm bash commands.
- **StaticSBNoThread** - Static non-thread-safe StringBuilder wrapper.
- **TextOutputGeneratorArgs** - Arguments for controlling list formatting behavior.

### Key Interfaces

- **ITextBuilder** - Interface for text building with append and undo support.
- **IPercentCalculatorTog** - Interface for percentage calculations in text generation.

## Installation

```bash
dotnet add package SunamoTextOutputGenerator
```

## Usage

```csharp
var generator = new TextOutputGenerator();

// Add a header
generator.Header("Results");

// Add a list
generator.List(new List<string> { "item1", "item2", "item3" }, "Items");

// Add a paragraph
generator.Paragraph("Some detailed text here.", "Details");

// Get the output
string output = generator.ToString();
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Package Information

- **Package Name**: SunamoTextOutputGenerator
- **License**: MIT
- **Repository**: [GitHub](https://github.com/sunamo/SunamoTextOutputGenerator)

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT License - see the repository root for details.

