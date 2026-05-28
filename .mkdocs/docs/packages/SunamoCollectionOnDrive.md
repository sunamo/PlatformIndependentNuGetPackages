# SunamoCollectionOnDrive

A collection that maintains its content even in a permanent file

- **NuGet**: [$(@{Name=SunamoCollectionOnDrive; CsprojRel=SunamoCollectionOnDrive/SunamoCollectionOnDrive/SunamoCollectionOnDrive.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionOnDrive\README.md; Description=A collection that maintains its content even in a permanent file; ApiNamespace=SunamoCollectionOnDrive}.Name)](https://www.nuget.org/packages/SunamoCollectionOnDrive)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionOnDrive)
- **API reference**: [../../api/SunamoCollectionOnDrive.html](../../api/SunamoCollectionOnDrive.html)

---
A .NET library providing a collection that automatically persists its content to a file on disk. Supports both simple string collections and custom types via a parser interface.

## Overview

SunamoCollectionOnDrive is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CollectionOnDrive** - A string collection that persists to a file on disk
- **CollectionOnDriveT\<T\>** - A generic collection for custom types implementing `IParserCollectionOnDrive`
- **CollectionOnDriveBase\<T\>** - Abstract base class with shared persistence logic
- **CollectionOnDriveArgs** - Configuration arguments for the collection

### Key Methods

- `Load()` - Loads the collection from disk
- `AddWithSave()` - Adds an item and saves to disk
- `AddWithoutSave()` - Adds an item without persisting
- `RemoveWithSave()` - Removes an item and saves to disk
- `RemoveAll()` - Clears the collection and the file
- `Save()` - Saves the current state to disk
- `Init()` - Initializes with configuration and optional file watching

## Installation

```bash
dotnet add package SunamoCollectionOnDrive
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoCollectionOnDrive
- **Target Frameworks**: net10.0; net9.0; net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

