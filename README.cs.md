# PlatformIndependentNuGetPackages

## Short description

Sbírka sdílených NuGet balíčků `Sunamo*` pro všechny aplikace a zařízení. Rodičovské repo drží asi 155 balíčků jako git submoduly, sady `.net48` projektů, skripty pro správu řešení, dokumentaci (DocFX a MkDocs publikované přes GitHub Actions) a pomocné dávkové soubory. Samotný kód balíčků žije v submodulech, ne přímo v tomto repu.

My shared libraries for all apps &amp; devices

## Dokumentace online

- API dokumentace všech balíčků (DocFX): https://sunamo.github.io/PlatformIndependentNuGetPackages/
- Návody a poznámky k balíčkům (MkDocs): https://sunamo.github.io/PlatformIndependentNuGetPackages/guide/
- Web se po každém pushi na `master` sestaví workflow `.github/workflows/docfx-pages.yml`.
