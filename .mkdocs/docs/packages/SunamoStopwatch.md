# SunamoStopwatch

Measuring time between operations

- **NuGet**: [$(@{Name=SunamoStopwatch; CsprojRel=SunamoStopwatch/SunamoStopwatch/SunamoStopwatch.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoStopwatch\README.md; Description=Measuring time between operations; ApiNamespace=SunamoStopwatch}.Name)](https://www.nuget.org/packages/SunamoStopwatch)
- **Source**: [GitHub](https://github.com/sunamo/SunamoStopwatch)
- **API reference**: [../../api/SunamoStopwatch.html](../../api/SunamoStopwatch.html)

---
Measuring time between operations.

## Overview

SunamoStopwatch is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It offers both instance-based (`StopwatchHelper`) and static (`StopwatchStatic`) APIs for measuring elapsed time of operations.

## Main Components

### Key Classes

- **StopwatchHelper** - Instance-based stopwatch for measuring elapsed time with support for saving and printing results.
- **StopwatchStatic** - Static wrapper providing global stopwatch functionality without needing to manage instances.

### Key Methods

- `SaveElapsed()` - Saves the elapsed time for a named operation.
- `Reset()` - Resets the stopwatch to zero.
- `Start()` - Resets and starts the stopwatch.
- `Stop()` - Stops the stopwatch and returns the elapsed time as a formatted string.
- `StopAndPrintElapsed()` - Stops, prints, and returns the elapsed milliseconds.
- `PrintElapsedAndContinue()` - Prints elapsed time and restarts the stopwatch.
- `CalculateAverageOfTakes()` - Calculates average elapsed time from a list of timing records.
- `StopAndElapsedMilliseconds()` - Stops the stopwatch and returns the elapsed milliseconds.

## Installation

```bash
dotnet add package SunamoStopwatch
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoStopwatch
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

