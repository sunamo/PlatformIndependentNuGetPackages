# SunamoGitConfig

Serializer and deserializer for .git config files

- **NuGet**: [$(@{Name=SunamoGitConfig; CsprojRel=SunamoGitConfig/SunamoGitConfig/SunamoGitConfig.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoGitConfig\README.md; Description=Serializer and deserializer for .git config files; ApiNamespace=SunamoGitConfig}.Name)](https://www.nuget.org/packages/SunamoGitConfig)
- **Source**: [GitHub](https://github.com/sunamo/SunamoGitConfig)
- **API reference**: [../../api/SunamoGitConfig.html](../../api/SunamoGitConfig.html)

---
Serializer and deserializer for .git config files

## Overview

SunamoGitConfig is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **BlockNames**
- **RemoteKeys**
- **ExistsNonExistsListGitConfig**
- **GitConfigSectionData**
- **GitConfigFileHelper**
- **GitConfigSectionParser**

### Key Methods

- `SetValue()`
- `GitConfigSectionData()`
- `Format()`
- `Save()`
- `Load()`
- `Parse()`
- `ParseBlocks()`
- `AddHeaderBlock()`
- `AddSettingsPair()`

## Installation

```bash
dotnet add package SunamoGitConfig
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)

## Package Information

- **Package Name**: SunamoGitConfig
- **Version**: 25.3.29.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 12

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

