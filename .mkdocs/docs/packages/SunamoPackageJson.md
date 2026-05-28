# SunamoPackageJson

Read and generating package.json

- **NuGet**: [$(@{Name=SunamoPackageJson; CsprojRel=SunamoPackageJson/SunamoPackageJson/SunamoPackageJson.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoPackageJson\README.md; Description=Read and generating package.json; ApiNamespace=SunamoPackageJson}.Name)](https://www.nuget.org/packages/SunamoPackageJson)
- **Source**: [GitHub](https://github.com/sunamo/SunamoPackageJson)
- **API reference**: [../../api/SunamoPackageJson.html](../../api/SunamoPackageJson.html)

---
A .NET library for reading and generating package.json files.

## Overview

SunamoPackageJson is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **Dependency** - Represents a single package dependency with a key (package name) and value (version).
- **PackageJson** - Data model for the package.json structure (dependencies, devDependencies, scripts, version, etc.).
- **PackageJsonHelper** - Utility methods for parsing package.json files and categorizing packages by version.

### Key Methods

- `PackageJson.GetVersionFromDepsOrDevDeps(packageName)` - Looks up a package version in dependencies or devDependencies.
- `PackageJsonHelper.Parse(json)` - Parses a JSON string into a PackageJson object.
- `PackageJsonHelper.CategorizeByFirstNumberOfPackage(folder, packageName)` - Categorizes package.json files by major version of a given package.

## Installation

```bash
dotnet add package SunamoPackageJson
```

## Dependencies

- **Newtonsoft.Json** (v13.0.4)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoPackageJson
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

