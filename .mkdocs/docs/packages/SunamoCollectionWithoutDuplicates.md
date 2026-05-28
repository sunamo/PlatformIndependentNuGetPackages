# SunamoCollectionWithoutDuplicates

Collection which automatically make Distinct

- **NuGet**: [$(@{Name=SunamoCollectionWithoutDuplicates; CsprojRel=SunamoCollectionWithoutDuplicates/SunamoCollectionWithoutDuplicates/SunamoCollectionWithoutDuplicates.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionWithoutDuplicates\README.md; Description=Collection which automatically make Distinct; ApiNamespace=SunamoCollectionWithoutDuplicates}.Name)](https://www.nuget.org/packages/SunamoCollectionWithoutDuplicates)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionWithoutDuplicates)
- **API reference**: [../../api/SunamoCollectionWithoutDuplicates.html](../../api/SunamoCollectionWithoutDuplicates.html)

---
A .NET collection that automatically prevents duplicate items (automatic Distinct).

## Overview

SunamoCollectionWithoutDuplicates is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CollectionWithoutDuplicates&lt;T&gt;** - Collection with duplicate prevention, supports both normal and string-based comparison modes.
- **CollectionWithoutDuplicatesStringComparing&lt;T&gt;** - Collection that always compares items by their string representation.
- **CollectionWithoutDuplicatesIListT&lt;T&gt;** - Collection implementing `IList<T>` with duplicate prevention using default equality.

### Key Methods

- `Add()` - Adds an item if not already present.
- `AddWithIndex()` - Adds an item and returns its index.
- `AddRange()` - Adds multiple items, returns list of duplicates that were skipped.
- `Contains()` / `ContainsN()` - Checks if an item exists in the collection.
- `IndexOf()` - Returns the index of an item.
- `Insert()` - Inserts an item at a specific index.
- `RemoveAt()` - Removes an item at a specific index.
- `Clear()` - Removes all items.
- `CopyTo()` - Copies items to an array.

## Installation

```bash
dotnet add package SunamoCollectionWithoutDuplicates
```

## Target Frameworks

`net10.0;net9.0;net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

