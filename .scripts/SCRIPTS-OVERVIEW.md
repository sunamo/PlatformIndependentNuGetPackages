# Scripts Overview

Přehled všech PowerShell skriptů v `.scripts/` složce projektu PlatformIndependentNuGetPackages.

## ⭐ Denně používané skripty

Nejčastěji používané skripty pro každodenní práci:

- **`get-target-frameworks-with-reasons.ps1`** - Zobrazí target frameworks s důvody odchylek
  - EN: Lists all projects with their target frameworks and explains deviations with reasons
  - CZ: Vypíše všechny projekty s jejich target frameworky a vysvětlí odchylky s důvody
  - Vylepšená verze get-target-frameworks.ps1 s detailními důvody

- **`check-group.ps1 -GroupNumber [-SkipBuild] [-SkipProgress]`** - Sloučená kontrola skupiny submodulů
  - EN: Unified submodule check - progress report + quality check (NoWarn, build) in one script
  - CZ: Sloučená kontrola submodulů - progress report + kvalita (NoWarn, build) v jednom skriptu
  - Parametry: `-GroupNumber` pro výběr skupiny, `-SkipBuild` přeskočí build, `-SkipProgress` přeskočí progress
  - Bez `-GroupNumber` generuje celkový report do `variable-renaming-progress.md`
  - Vytváří `submodules-quality-report.json`
  - Nahrazuje dřívější `generate-progress-report.ps1` a `check-submodules-quality.ps1`

- **`open-terminal-tabs.ps1 -GroupNumber`** - Otevře Windows Terminal s taby pro skupinu
  - EN: Opens pwsh tabs in Windows Terminal for all submodules in the specified group
  - CZ: Otevře pwsh taby ve Windows Terminal pro všechny submoduly v zadané skupině
  - Parametr: `-GroupNumber` pro výběr skupiny

- **`open-submodule-tabs.ps1 -SubmoduleName [-Count]`** - Otevře N tabů pro jeden submodul
  - EN: Opens N pwsh tabs in Windows Terminal for the specified submodule with Claude running
  - CZ: Otevře N pwsh tabů ve Windows Terminal pro zadaný submodul se spuštěným Claude
  - Parametry: `-SubmoduleName` (povinný), `-Count` (volitelný, default 10)

## 🔄 Ke třídění

Nově přidané skripty které zatím nejsou zařazené do kategorií:

- **`add-variables-ok-comment-grouped.ps1 [-GroupNumber]`** - Hromadné přidání "variables names: ok" komentáře
  - EN: Add "// variables names: ok" comment to all .cs files in specified group of submodules
  - CZ: Přidá "// variables names: ok" komentář do všech .cs souborů ve specifické skupině submodulů
  - Parametr: `-GroupNumber` (volitelný, 0 = všechny submoduly)

- **`find-empty-classes.ps1 [-Remove] [-DryRun]`** - Najde prázdné C# třídy
  - EN: Finds empty C# classes and optionally removes them
  - CZ: Najde prázdné C# třídy a volitelně je smaže
  - Parametry: `-Remove` (smaže soubory), `-DryRun` (default true)

- **`get-var-ok-stats.ps1 -SolutionDir`** - Statistiky "variables names: ok" komentářů
  - EN: Get statistics about "// variables names: ok" comments in solution
  - CZ: Získá statistiky o "// variables names: ok" komentářích v solution
  - Parametr: `-SolutionDir` (povinný) - cesta k solution adresáři

- **`group-files-without-var-ok.ps1 -SolutionDir`** - Seskupí soubory bez "variables names: ok"
  - EN: Groups .cs files without "// variables names: ok" comment
  - CZ: Seskupí .cs soubory bez "// variables names: ok" komentáře
  - Parametr: `-SolutionDir` (povinný) - cesta k solution adresáři

- **`remove-empty-classes.ps1 [-Force] [-DryRun] [-OpenInVS]`** - Smaže prázdné C# třídy
  - EN: Checks and removes empty C# classes with various options
  - CZ: Zkontroluje a smaže prázdné C# třídy s různými možnostmi
  - Parametry: `-Force` (bez potvrzení), `-DryRun` (default true), `-OpenInVS` (otevře v VS)

## 📌 Pravidelně používané skripty

