# SunamoJson

Wrapper aroung Utf8Json, switching between different json libraries within one
      interface

- **NuGet**: [$(@{Name=SunamoJson; CsprojRel=SunamoJson/SunamoJson/SunamoJson.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoJson\README.md; Description=Wrapper aroung Utf8Json, switching between different json libraries within one
      interface; ApiNamespace=SunamoJson}.Name)](https://www.nuget.org/packages/SunamoJson)
- **Source**: [GitHub](https://github.com/sunamo/SunamoJson)
- **API reference**: [../../api/SunamoJson.html](../../api/SunamoJson.html)

---
JSON serialization and deserialization helper library built on Newtonsoft.Json, providing simplified file I/O operations for JSON data.

## Overview

SunamoJson is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **SerializerHelperJson** - Read from and write to JSON files with configurable options
- **JsonGenerator** - Simple JSON content builder using key-value pairs
- **ReadFromJsonFileArgs** - Configuration for JSON file reading
- **WriteToJsonFileArgs** - Configuration for JSON file writing

### Key Methods

- `SerializerHelperJson.WriteToJsonFile<T>()` - Serialize an object to a JSON file
- `SerializerHelperJson.ReadFromJsonFile<T>()` - Deserialize an object from a JSON file
- `JsonGenerator.Pair()` - Add a key-value pair to JSON output

## Installation

```bash
dotnet add package SunamoJson
```

## Dependencies

- **Newtonsoft.Json** (13.0.4)
- **Microsoft.Extensions.Logging.Abstractions** (10.0.2)

## Package Information

- **Package Name**: SunamoJson
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

