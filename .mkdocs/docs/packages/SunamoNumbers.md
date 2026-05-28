# SunamoNumbers

Generating, calculating with numbers

- **NuGet**: [$(@{Name=SunamoNumbers; CsprojRel=SunamoNumbers/SunamoNumbers/SunamoNumbers.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoNumbers\README.md; Description=Generating, calculating with numbers; ApiNamespace=SunamoNumbers}.Name)](https://www.nuget.org/packages/SunamoNumbers)
- **Source**: [GitHub](https://github.com/sunamo/SunamoNumbers)
- **API reference**: [../../api/SunamoNumbers.html](../../api/SunamoNumbers.html)

---
A platform-independent .NET library for numeric operations including statistical calculations, number normalization, interval parsing, and mathematical utilities.

## Features

- **Statistical Calculations**: Median, average, min/max computations with `NH` (Number Helper)
- **Interval Parsing**: Parse numeric intervals and single values from strings with `NumberService`
- **Number Normalization**: Convert signed numeric types to unsigned equivalents with `NormalizeNumbers`
- **Math Utilities**: Highest Common Factor (HCF) and Lowest Common Factor (LCF) with `MH`
- **Range Generation**: Generate sequential number lists and intervals with `LinearHelper`
- **Value Tracking**: Track minimum/maximum values with `LowHighHelper`

## Installation

```bash
dotnet add package SunamoNumbers
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Projects

| Project | Description |
|---|---|
| SunamoNumbers | Main library with number utilities |
| SunamoNumbers.Tests | Unit tests using xUnit |
| RunnerNumbers | Console runner for manual test execution |

## License

MIT

