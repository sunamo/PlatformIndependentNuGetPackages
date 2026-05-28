# SunamoClipboard

Working with clipboard

- **NuGet**: [$(@{Name=SunamoClipboard; CsprojRel=SunamoClipboard/SunamoClipboard/SunamoClipboard.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoClipboard\README.md; Description=Working with clipboard; ApiNamespace=SunamoClipboard}.Name)](https://www.nuget.org/packages/SunamoClipboard)
- **Source**: [GitHub](https://github.com/sunamo/SunamoClipboard)
- **API reference**: [../../api/SunamoClipboard.html](../../api/SunamoClipboard.html)

---
A platform-independent .NET library for working with the system clipboard.

## Overview

SunamoClipboard is part of the Sunamo package ecosystem, providing modular, platform-independent clipboard utilities for .NET development. It wraps [TextCopy](https://github.com/CopyText/TextCopy) to offer a simplified API for getting and setting clipboard text, lines, and dictionaries.

## Main Components

### ClipboardHelper

Static helper class providing the following methods:

- `GetText()` - Gets text from the clipboard.
- `GetLines()` - Gets lines from the clipboard split by newline characters.
- `GetLinesAllWhitespaces()` - Gets lines from the clipboard split by all whitespace characters.
- `SetText(string text)` - Sets text to the clipboard.
- `SetText(StringBuilder stringBuilder)` - Sets text from a StringBuilder to the clipboard.
- `SetLines(List<string> list)` - Sets multiple lines to the clipboard joined by newlines.
- `SetDictionary<T1, T2>(Dictionary<T1, T2> dictionary, string delimiter)` - Sets a dictionary to the clipboard with a custom delimiter.
- `AppendText(string textToAppend)` - Appends text to existing clipboard content.

## Installation

```bash
dotnet add package SunamoClipboard
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)
- **TextCopy** (v6.2.1)

## License

MIT

