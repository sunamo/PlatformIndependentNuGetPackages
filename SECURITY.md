# Security policy

## Reporting a vulnerability

Please do not open a public issue for a security problem.
Send the details to radek@sunamo.cz, including the package name, the version and steps to reproduce.

You will get an answer within a few days.
A fixed version is published as a new package version; older versions are not patched.

## Supported versions

Only the latest published version of each package is supported.

## Dependency checks

`.scripts/scan-vulnerable-packages.py` checks the direct NuGet dependencies of every package against the NuGet vulnerability data.
The same check runs in the pull request workflow.
