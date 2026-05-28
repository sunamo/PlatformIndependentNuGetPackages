# SunamoPInvoke

Interop with classic WinAPI

- **NuGet**: [$(@{Name=SunamoPInvoke; CsprojRel=SunamoPInvoke/SunamoPInvoke/SunamoPInvoke.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoPInvoke\README.md; Description=Interop with classic WinAPI; ApiNamespace=SunamoPInvoke.Args}.Name)](https://www.nuget.org/packages/SunamoPInvoke)
- **Source**: [GitHub](https://github.com/sunamo/SunamoPInvoke)
- **API reference**: [../../api/SunamoPInvoke.Args.html](../../api/SunamoPInvoke.Args.html)

---
P/Invoke wrapper library for Windows API (WinAPI) interop in .NET.

## Overview

SunamoPInvoke provides managed wrappers and P/Invoke declarations for common Windows API functions, including:

- **Global keyboard hooks** - system-wide keyboard event capture
- **File operations** - recycle bin integration via Shell API
- **Clipboard** - clipboard monitoring and management
- **Process management** - process token manipulation, impersonation
- **Shell icons** - file/folder icon extraction constants
- **Known folders** - GUID-based known folder path retrieval

## Main Components

### Classes

- **W32** - Core P/Invoke declarations for kernel32, user32, shell32, advapi32, gdi32, and psapi
- **GlobalKeyboardHook** - System-wide keyboard hook with event-based API
- **FileOperationAPIWrapper** - Shell file operations (recycle bin, silent delete)
- **KeysCatcher** - Key state detection utilities
- **IconExtractor** - Shell icon extraction constants
- **KnownFoldersGuid** - Well-known Windows folder GUIDs
- **User32** - User32.dll icon destruction function

### Structs

- **LowLevelKeyboardInputEvent** - Low-level keyboard input event data
- **SHFILEINFO** - Shell file information
- **STARTUPINFO** - Process startup information
- **PROCESS_INFORMATION** - Created process information
- **LUID** / **LUID_AND_ATTRIBUTES** / **TOKEN_PRIVILEGES** - Security token structures
- **BY_HANDLE_FILE_INFORMATION** - File information by handle

### Enums

- **FolderType** - Folder icon visual state (open/closed)
- **IconSize** - Shell icon size (large/small)
- **ProcessAccessFlags** - Process access rights
- **SECURITY_IMPERSONATION_LEVEL** - Token impersonation levels
- **TOKEN_TYPE** - Security token types

## Installation

```bash
dotnet add package SunamoPInvoke
```

## Target Frameworks

- .NET 10.0
- .NET 9.0
- .NET 8.0

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions**

## License

MIT - See the repository root for license information.

