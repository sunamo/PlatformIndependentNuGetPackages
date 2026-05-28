# SunamoSelenium

Code base for easy work with Selenium

- **NuGet**: [$(@{Name=SunamoSelenium; CsprojRel=SunamoSelenium/SunamoSelenium/SunamoSelenium.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoSelenium\README.md; Description=Code base for easy work with Selenium; ApiNamespace=SunamoSelenium}.Name)](https://www.nuget.org/packages/SunamoSelenium)
- **Source**: [GitHub](https://github.com/sunamo/SunamoSelenium)
- **API reference**: [../../api/SunamoSelenium.html](../../api/SunamoSelenium.html)

---
A .NET library for simplified Selenium WebDriver initialization and management.

## Overview

SunamoSelenium is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It wraps common Selenium operations like driver initialization, page navigation, element waiting, and PowerShell output processing.

## Main Components

### Key Classes

- **SeleniumHelper** - Initializes Edge and Chrome WebDriver instances using built-in Selenium Manager for automatic driver download
- **SeleniumService** - Provides utility methods for waiting for page load and finding elements
- **SeleniumNavigateService** - Navigation with logging and page-ready waiting
- **CmpWorkaroundService** - Workaround for Consent Management Platform dialogs via Seznam.cz login
- **CloudFlareHumanVerifyService** - Handles CloudFlare human verification challenges
- **ByHelper** - Creates CSS selector locators from space-separated class names
- **PsOutput** - Processes PowerShell command output and error records
- **ExceptionsExtensions** - Recursively collects all exception messages
- **StringToUnixLineEndingExtensions** - Converts line endings to Unix format

## Installation

```bash
dotnet add package SunamoSelenium
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (latest compatible)
- **Microsoft.PowerShell.SDK** (v7.4.6)
- **Selenium.Support** (v4.40.0)
- **Selenium.WebDriver** (v4.40.0)
- **DotNetSeleniumExtras.WaitHelpers** (v3.11.0)
- **System.Management.Automation** (v7.4.6)

## Target Frameworks

### Main Library (SunamoSelenium.csproj)
- **Target Frameworks**: net10.0, net9.0, net8.0
- NuGet packages support multiple .NET versions for broad compatibility

### Test and Runner Projects
- **Target Framework**: net10.0 only
- Test and runner projects use only the latest .NET version to simplify dependency management

## Package Version Notes

### PowerShell and System.Management.Automation
- Uses version 7.4.6 because 7.5.4+ requires .NET 9+ only. Version 7.4.6 supports net8.0, net9.0, and net10.0.

### Microsoft.Extensions.Logging.Abstractions
- Uses wildcard version (*) to automatically get the latest compatible version and avoid dependency conflicts.

## License

MIT

