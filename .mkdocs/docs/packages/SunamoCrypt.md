# SunamoCrypt

Crypting with various crypting algorithms (Rijndael, Triple DES etc.)

- **NuGet**: [$(@{Name=SunamoCrypt; CsprojRel=SunamoCrypt/SunamoCrypt/SunamoCrypt.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoCrypt\README.md; Description=Crypting with various crypting algorithms (Rijndael, Triple DES etc.); ApiNamespace=SunamoCrypt}.Name)](https://www.nuget.org/packages/SunamoCrypt)
- **Source**: [GitHub](https://github.com/sunamo/SunamoCrypt)
- **API reference**: [../../api/SunamoCrypt.html](../../api/SunamoCrypt.html)

---
Crypting with various crypting algorithms (Rijndael, Triple DES etc.)

## Overview

SunamoCrypt is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.

## Main Components

### Key Classes

- **BTS2**
- **CryptHelper**
- **RijndaelBytes**
- **Rijndael**
- **TripleDES**
- **RC2**
- **RijndaelString**
- **CryptHelper2**
- **IV**
- **CryptData**

### Key Methods

- `ConvertFromUtf8ToBytes()`
- `ConvertFromBytesToUtf8()`
- `ClearEndingsBytes()`
- `Decrypt()`
- `Encrypt()`
- `ApplyCryptData()`
- `EncryptRSA()`
- `DecryptRSA()`
- `GetRSAParametersFromXml()`
- `EncryptTripleDES()`

## Installation

```bash
dotnet add package SunamoCrypt
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v9.0.3)

## Package Information

- **Package Name**: SunamoCrypt
- **Version**: 25.6.7.1
- **Target Framework**: net9.0
- **Category**: Platform-Independent NuGet Package
- **Source Files**: 15

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

See the repository root for license information.