### NuGet Management
- **`republish-nuget-packages.ps1`** - Publikuje NuGet balíčky s kontrolou frameworks
  - EN: Republishes NuGet packages with framework verification
  - CZ: Publikuje NuGet balíčky s ověřením frameworks
  - Podporuje auto-versioning (YY.M.D.sequence)
  - Dotazuje NuGet.org API pro kontrolu publikovaných verzí

- **`republish-parallel.ps1`** - Paralelní publikování NuGet balíčků (8x rychlejší)
  - EN: Publishes multiple packages in parallel for faster processing
  - CZ: Publikuje více balíčků paralelně pro rychlejší zpracování
  - Používá PowerShell parallel processing
  - Thread-safe versioning s file locking

- **`compare-with-nuget.ps1`** - Porovná lokální projekty s publikovanými balíčky
  - EN: Compares local projects with published NuGet packages
  - CZ: Porovná lokální projekty s publikovanými NuGet balíčky

### Target Frameworks Management
- **`get-target-frameworks.ps1`** - Zobrazí target frameworks pro všechny projekty
  - EN: Lists all projects with their target frameworks and explains deviations
  - CZ: Vypíše všechny projekty s jejich target frameworky a vysvětlí odchylky
  - Čte z FRAMEWORKS.md, README.md nebo .csproj komentářů
  - Seskupuje podle kombinací frameworks

- **`fix-target-frameworks.ps1`** - Opraví target frameworks na net10.0;net9.0;net8.0
  - EN: Fixes target frameworks to net10.0;net9.0;net8.0
  - CZ: Opraví target frameworks na net10.0;net9.0;net8.0
  - Batch úprava všech .csproj souborů

- **`create-frameworks-docs.ps1`** - Vytvoří FRAMEWORKS.md pro nestandardní projekty
  - EN: Creates FRAMEWORKS.md documentation for non-standard projects
  - CZ: Vytvoří FRAMEWORKS.md dokumentaci pro nestandardní projekty
  - Používá template z FRAMEWORKS.md.template

### Git & Submodules
- **`list-branches-grouped.ps1`** - Seznam větví pro root a submoduly, seskupené
  - EN: Shows which repositories have which local branches, grouped by branch pattern
  - CZ: Zobrazuje které repozitáře mají které lokální větve, seskupené podle vzoru větví

- **`commit-all-submodules.ps1`** - Commituje a pushuje změny ve všech submodulech
  - EN: Commits and pushes changes in all modified submodules
  - CZ: Commituje a pushuje změny ve všech upravených submodulech

- **`commit-and-push-all-submodules.ps1`** - Alternativní verze pro commit&push submodulů
  - EN: Alternative version for committing and pushing all submodules
  - CZ: Alternativní verze pro commitování a pushování všech submodulů

- **`list-changed-files-in-submodules.ps1`** - Seznam změněných souborů v submodulech
  - EN: Lists changed files in all submodules
  - CZ: Vypíše změněné soubory ve všech submodulech

- **`clone-submodules-parallel.ps1`** - Paralelní klonování submodulů
  - EN: Parallel submodule cloning for faster setup
  - CZ: Paralelní klonování submodulů pro rychlejší setup

- **`force-push-all-submodules.ps1`** - Force push všech submodulů
  - EN: Force pushes all submodules
  - CZ: Force pushuje všechny submoduly

### Development Workflow
- **`group-submodules.ps1`** - Seskupí submoduly do skupin
  - EN: Groups submodules into manageable groups
  - CZ: Seskupí submoduly do spravovatelných skupin
  - Vytváří `submodules-grouped.md`

- **`setup-husky-all-projects.ps1`** - Nastavení Husky.NET pro všechny projekty
  - EN: Setup Husky.NET for all projects in the repository
  - CZ: Nastavení Husky.NET pro všechny projekty v repozitáři

- **`add-github-workflow.ps1`** - Přidá GitHub workflow
  - EN: Adds GitHub workflow configuration
  - CZ: Přidá GitHub workflow konfiguraci

### Documentation & Changelog
- **`generate-changelog.ps1`** - Generování detailního changelogu
  - EN: Generate detailed changelog from git commits
  - CZ: Generování detailního changelogu z git commitů

- **`generate-rich-changelog.ps1`** - Generování bohatého changelogu
  - EN: Generate rich changelog with formatting
  - CZ: Generování bohatého changelogu s formátováním

- **`generate-readmes.ps1`** - Generování README souborů
  - EN: Generate README files for projects
  - CZ: Generování README souborů pro projekty

