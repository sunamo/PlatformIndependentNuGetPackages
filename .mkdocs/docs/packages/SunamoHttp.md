# SunamoHttp

Caching files locally to limit HTTP requests

- **NuGet**: [$(@{Name=SunamoHttp; CsprojRel=SunamoHttp/SunamoHttp/SunamoHttp.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoHttp\README.md; Description=Caching files locally to limit HTTP requests; ApiNamespace=SunamoHttp}.Name)](https://www.nuget.org/packages/SunamoHttp)
- **Source**: [GitHub](https://github.com/sunamo/SunamoHttp)
- **API reference**: [../../api/SunamoHttp.html](../../api/SunamoHttp.html)

---
Caching files locally to limit HTTP requests

## Overview

SunamoHttp is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **DownloadOrReadArgs**
- **GetResponseArgs**
- **HttpRequestData**
- **HttpRequestDataHttp**
- **UploadFile**
- **HttpClientHelper**
- **HttpResponseHelper**

### Key Methods

- `GetResponseBytes()`
- `GetResponseText()`
- `GetResponseStream()`
- `DownloadOrReadWorker()`
- `DownloadOrRead()`
- `ExistsPage()`
- `IsNotFound()`
- `SomeError()`

## Installation

```bash
dotnet add package SunamoHttp
```

## Dependencies

- **Microsoft.AspNetCore.Http** (v2.3.0)
- **Microsoft.Extensions.Logging** (v9.0.3)
- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)
- **System.Text.Encodings.Web** (v9.0.3)

## Package Information

- **Package Name**: SunamoHttp
- **Version**: 25.6.7.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 34

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

