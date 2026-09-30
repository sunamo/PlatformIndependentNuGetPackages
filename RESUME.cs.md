---
schema_version: 4
type: library
file_count: 1567
delete_recommendation_percent: 2
generated_date: 2026-09-30
generated_time: 16:46:11
github_origin: no
github_source_url: 
---

## Description

Sbírka sdílených NuGet balíčků `Sunamo*` pro všechny aplikace a zařízení. Rodičovské repo drží asi 155 balíčků jako git submoduly, sady `.net48` projektů, skripty pro správu řešení, dokumentaci (DocFX a MkDocs publikované přes GitHub Actions) a pomocné dávkové soubory. Samotný kód balíčků žije v submodulech, ne přímo v tomto repu.

## Původ zdrojáků

Staženo z GitHubu: **ne** — vlastní knihovny uživatele, repo patří účtu `sunamo` (GitHub) a `.gitmodules` míří z 151 submodulů na `git@github.com:sunamo/...` a ze 4 (SunamoComgate, SunamoPayments, SunamoTesseract, SunamoYt) na vlastní Azure DevOps `sunamocz`.

- Ověřeno: `git remote -v` (`git@github.com:sunamo/PlatformIndependentNuGetPackages.git`, vlastní účet), `git log` (2691 commitů od 2024-07-10, autoři Radek Jancik/Radek Jančík/smutekutek/sunamo.cz), `.gitmodules` (155 submodulů: 151 z `github.com:sunamo`, 4 z Azure DevOps `sunamocz`).
- `gh search repos "PlatformIndependentNuGetPackages"` vrátil jen vlastní repa `sunamo/*` (SunamoDevCodeCore, SunamoToNetCore, SunamoCodeGenerator, SunamoMsBuild, SunamoCSharp, SunamoSolutionsIndexer), žádné cizí; hash porovnání proto nebylo potřeba.

## Doporučení ke smazání

Doporučení ke smazání: **2 %** — nemazat, je to centrální sbírka sdílených knihoven, na které stojí ostatní projekty.

- Aktivní (poslední commity 2026-09-30) a s dlouhou historií (2691 commitů).
- Odkazují na něj submoduly i konzumující aplikace.
- V rootu jsou dočasné soubory (build výstupy, dávky `_batches`, `_modernized_done`, skripty), které by šlo uklidit, ale nejsou důvodem k mazání.
