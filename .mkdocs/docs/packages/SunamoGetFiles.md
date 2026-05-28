# SunamoGetFiles

Retrieving files with automatic exception catching and further processing after

- **NuGet**: [$(@{Name=SunamoGetFiles; CsprojRel=SunamoGetFiles/SunamoGetFiles/SunamoGetFiles.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoGetFiles\README.md; Description=Retrieving files with automatic exception catching and further processing after; ApiNamespace=SunamoGetFiles}.Name)](https://www.nuget.org/packages/SunamoGetFiles)
- **Source**: [GitHub](https://github.com/sunamo/SunamoGetFiles)
- **API reference**: [../../api/SunamoGetFiles.html](../../api/SunamoGetFiles.html)

---
A .NET library for retrieving files from the file system with automatic exception handling, recursive folder traversal, progress bar support, and flexible filtering options.

## Overview

SunamoGetFiles is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It wraps `Directory.GetFiles` with robust error handling, folder-level filtering, and progress reporting.

## Main Components

### Key Classes

- **FSGetFiles** - Main static class with file retrieval methods
- **GetFilesEveryFolderArgs** - Configuration object for controlling search behavior (filtering, progress bars, sorting, exclusions)

### Key Methods

- `GetFilesEveryFolder()` - Recursively gets files from all subfolders with error handling per folder
- `GetFilesAsync()` - Asynchronous file retrieval with semicolon-delimited multi-folder support
- `GetFilesSizes()` - Gets file sizes in bytes for a list of files
- `GetFilesSize()` - Gets total size of files in human-readable format (auto-selects B/KB/MB/GB/TB)
- `FilesOfExtension()` / `FilesOfExtensions()` - Gets files filtered by extension(s)
- `FilesOfExtensionsArray()` - Gets files matching any of specified extensions
- `AllFilesInFolders()` - Gets files from multiple folders with multiple extensions
- `FilesWhichContainsAll()` - Finds files whose content contains all specified strings
- `GetFilesWithContentInDictionary()` - Returns files with their content as key-value pairs
- `FilterByGetFilesArgs()` - Applies filter settings from args to an existing file list

## Installation

```bash
dotnet add package SunamoGetFiles
```

## Dependencies

- **Microsoft.Extensions.Logging** (v10.0.2)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoGetFiles
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the [main repository](https://github.com/sunamo/PlatformIndependentNuGetPackages).

## License

MIT - See the repository root for license information.

