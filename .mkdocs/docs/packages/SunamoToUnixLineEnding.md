# SunamoToUnixLineEnding

Extension method for forced conversion of \r\n to \n for use by the same
      applications on Windows and Linux

- **NuGet**: [$(@{Name=SunamoToUnixLineEnding; CsprojRel=SunamoToUnixLineEnding/SunamoToUnixLineEnding/SunamoToUnixLineEnding.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoToUnixLineEnding\README.md; Description=Extension method for forced conversion of \r\n to \n for use by the same
      applications on Windows and Linux; ApiNamespace=SunamoToUnixLineEnding}.Name)](https://www.nuget.org/packages/SunamoToUnixLineEnding)
- **Source**: [GitHub](https://github.com/sunamo/SunamoToUnixLineEnding)
- **API reference**: [../../api/SunamoToUnixLineEnding.html](../../api/SunamoToUnixLineEnding.html)

---
Extension methods for forced conversion of `\r\n` to `\n` for use by the same applications on Windows and Linux.

## Overview

SunamoToUnixLineEnding is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **Consts2** - Constants for line ending characters (`Newline`, `CarriageReturnNewline`)
- **IListToUnixLineEndingExtensions** - Extension method for converting line endings in `IList<string>`
- **StringToUnixLineEndingExtensions** - Extension method for converting line endings in `string`

### Key Methods

- `ToUnixLineEnding()` - Converts all line endings to Unix format (LF only)

## Installation

```bash
dotnet add package SunamoToUnixLineEnding
```

## Usage

```csharp
using SunamoToUnixLineEnding;

// Convert a single string
string text = "Hello\r\nWorld";
string unixText = text.ToUnixLineEnding(); // "Hello\nWorld"

// Convert all strings in a list
IList<string> lines = new List<string> { "line1\r\npart1", "line2\r\npart2" };
lines.ToUnixLineEnding(); // All elements now use \n
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Package Information

- **Package Name**: SunamoToUnixLineEnding
- **Target Frameworks**: net10.0, net9.0, net8.0
- **License**: MIT
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

