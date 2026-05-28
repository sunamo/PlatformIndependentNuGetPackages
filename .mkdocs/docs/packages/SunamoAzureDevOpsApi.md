# SunamoAzureDevOpsApi

Utilities for working with Azure DevOps

- **NuGet**: [$(@{Name=SunamoAzureDevOpsApi; CsprojRel=SunamoAzureDevOpsApi/SunamoAzureDevOpsApi/SunamoAzureDevOpsApi.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAzureDevOpsApi\README.md; Description=Utilities for working with Azure DevOps; ApiNamespace=SunamoAzureDevOpsApi}.Name)](https://www.nuget.org/packages/SunamoAzureDevOpsApi)
- **Source**: [GitHub](https://github.com/sunamo/SunamoAzureDevOpsApi)
- **API reference**: [../../api/SunamoAzureDevOpsApi.html](../../api/SunamoAzureDevOpsApi.html)

---
Utilities for working with Azure DevOps API.

## Overview

SunamoAzureDevOpsApi is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development. It offers a client for connecting to Azure DevOps and a parser for generating git clone commands from API responses.

## Main Components

### AzureDevOpsApiClient

Client for interacting with Azure DevOps API. Connects using a Personal Access Token and retrieves repository information.

- `LoadRepositories()` - Loads list of repository names from an Azure DevOps organization.

### AzureDevOpsApiParser

Parser for Azure DevOps API JSON responses.

- `ParseRepositories(string jsonResponse, string cloneUrlTemplate)` - Parses a JSON response containing repositories and generates git clone commands using the provided URL template.

### Model Classes

- **Project** - Represents an Azure DevOps project with properties like Id, Name, Description, State, and Visibility.
- **Repositories** - Container for the repository list API response.
- **Value** - Represents an individual Azure DevOps repository with clone URLs, branch info, and project association.

## Installation

```bash
dotnet add package SunamoAzureDevOpsApi
```

## Target Frameworks

- net10.0
- net9.0
- net8.0

## Dependencies

- **Microsoft.TeamFoundationServer.Client** (v19.225.2)
- **Microsoft.VisualStudio.Services.Client** (v19.225.2)
- **Newtonsoft.Json** (v13.0.4)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## License

MIT - See the repository root for license information.

