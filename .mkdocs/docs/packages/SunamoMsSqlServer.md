# SunamoMsSqlServer

Helpers and services for MS Sql Server

- **NuGet**: [$(@{Name=SunamoMsSqlServer; CsprojRel=SunamoMsSqlServer/SunamoMsSqlServer/SunamoMsSqlServer.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoMsSqlServer\README.md; Description=Helpers and services for MS Sql Server; ApiNamespace=SunamoMsSqlServer.Helpers}.Name)](https://www.nuget.org/packages/SunamoMsSqlServer)
- **Source**: [GitHub](https://github.com/sunamo/SunamoMsSqlServer)
- **API reference**: [../../api/SunamoMsSqlServer.Helpers.html](../../api/SunamoMsSqlServer.Helpers.html)

---
Helpers and services for MS SQL Server.

## Overview

SunamoMsSqlServer is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It offers helper classes and services for managing SQL Server connections, executing queries, and handling identity inserts using Entity Framework Core.

## Main Components

### Helpers

- **IdentityHelpers** - Extension methods for managing SQL Server IDENTITY_INSERT on Entity Framework Core DbContext
- **MsSqlConnectHelper** - Helper methods for opening and closing SQL Server connections

### Services

- **MsSqlService** - Core service for managing MS SQL Server connections and executing database operations
- **MsSqlOneColumnService** - Service for reading single-column data from MS SQL Server tables
- **UniqueIdService** - Service for managing unique ID generation and identity insert permissions

### Data Types

- **ResultWithExceptionMsSqlServer\<T\>** - Wrapper for result values or exception messages from MS SQL Server operations

## Installation

```bash
dotnet add package SunamoMsSqlServer
```

## Dependencies

- **Microsoft.Data.SqlClient** (v6.1.4)
- **Microsoft.EntityFrameworkCore** (v9.0.1)
- **Microsoft.EntityFrameworkCore.Relational** (v9.0.1)
- **Microsoft.Extensions.Logging.Abstractions** (latest compatible)

## Target Frameworks

### Main Library (SunamoMsSqlServer.csproj)
- **Target Frameworks**: net10.0, net9.0, net8.0
- **Reason**: NuGet packages must support multiple .NET versions for broad compatibility

### Test & Runner Projects
- **Target Framework**: net10.0 only
- **Reason**: Test and runner projects don't need multi-targeting. Using only the latest .NET version simplifies dependency management.

## License

MIT

