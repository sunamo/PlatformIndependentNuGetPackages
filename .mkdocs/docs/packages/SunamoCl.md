# SunamoCl

Methods for show Countdown and other UI in cmd

- **NuGet**: [$(@{Name=SunamoCl; CsprojRel=SunamoCl/SunamoCl/SunamoCl.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCl\README.md; Description=Methods for show Countdown and other UI in cmd; ApiNamespace=SunamoCl}.Name)](https://www.nuget.org/packages/SunamoCl)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCl)
- **API reference**: [../../api/SunamoCl.html](../../api/SunamoCl.html)

---
Console UI utilities for .NET command-line applications including countdown timers, progress bars, colored output, user input handling, and action selection menus.

## Overview

SunamoCl is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It wraps common console operations into a clean API with support for clipboard integration, formatted tables, typed logging, and interactive user prompts.

## Features

- **Colored console output** - Error (red), Warning (yellow), Success (green), Information (white), Appeal (magenta)
- **User input** - Type-safe prompts with validation, Yes/No questions, number input with range checking, multi-line input
- **Action selection** - Register sync/async actions and let users select from numbered menus
- **Progress bars** - ShellProgressBar wrapper with parent/child support
- **Countdown timers** - Visual countdown with console title flashing for notifications
- **Formatted tables** - Render data as aligned console tables
- **Clipboard integration** - Load input from clipboard or manual typing
- **Console log mirroring** - Tee all output to a file for AI tool analysis
- **Command-line argument parsing** - Integration with CommandLineParser library
- **Dependency injection** - Built-in IConfiguration and ILogger setup

## Installation

```bash
dotnet add package SunamoCl
```

## Key Classes

| Class | Description |
|---|---|
| `CL` | Main static class for console I/O, user prompts, and colored output |
| `CmdBootStrap` | Application bootstrapping with action routing and DI setup |
| `CLActions` | Merges sync/async action dictionaries and runs selected actions |
| `CLProgressBar` | ShellProgressBar wrapper for simple progress tracking |
| `CLProgressBarWithChilds` | Progress bar with nested child progress bars |
| `ClFlasher` | Flashes the console window in the Windows taskbar |
| `ClNotify` | Flashes the console title to attract user attention |
| `CmdTable` | Renders formatted tables in the console |
| `TableParser` | Converts collections to aligned string tables |
| `ConsoleLogger` | Static console logger with internationalization support |
| `TypedConsoleLogger` | Color-coded typed message logger |

## Dependencies

- Microsoft.Extensions.Logging.Abstractions
- CommandLineParser
- Microsoft.Extensions.Configuration.Json
- Microsoft.Extensions.DependencyInjection
- Microsoft.Extensions.Logging
- Microsoft.Extensions.Logging.Console
- ShellProgressBar
- TextCopy

## Target Frameworks

- net10.0
- net9.0
- net8.0

## License

MIT