### Project Structure
- **`find-projects.ps1`** - Najde všechny .csproj soubory
  - EN: Finds all .csproj files in the repository
  - CZ: Najde všechny .csproj soubory v repozitáři

- **`create-solution.ps1`** - Vytvoří .sln soubor se všemi projekty
  - EN: Creates solution file with all projects
  - CZ: Vytvoří solution soubor se všemi projekty

- **`create-selected-solution.ps1`** - Vytvoří .sln s vybranými projekty
  - EN: Creates solution file with selected projects
  - CZ: Vytvoří solution soubor s vybranými projekty

- **`add-runners-to-sln.ps1`** - Přidá Runner projekty do solution
  - EN: Adds Runner projects to solution
  - CZ: Přidá Runner projekty do solution

### Variable Naming & Code Quality
- **`add-variables-ok-comment.ps1`** - Přidá `// variables names: ok` komentář
  - EN: Adds '// variables names: ok' comment to reviewed files
  - CZ: Přidá '// variables names: ok' komentář do zkontrolovaných souborů

- **`check-variables-names-marker.ps1`** - Zkontroluje přítomnost marker komentářů
  - EN: Checks for presence of variable names marker comments
  - CZ: Zkontroluje přítomnost marker komentářů pro názvy proměnných

- **`count-variables-ok-comments.ps1`** - Spočítá soubory s `// variables names: ok`
  - EN: Counts files with '// variables names: ok' comment
  - CZ: Spočítá soubory s '// variables names: ok' komentářem

- **`add-enum-comments.ps1`** - Přidá marker komentáře do enum souborů
  - EN: Adds marker comments to enum-only files
  - CZ: Přidá marker komentáře do souborů obsahujících pouze enumy

- **`open-files-without-var-ok.ps1`** - Otevře soubory bez marker komentáře
  - EN: Opens files without '// variables names: ok' comment
  - CZ: Otevře soubory bez '// variables names: ok' komentáře

- **`check-refactoring-status.ps1`** - Kontrola statusu refactoringu
  - EN: Check refactoring status across projects
  - CZ: Kontrola statusu refactoringu napříč projekty

### Submodule Documentation
- **`add-submodule-claude-md.ps1`** - Přidá CLAUDE.md do submodulů
  - EN: Adds CLAUDE.md file to submodules
  - CZ: Přidá CLAUDE.md soubor do submodulů

- **`add-root-claude-md.ps1`** - Přidá CLAUDE.md do root projektu
  - EN: Adds CLAUDE.md file to root project
  - CZ: Přidá CLAUDE.md soubor do root projektu

---

## 🗄️ Jednorázově použité skripty

### Variable Renaming (Historical - feat-better-naming-for-variables branch)
Tyto skripty byly použity při velkém refactoringu přejmenování proměnných na samopopisné názvy:

- **`refactor-short-variables.ps1`** - Původní verze refactoring skriptu
- **`refactor-short-variables-v2.ps1`** - Vylepšená verze 2
- **`fix-short-variable-names.ps1`** - Oprava krátkých názvů proměnných
- **`fix-all-remaining-short-vars.ps1`** - Oprava všech zbývajících krátkých proměnných
- **`fix-all-remaining-short-vars-ultimate.ps1`** - Ultimate verze
- **`fix-all-short-variable-names-complete.ps1`** - Kompletní oprava
- **`fix-short-vars-across-submodules.ps1`** - Oprava napříč submoduly
- **`fix-short-vars-comprehensive-v2.ps1`** - Comprehensive verze 2
- **`fix-short-vars-final.ps1`** - Finální verze
- **`fix-incomplete-variable-renames.ps1`** - Oprava nekompletních přejmenování
- **`fix-incorrect-type-renames.ps1`** - Oprava nesprávných přejmenování typů
- **`fix-method-body-variables.ps1`** - Oprava proměnných v těle metod
- **`verify-refactoring-complete.ps1`** - Ověření dokončení refactoringu
- **`verify-no-short-vars.ps1`** - Ověření že nejsou krátké proměnné
- **`verify-all-short-vars-comprehensive.ps1`** - Comprehensive verifikace
- **`find-short-vars-in-refactored-files.ps1`** - Hledání krátkých vars v refactorovaných souborech
- **`find-incomplete-renames.ps1`** - Hledání nekompletních přejmenování
- **`list-unmodified-files-in-submodules.ps1`** - Seznam neupravených souborů
- **`split-variables-for-ai-analysis.ps1`** - Rozdělení proměnných pro AI analýzu
- **`generate-ai-rename-mappings.ps1`** - Generování AI rename mappingů
- **`apply-variable-rename-mappings.ps1`** - Aplikace rename mappingů
- **`rename-parameters.ps1`** - Přejmenování parametrů
- **`fix-remaining-variables.ps1`** - Oprava zbývajících proměnných

