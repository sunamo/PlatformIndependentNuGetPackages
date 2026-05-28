# SunamoAttributes

Shared attributes for packages

- **NuGet**: [$(@{Name=SunamoAttributes; CsprojRel=SunamoAttributes/SunamoAttributes/SunamoAttributes.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAttributes\README.md; Description=Shared attributes for packages; ApiNamespace=SunamoAttributes}.Name)](https://www.nuget.org/packages/SunamoAttributes)
- **Source**: [GitHub](https://github.com/sunamo/SunamoAttributes)
- **API reference**: [../../api/SunamoAttributes.html](../../api/SunamoAttributes.html)

---
Shared custom attributes for the Sunamo NuGet package ecosystem. Provides reusable attribute classes for serialization, mapping, validation, and deprecation marking in .NET applications.

## Included Attributes

- **DataMemberAttribute** - Specifies the name of a data member for serialization or mapping.
- **IgnoreAttribute** - Marks properties or fields to be ignored during processing or serialization.
- **InnerObjectAttribute** - Base attribute for marking inner object properties or fields.
- **MessageIfFailAttribute** - Specifies a custom error message displayed on validation or operation failure.
- **NotTranslateAttribute** - Marks strings or properties that should not be translated.
- **ObjectObsoleteAttribute** - Marks methods as obsolete when accepting object parameters.
- **ObjectParamsAllowedAttribute** - Marks methods as intentionally accepting object params parameters.
- **ObjectParamsObsoleteAttribute** - Marks methods as obsolete when accepting object params parameters.
- **OuterObjectAttribute** - Marks outer object properties or classes.
- **OuterObjectMapping** - Represents mapping information for an outer object including primary key and property information.
- **PrimaryKeyAttribute** - Marks a property as a primary key identifier.
- **TParamsObsoleteAttribute** - Marks methods as obsolete when accepting generic type params parameters.

## Installation

```bash
dotnet add package SunamoAttributes
```

## Target Frameworks

`net10.0`, `net9.0`, `net8.0`

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## Links

- [NuGet](https://www.nuget.org/profiles/sunamo)
- [GitHub](https://github.com/sunamo/PlatformIndependentNuGetPackages)
- [Developer site](https://sunamo.cz)

## License

See the repository root for license information.

