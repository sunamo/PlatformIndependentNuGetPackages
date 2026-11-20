# Contributing to PlatformIndependentNuGetPackages

Each package is a separate git repository included here as a submodule, so a change is committed in the package first and then the submodule pointer is updated here.

## Rules

- Code, comments and XML documentation are written in English only.
- Every public member has an XML documentation comment.
- Packages do not reference each other (only `Runner*` and `*.Tests` projects may); copy the needed code into `_sunamo/<Donor>/` instead.
- Every package name starts with `Sunamo` (except `Runner*`).
- Versions use the scheme `year.month.day.build`, for example `26.5.18.4`.
- Commit messages are English and follow `<type>: description` (for example `fix: handle empty input`).

## Before opening a pull request

1. Build and test the changed package: `dotnet test <Package>/<Package>.Tests`.
2. Run the rule checker: `python -I .scripts/check-rules.py .`.
3. Check dependencies for known vulnerabilities: `python -I .scripts/scan-vulnerable-packages.py .` (from the pinp root).

The pull request workflow repeats these checks for the changed packages.
