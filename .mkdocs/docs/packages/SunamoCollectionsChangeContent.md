# SunamoCollectionsChangeContent

Method for change content across whole collection

- **NuGet**: [$(@{Name=SunamoCollectionsChangeContent; CsprojRel=SunamoCollectionsChangeContent/SunamoCollectionsChangeContent/SunamoCollectionsChangeContent.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCollectionsChangeContent\README.md; Description=Method for change content across whole collection; ApiNamespace=SunamoCollectionsChangeContent}.Name)](https://www.nuget.org/packages/SunamoCollectionsChangeContent)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCollectionsChangeContent)
- **API reference**: [../../api/SunamoCollectionsChangeContent.html](../../api/SunamoCollectionsChangeContent.html)

---
Methods for changing content across an entire collection of strings using custom transformation functions.

## Overview

SunamoCollectionsChangeContent is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It allows you to apply transformation functions to every element in a `List<string?>`, with support for conditional transformation, multiple arguments, and automatic null/empty removal.

## Main Components

### Key Classes

- **CAChangeContent** - Static class with methods for transforming string collections.
- **ChangeContentArgs** - Configuration class controlling null/empty removal and argument switching behavior.

### Key Methods

- `ChangeContent0()` - Applies a `Func<string?, string?>` to each element.
- `ChangeContent1<T>()` - Applies a transformation with one additional argument.
- `ChangeContent2<T, U>()` - Applies a transformation with two additional arguments.
- `ChangeContentWithCondition()` - Applies a transformation only to elements matching a predicate.
- `ChangeContentSwitch12<TArg>()` - Applies a transformation with switched parameter order.

## Installation

```bash
dotnet add package SunamoCollectionsChangeContent
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoCollectionsChangeContent
- **Version**: 26.4.7.5
- **Target Frameworks**: net10.0; net9.0; net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

