# SunamoRoslyn

Work with Roslyn platform

- **NuGet**: [$(@{Name=SunamoRoslyn; CsprojRel=SunamoRoslyn/SunamoRoslyn/SunamoRoslyn.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoRoslyn\README.md; Description=Work with Roslyn platform; ApiNamespace=SunamoRoslyn}.Name)](https://www.nuget.org/packages/SunamoRoslyn)
- **Source**: [GitHub](https://github.com/sunamo/SunamoRoslyn)
- **API reference**: [../../api/SunamoRoslyn.html](../../api/SunamoRoslyn.html)

---
Work with Roslyn platform - provides utilities for C# code analysis, parsing, formatting, and manipulation using Microsoft Roslyn.

## Overview

SunamoRoslyn is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It wraps the Microsoft Roslyn APIs to simplify common code analysis tasks like finding methods, parsing variables, formatting code, and removing comments.

## Main Components

### Key Classes

- **ChildNodes** - Navigate syntax tree child nodes (methods, fields, variables, namespaces, classes)
- **RoslynHelper** - Core helper for syntax tree operations (find nodes, replace nodes, get class declarations)
- **RoslynParser** - Parse C# code using Roslyn (extract variables, check if text is valid C#)
- **RoslynParserText** - Text-based code analysis without full Roslyn parsing
- **RoslynCommentService** - Remove all types of comments from C# code
- **RoslynFormatService** - Format C# code using Roslyn formatter
- **SourceCodeIndexerRoslyn** - Index source code files for fast searching and element lookup
- **RoslynAnalyzer** - Roslyn diagnostic analyzer
- **RoslynCodeFixProvider** - Code fix provider for Roslyn diagnostics

### Data Models

- **CodeElement\<T\>** - Base class for code elements with name, type, location
- **ClassCodeElement** - Represents a class-level code element (method)
- **NamespaceCodeElement** - Represents a namespace-level code element (class, enum, interface, struct)
- **CodeElements** - Container for namespace and class code elements
- **SourceFileTree** - Holds syntax tree and root for a source file
- **FoundedCodeElement** - Represents a found code element with line and position

### Key Methods

- `ChildNodes.Methods()` - Get method declarations from a syntax node
- `ChildNodes.MethodsDescendant()` - Get all method declarations recursively
- `ChildNodes.FieldsDescendant()` - Get all field declarations recursively
- `ChildNodes.VariablesDescendant()` - Get all variable declarations recursively
- `RoslynHelper.GetClass()` - Get the class declaration from a syntax root
- `RoslynHelper.FindNode()` - Find a specific node within a parent node
- `RoslynParser.ParseVariables()` - Extract declared and assigned variables
- `RoslynCommentService.RemoveComments()` - Remove all comments from C# code

## Installation

```bash
dotnet add package SunamoRoslyn
```

## Target Frameworks

- net10.0
- net9.0
- net8.0

## Dependencies

- **Microsoft.CodeAnalysis** (v5.0.0)
- **Microsoft.CodeAnalysis.CSharp** (v5.0.0)
- **Microsoft.CodeAnalysis.CSharp.Scripting** (v5.0.0)
- **Microsoft.CodeAnalysis.CSharp.Workspaces** (v5.0.0)
- **Microsoft.CodeAnalysis.Workspaces.MSBuild** (v5.0.0)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoRoslyn
- **Version**: 26.2.7.2
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