### Specific Variable Fixes (Historical)
- **`fix-variable-names-sh.ps1`** - Oprava proměnných v SH třídě
- **`fix-sh-foreach-variables-part1.ps1`** - Oprava SH foreach proměnných část 1
- **`fix-sh-remaining-line.ps1`** - Oprava zbývajícího řádku v SH
- **`fix-throwex-type-collision.ps1`** - Oprava kolize typů v ThrowEx

### Parameter & Field Casing (Historical)
- **`fix-non-private-fields-casing.ps1`** - Oprava casing non-private fields
- **`fix-parameter-casing.ps1`** - Oprava casing parametrů
- **`fix-parameters-simple.ps1`** - Jednoduchá oprava parametrů
- **`fix-parameter-usages-in-methods.ps1`** - Oprava použití parametrů v metodách

### Mapping Files (Historical)
- **`convert-mappings.ps1`** - Konverze mapping souborů
- **`verify-mappings.ps1`** - Verifikace mappingů
- **`summary-mappings.ps1`** - Souhrn mappingů

### File Management (Historical)
- **`find-large-files.ps1`** - Hledání velkých souborů
- **`split-large-files-to-partial.ps1`** - Rozdělení velkých souborů na partial
- **`cleanup-split-files.ps1`** - Vyčištění rozdělených souborů
- **`cleanup-partial-files.ps1`** - Vyčištění partial souborů
- **`find-files-without-header.ps1`** - Hledání souborů bez hlavičky
- **`find-files-without-marker.ps1`** - Hledání souborů bez markeru
- **`find-and-open-empty-cs-files.ps1`** - Hledání a otevření prázdných .cs souborů
- **`delete-current-file-with-confirmation.ps1`** - Smazání aktuálního souboru s potvrzením
- **`get-files-without-header.ps1`** - Získání souborů bez hlavičky
- **`extract-files.ps1`** - Extrakce souborů

### Code Cleanup (Historical)
- **`remove-commented-code-blocks.ps1`** - Odstranění zakomentovaných bloků kódu
- **`comment-broken-usings.ps1`** - Zakomentování nefunkčních using direktiv
- **`fix-comments-replacement.ps1`** - Oprava náhrady komentářů
- **`fix-whitespace.ps1`** - Oprava whitespace

### .NET Version Migration (Historical)
- **`upgrade-to-net9.ps1`** - Upgrade na .NET 9
- **`fix-net10.ps1`** - Oprava net10.0
- **`fix-net10-to-net9.ps1`** - Oprava net10.0 na net9.0
- **`restore-net10-in-submodules.ps1`** - Obnovení net10.0 v submodulech
- **`fix-runner-tests-frameworks.ps1`** - Oprava frameworks v Runner/Tests projektech
- **`set-all-runner-tests-frameworks.ps1`** - Nastavení frameworks všem Runner/Tests
- **`find-net8-projects.ps1`** - Hledání projektů s net8.0

### Build & Testing (Historical)
- **`check-all-builds.ps1`** - Kontrola buildů všech projektů
- **`build-test-solution.ps1`** - Build test solution
- **`show-build-errors.ps1`** - Zobrazení build chyb
- **`check-complete-projects.ps1`** - Kontrola kompletních projektů
- **`check-complete-solutions.ps1`** - Kontrola kompletních solutions
- **`fix-test-projects.ps1`** - Oprava test projektů

### Git Operations (Historical)
- **`register-all-submodules.ps1`** - Registrace všech submodulů do .gitmodules
- **`create-gitmodules.ps1`** - Vytvoření .gitmodules souboru
- **`revert-all-submodules.ps1`** - Revert všech submodulů
- **`revert-submodules.ps1`** - Revert submodulů
- **`check-submodule-status.ps1`** - Kontrola statusu submodulů

