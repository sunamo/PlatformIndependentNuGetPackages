# SunamoCollectionsGeneric

Working with generic collections

- **NuGet**: [$(@{Name=SunamoCollectionsGeneric; CsprojRel=SunamoCollectionsGeneric/SunamoCollectionsGeneric/SunamoCollectionsGeneric.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionsGeneric\README.md; Description=Working with generic collections; ApiNamespace=SunamoCollectionsGeneric}.Name)](https://www.nuget.org/packages/SunamoCollectionsGeneric)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionsGeneric)
- **API reference**: [../../api/SunamoCollectionsGeneric.html](../../api/SunamoCollectionsGeneric.html)

---
Working with generic collections.

## Overview

SunamoCollectionsGeneric is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It offers a variety of collection types and helper methods for working with generic collections.

## Main Components

### Key Classes

- **CAG** - Collection helper class providing utility methods (compare, deduplicate, convert arrays)
- **CAGConsts** - Constants and basic utility methods for collections
- **BadGoodCollection** - Collection that categorizes items into Bad and Good lists
- **CollectionToEnd** - Collection that appends items to the end
- **CycleGenerator** - Generator that cycles through items, returning to start after reaching the end
- **CyclingCollection** - Collection supporting forward/backward cycling navigation
- **D** - Dictionary with debugging capabilities and enumerable support
- **DictionarySort** - Helper for sorting dictionaries by keys or values
- **DictionaryWithList** - Dictionary backed by a list for maintaining insertion order
- **Joiner** - Helper for building strings by joining items with a separator
- **L** - Extended List with change tracking and default value support
- **ResolvedDictionary** - Dictionary that resolves values using a function when key is not found
- **SafeStringCollection** - String collection that replaces unallowed characters
- **SunamoDictionarySort** - Dictionary with built-in sorting capabilities
- **SunamoHashSetWithoutDuplicates** - HashSet that tracks and reports duplicates
- **UniqueTableInWhole** - Table with uniqueness constraints on rows/columns

### Key Methods

- `CAG.CompareList()` - Compare two lists and find common/unique elements
- `CAG.CompareListSanitizeStringOutput()` - Compare lists with formatted output
- `CAG.RemoveDuplicitiesList()` - Remove duplicates from a list
- `CAG.EqualRanges()` - Find matching ranges in a list
- `CyclingCollection.Next()` / `Before()` - Navigate through collection
- `CyclingCollection.SetIteration()` - Set current position
- `DictionarySort.SortByKeysDesc()` / `SortByValuesDesc()` - Sort dictionaries

## Installation

```bash
dotnet add package SunamoCollectionsGeneric
```

## Target Frameworks

`net10.0`, `net9.0`, `net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## License

MIT

