# SunamoCollectionsValuesTableGrid

Export to DataTable, flipping rows into columns and vice versa, checking if all
      rows / columns have the same value. Generic.

- **NuGet**: [$(@{Name=SunamoCollectionsValuesTableGrid; CsprojRel=SunamoCollectionsValuesTableGrid/SunamoCollectionsValuesTableGrid/SunamoCollectionsValuesTableGrid.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionsValuesTableGrid\README.md; Description=Export to DataTable, flipping rows into columns and vice versa, checking if all
      rows / columns have the same value. Generic.; ApiNamespace=SunamoCollectionsValuesTableGrid}.Name)](https://www.nuget.org/packages/SunamoCollectionsValuesTableGrid)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionsValuesTableGrid)
- **API reference**: [../../api/SunamoCollectionsValuesTableGrid.html](../../api/SunamoCollectionsValuesTableGrid.html)

---
A generic two-dimensional table grid for .NET that allows querying parallel collections as one. Supports exporting to `DataTable`, transposing rows into columns and vice versa, and checking if all rows or columns contain the same value.

## Overview

SunamoCollectionsValuesTableGrid is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **ValuesTableGrid&lt;T&gt;** — generic table grid inheriting from `List<List<T>>`

### Key Methods

- `SwitchRowsAndColumn()` — transposes the grid into a DataTable
- `ToDataTable()` — converts the grid to a DataTable with captions
- `IsAllInColumn()` — checks if all elements in a column equal a value
- `IsAllInRow()` — checks if all elements in a row equal a value

## Installation

```bash
dotnet add package SunamoCollectionsValuesTableGrid
```

## Target Frameworks

`net10.0`, `net9.0`, `net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Package Information

- **Package Name**: SunamoCollectionsValuesTableGrid
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT

