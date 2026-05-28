# SunamoYouTube

Working with YouTube

- **NuGet**: [$(@{Name=SunamoYouTube; CsprojRel=SunamoYouTube/SunamoYouTube/SunamoYouTube.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoYouTube\README.md; Description=Working with YouTube; ApiNamespace=SunamoYouTube}.Name)](https://www.nuget.org/packages/SunamoYouTube)
- **Source**: [GitHub](https://github.com/sunamo/SunamoYouTube)
- **API reference**: [../../api/SunamoYouTube.html](../../api/SunamoYouTube.html)

---
A .NET library for working with the YouTube Data API v3 - creating playlists and managing video codes.

## Overview

SunamoYouTube is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **YouTubeHelper** - Static helper for YouTube API operations (playlist creation, video code extraction from URIs).

### Key Methods

- `GetYtCodesFromUri()` - Extracts YouTube video codes from a list of URIs.
- `CreateNewPlaylist()` - Creates a new public YouTube playlist and adds videos to it.

## Installation

```bash
dotnet add package SunamoYouTube
```

## Dependencies

- **Google.Apis.YouTube.v3** (v1.73.0.4029)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoYouTube
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

