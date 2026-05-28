# SunamoUnderscore

Static sharing data objects - for use only in my apps

- **NuGet**: [$(@{Name=SunamoUnderscore; CsprojRel=SunamoUnderscore/SunamoUnderscore/SunamoUnderscore.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoUnderscore\README.md; Description=Static sharing data objects - for use only in my apps; ApiNamespace=SunamoUnderscore}.Name)](https://www.nuget.org/packages/SunamoUnderscore)
- **Source**: [GitHub](https://github.com/sunamo/SunamoUnderscore)
- **API reference**: [../../api/SunamoUnderscore.html](../../api/SunamoUnderscore.html)

---
Static sharing data objects - for use only in my apps

## Overview

SunamoUnderscore is part of the Sunamo package ecosystem, providing global static shared data objects for cross-module communication in .NET applications.

## Main Components

### Key Classes and Interfaces

- **`_`** - Global static class holding shared references (database connections, OAuth configs, encryption functions)
- **`IDatabasesConnections`** - Interface for managing and switching database connections
- **`IOAuth`** - Common OAuth configuration interface for payment gateways
- **`IComgateOAuth`** - Comgate-specific OAuth configuration
- **`IGoPayOAuth`** - GoPay-specific OAuth configuration
- **`RadioButtonsSql`** - Represents SQL database radio button selection state
- **`Databases`** - Enum of available database connection targets

## Installation

```bash
dotnet add package SunamoUnderscore
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoUnderscore
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

