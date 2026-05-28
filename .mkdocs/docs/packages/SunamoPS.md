# SunamoPS

Working with Powershell 7 - Invoking commands, return outputs etc.

- **NuGet**: [$(@{Name=SunamoPS; CsprojRel=SunamoPS/SunamoPS/SunamoPS.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoPS\README.md; Description=Working with Powershell 7 - Invoking commands, return outputs etc.; ApiNamespace=SunamoPS}.Name)](https://www.nuget.org/packages/SunamoPS)
- **Source**: [GitHub](https://github.com/sunamo/SunamoPS)
- **API reference**: [../../api/SunamoPS.html](../../api/SunamoPS.html)

---
A .NET library for working with PowerShell 7 — invoking commands, capturing output, parsing scripts, and running external processes.

## Overview

SunamoPS is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It wraps the PowerShell SDK to offer a clean API for executing PowerShell commands programmatically from C#.

## Key Features

- **Command Execution** — Run single or multiple PowerShell commands and capture structured output
- **Process Invocation** — Launch external processes (e.g., `git`, `wsl`) and capture stdout
- **Script Parsing** — Parse PowerShell `.ps1` files to extract function definitions
- **Command Building** — Fluent builder for constructing PowerShell scripts with cd, cmd /c, yt-dlp, etc.
- **Progress Tracking** — Event-based progress state for batch operations
- **Output Caching** — Optional JSON-based save/load of command output

## Main Components

| Class | Description |
|---|---|
| `PowershellRunner` | Core runner — executes commands, returns structured output |
| `PowershellRunnerString` | String-returning wrapper around PowershellRunner |
| `PowershellBuilder` | Fluent builder for constructing command scripts |
| `PowershellHelper` | Utilities — process listing, language detection, script parsing |
| `PowershellParser` | Parses command strings into parts respecting quoted sections |
| `PsOutput` | Base class for processing PSObject and ErrorRecord output |
| `PS` | Static utility for quick PowerShell command execution |

## Installation

```bash
dotnet add package SunamoPS
```

## Usage

```csharp
// Execute a single command
var output = await PowershellRunner.Instance.InvokeSingle("Get-Process");

// Execute a command in a specific folder
var gitStatus = await PowershellRunner.Instance.InvokeInFolder(@"C:\MyRepo", "git status");

// Run an external process
var result = await PowershellRunner.Instance.InvokeProcess("git", "status");

// Parse PowerShell script methods
var methods = PowershellHelper.ParseMethods(powershellCode);

// Build commands with the fluent builder
var builder = PowershellBuilder.Create(TextBuilderPS.Create);
builder.Cd(@"C:\MyRepo");
builder.AddRawLine("git status");
var commands = builder.ToList();
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- Microsoft.PowerShell.SDK
- Microsoft.Extensions.Logging.Abstractions
- Newtonsoft.Json
- SunamoToUnixLineEnding

## License

MIT — see the repository root for details.