### Utility Scripts (Historical)
- **`apply-fix.ps1`** - Aplikace fixu
- **`fix-broken-script.ps1`** - Oprava nefunkčního skriptu
- **`fix-by-lines.ps1`** - Oprava po řádcích
- **`fix-all-refactoring-issues.ps1`** - Oprava všech refactoring problémů
- **`fix-pushSolutionsData.ps1`** - Oprava pushSolutionsData
- **`test-regex.ps1`** - Testování regex
- **`test-write.ps1`** - Testování zápisu
- **`test-empty-class-detection.ps1`** - Testování detekce prázdných tříd
- **`test-specific-file.ps1`** - Testování specifického souboru
- **`check-line.ps1`** - Kontrola řádku

### Visual Studio Integration (Historical)
- **`diagnose-vs-dte.ps1`** - Diagnostika VS DTE
- **`enumerate-rot.ps1`** - Enumerace ROT (Running Object Table)
- **`check-vs-rot-simple.ps1`** - Jednoduchá kontrola VS ROT

### Claude Integration (Historical)
- **`start-claude.ps1`** - Spuštění Claude
- **`start-claude-sunamoai.ps1`** - Spuštění Claude pro SunamoAI
- **`start-claude-sunamoargs.ps1`** - Spuštění Claude pro SunamoArgs
- **`add-marker-to-all.ps1`** - Přidání markeru všem
- **`add-marker-to-current-file.ps1`** - Přidání markeru aktuálnímu souboru

### Project Structure Analysis (Historical)
- **`find-folders-without-csproj.ps1`** - Hledání složek bez .csproj
- **`find-non-standard-structure.ps1`** - Hledání nestandardní struktury

### Progress Tracking (Historical)
- **`generate-progress-report.ps1`** - Generování progress reportu (NAHRAZENO check-group.ps1)
- **`check-submodules-quality.ps1`** - Kontrola kvality submodulů (NAHRAZENO check-group.ps1)
- **`update-progress-in-grouped.ps1`** - Aktualizace progressu v grouped.md

### Version Management (Historical)
- **`increment-versions.ps1`** - Inkrementace verzí

### Extraction & Filtering (Historical)
- **`extract-projects.ps1`** - Extrakce projektů
- **`filter-errors.ps1`** - Filtrování chyb

### Verification (Historical)
- **`verify-published.ps1`** - Ověření publikovaných balíčků

---

## 📁 Supporting Files

### Templates
- **`FRAMEWORKS.md.template`** - Template pro FRAMEWORKS.md dokumentaci

### Data Files
- **`.sequence-26.1.1`** - Sequence number pro versioning
- **`submodules-grouped.md`** - Seskupené submoduly
- **`submodules-quality-report.json`** - Report kvality submodulů
- **`variable-renaming-progress.md`** - Progress přejmenování proměnných

### Log Files
- **`commit-log.txt`** - Log commitů
- **`gaac-log.txt`** - Log gaac funkcí
- **`parallel-log.txt`** - Log paralelního zpracování
- **`republish-log.txt`** - Log publikování
- **`line57.txt`** - Specifický řádek pro debugging

### Helper Scripts
- **`run-parallel.ps1`** - Helper pro paralelní spouštění

---

## 💡 Usage Tips

### Denní workflow
1. **Kontrola frameworks**: `get-target-frameworks-with-reasons.ps1`
2. **Progress + kvalita**: `check-group.ps1 -GroupNumber 1`
3. **Jen progress (rychle)**: `check-group.ps1 -GroupNumber 1 -SkipBuild`
4. **Otevření terminálů**: `open-terminal-tabs.ps1 -GroupNumber 1`

### Pravidelné workflow
1. **Publikování balíčků**: `republish-parallel.ps1`
2. **Commit změn**: `commit-all-submodules.ps1`

### Git workflow
1. Seznam větví: `list-branches-grouped.ps1`
2. Změněné soubory: `list-changed-files-in-submodules.ps1`
3. Commit & push: `commit-all-submodules.ps1`

### Kvalita kódu
1. Kontrola marker komentářů: `check-variables-names-marker.ps1`
2. Přidání markerů do enum souborů: `add-enum-comments.ps1`
3. Otevření souborů bez markeru: `open-files-without-var-ok.ps1`

---

**Poslední aktualizace:** 2026-01-01
**Celkem skriptů:** 100+
**Kategorie:** NuGet, Git, Frameworks, Code Quality, Project Structure
