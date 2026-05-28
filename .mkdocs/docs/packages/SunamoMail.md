# SunamoMail

Sending mail with several providers (Seznam.cz, Gmail, etc.)

- **NuGet**: [$(@{Name=SunamoMail; CsprojRel=SunamoMail/SunamoMail/SunamoMail.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoMail\README.md; Description=Sending mail with several providers (Seznam.cz, Gmail, etc.); ApiNamespace=SunamoMail}.Name)](https://www.nuget.org/packages/SunamoMail)
- **Source**: [GitHub](https://github.com/sunamo/SunamoMail)
- **API reference**: [../../api/SunamoMail.html](../../api/SunamoMail.html)

---
Sending mail with several providers (Seznam.cz, Gmail, etc.)

## Overview

SunamoMail is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **SmtpServerData**
- **GoogleAppsMailbox**
- **MailBox**
- **SeznamMailbox**

### Key Methods

- `Gmail()`
- `SeznamCz()`
- `SendEmail()`
- `SendCentrum()`
- `SendSeznam()`
- `SendSeznamMailkitWorker()`

## Installation

```bash
dotnet add package SunamoMail
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)
- **MailKit** (v4.11.0)
- **Microsoft.Extensions.Logging** (v9.0.3)
- **MimeKit** (v4.11.0)

## Package Information

- **Package Name**: SunamoMail
- **Version**: 25.6.9.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 13

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

