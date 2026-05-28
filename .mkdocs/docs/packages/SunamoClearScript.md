# SunamoClearScript

Wrapper around Microsoft.ClearScript offering easier work

- **NuGet**: [$(@{Name=SunamoClearScript; CsprojRel=SunamoClearScript/SunamoClearScript/SunamoClearScript.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoClearScript\README.md; Description=Wrapper around Microsoft.ClearScript offering easier work; ApiNamespace=SunamoClearScript}.Name)](https://www.nuget.org/packages/SunamoClearScript)
- **Source**: [GitHub](https://github.com/sunamo/SunamoClearScript)
- **API reference**: [../../api/SunamoClearScript.html](../../api/SunamoClearScript.html)

---
Wrapper around Microsoft.ClearScript offering easier JavaScript code compilation and execution via the V8 engine.

## Overview

SunamoClearScript is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **ClearScriptHelper** - Singleton helper for compiling JavaScript code using ClearScript V8 engine.

### Key Methods

- `Execute(string code)` - Compiles JavaScript code and returns whether it was successful.

## Installation

```bash
dotnet add package SunamoClearScript
```

## Dependencies

- **Microsoft.ClearScript.Core** (v7.5.0)
- **Microsoft.ClearScript.V8** (v7.5.0)
- **Microsoft.ClearScript.V8.Native.win-x86** (v7.5.0)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoClearScript
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

