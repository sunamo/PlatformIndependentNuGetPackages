# SunamoAsync

Run async code as sync and vice versa

- **NuGet**: [$(@{Name=SunamoAsync; CsprojRel=SunamoAsync/SunamoAsync/SunamoAsync.csproj; ReadmePath=E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoAsync\README.md; Description=Run async code as sync and vice versa; ApiNamespace=SunamoAsync}.Name)](https://www.nuget.org/packages/SunamoAsync)
- **Source**: [GitHub](https://github.com/sunamo/SunamoAsync)
- **API reference**: [../../api/SunamoAsync.html](../../api/SunamoAsync.html)

---
Run async code synchronously and invoke async/sync actions uniformly.

## Overview

SunamoAsync is part of the Sunamo package ecosystem, providing a lightweight helper for running async methods synchronously in .NET. It uses a custom `SynchronizationContext` to safely block on async code without deadlocks.

## Main Components

### AsyncHelper

Singleton class (`AsyncHelper.Instance`) with the following public API:

- `InvokeFuncTaskOrAction(object actionOrFunc)` - Invokes either an `Action` or a `Func<Task>` uniformly.
- `GetResult<T>(Task<T> task)` - Gets the result of a typed task synchronously.
- `GetResult(Task task)` - Awaits a task synchronously.
- `RunAsync(Task task)` - Runs a task asynchronously.
- `RunSync<T, T1>(Func<T1, T> task, T1 argument1)` - Executes a function with one parameter synchronously.
- `RunSync<T, T1, T2>(...)` - Executes a function with two parameters synchronously.
- `RunSync<T, T1, T2, T3>(...)` - Executes a function with three parameters synchronously.
- `RunSyncWithoutReturnValue(Func<Task> task)` - Executes an async method synchronously without return value.
- `RunSyncWithoutReturnValue<T1>(...)` - With one parameter.
- `RunSyncWithoutReturnValue<T1, T2>(...)` - With two parameters.
- `RunSyncWithoutReturnValue<T1, T2, T3>(...)` - With three parameters.

## Installation

```bash
dotnet add package SunamoAsync
```

## Dependencies

- **Microsoft.Extensions.Logging.Abstractions** (v10.0.2)

## Package Information

- **Target Frameworks**: net10.0, net9.0, net8.0
- **License**: MIT

## Related Packages

This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.

## License

MIT - See the repository root for license information.

