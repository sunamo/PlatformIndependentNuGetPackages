# SunamoLogging

Support for several logging system based on their output

- **NuGet**: [$(@{Name=SunamoLogging; CsprojRel=SunamoLogging/SunamoLogging/SunamoLogging.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoLogging\README.md; Description=Support for several logging system based on their output; ApiNamespace=SunamoLogging}.Name)](https://www.nuget.org/packages/SunamoLogging)
- **Source**: [GitHub](https://github.com/sunamo/SunamoLogging)
- **API reference**: [../../api/SunamoLogging.html](../../api/SunamoLogging.html)

---
Support for several logging system based on their output

## Overview

SunamoLogging is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **as**
- **FileLogger**
- **FileLoggerExtensions**
- **FileLoggerProvider**
- **ILoggerExtensions**
- **InitApp**
- **DebugLogger**

### Key Methods

- `ClipboardOrDebug()`
- `WriteLineFormat()`
- `WriteCount()`
- `WriteList()`
- `WriteListOneRow()`
- `SavedToDrive()`
- `TryAFewSecondsLaterAfterFullyInitialized()`
- `Finished()`
- `EndRunTime()`
- `ResultCopiedToClipboard()`

## Installation

```bash
dotnet add package SunamoLogging
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v9.0.5)

## Package Information

- **Package Name**: SunamoLogging
- **Version**: 25.6.7.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 34

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

