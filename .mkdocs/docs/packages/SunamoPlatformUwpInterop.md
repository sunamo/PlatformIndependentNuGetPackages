# SunamoPlatformUwpInterop

One of base foundation for sunamo's app platform - second is SunamoThisApp

- **NuGet**: [$(@{Name=SunamoPlatformUwpInterop; CsprojRel=SunamoPlatformUwpInterop/SunamoPlatformUwpInterop/SunamoPlatformUwpInterop.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoPlatformUwpInterop\README.md; Description=One of base foundation for sunamo's app platform - second is SunamoThisApp; ApiNamespace=SunamoPlatformUwpInterop}.Name)](https://www.nuget.org/packages/SunamoPlatformUwpInterop)
- **Source**: [GitHub](https://github.com/sunamo/SunamoPlatformUwpInterop)
- **API reference**: [../../api/SunamoPlatformUwpInterop.html](../../api/SunamoPlatformUwpInterop.html)

---
One of the base foundations for the Sunamo app platform - the second is SunamoThisApp.

## Overview

SunamoPlatformUwpInterop is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It handles application data management, settings persistence, and folder structure creation for desktop and UWP applications.

## Main Components

### Key Classes

- **AppData** - Singleton providing application data management (folder creation, settings read/write)
- **AppDataMethods** - Convenience methods for accessing Data and Settings folders
- **CachedSettings** - Caching layer for common settings values
- **CreateAppFoldersIfDontExistsArgs** - Arguments for initializing application folders and loading settings
- **SpecialFoldersHelper** - Helper for accessing special system folders (AppData/Roaming)

### Key Methods

- `CreateAppFoldersIfDontExists()` - Initializes all application folders and loads settings
- `GetFile()` / `GetFileString()` - Gets file paths within application folders
- `GetFolder()` - Gets application folder paths
- `GetRootFolder()` - Gets or creates the root folder for an application
- `SaveFileOfSettings()` / `ReadFileOfSettings*()` - Persists and reads settings values
- `GetCommonSettings()` / `SetCommonSettings()` - Manages encrypted common settings
- `GetFolderWithAppsFiles()` - Gets the configuration file path for app folder locations

## Installation

```bash
dotnet add package SunamoPlatformUwpInterop
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoPlatformUwpInterop
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

