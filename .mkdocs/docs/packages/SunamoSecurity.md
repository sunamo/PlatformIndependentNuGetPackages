# SunamoSecurity

Helpers for SecureString, ProtectedData and more

- **NuGet**: [$(@{Name=SunamoSecurity; CsprojRel=SunamoSecurity/SunamoSecurity/SunamoSecurity.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoSecurity\README.md; Description=Helpers for SecureString, ProtectedData and more; ApiNamespace=SunamoSecurity}.Name)](https://www.nuget.org/packages/SunamoSecurity)
- **Source**: [GitHub](https://github.com/sunamo/SunamoSecurity)
- **API reference**: [../../api/SunamoSecurity.html](../../api/SunamoSecurity.html)

---
Helpers for SecureString, ProtectedData and more

## Overview

SunamoSecurity is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **CryptDelegates** - Holds delegate references for string encryption and decryption operations.
- **ProtectedDataHelper** - Encrypts and decrypts strings using the Windows Data Protection API (DPAPI).
- **SecureStringHelper** - Converts between SecureString and regular strings, with convenience encryption methods.

### Key Methods

- `SecureStringHelper.ToSecureString()` - Extension method to convert a string to SecureString
- `SecureStringHelper.ToSecureString2()` - Converts a string to a read-only SecureString character by character
- `SecureStringHelper.ToInsecureString()` - Converts a SecureString back to a regular string via Unicode allocation
- `SecureStringHelper.ToInsecureString2()` - Converts a SecureString back to a regular string via BSTR marshalling
- `SecureStringHelper.EncryptString()` - Encrypts a plain text string using DPAPI
- `SecureStringHelper.DecryptString()` - Decrypts an encrypted string using DPAPI
- `SecureStringHelper.CreateCryptDelegates()` - Creates a CryptDelegates instance with default encrypt/decrypt methods
- `ProtectedDataHelper.EncryptString()` - Encrypts a SecureString using DPAPI with salt
- `ProtectedDataHelper.DecryptString()` - Decrypts a Base64-encoded string using DPAPI with salt

## Installation

```bash
dotnet add package SunamoSecurity
```

## Dependencies

- **System.Security.Cryptography.ProtectedData** (v10.0.2)
- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Package Name**: SunamoSecurity
- **Version**: 26.2.7.2
- **Target Frameworks**: net10.0;net9.0;net8.0
- **Category**: Platform-Independent NuGet Package
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

