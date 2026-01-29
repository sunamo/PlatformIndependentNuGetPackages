# Grouped Submodules Reports

Tento soubor popisuje jak fungují skripty pro sledování pokroku práce na jednotlivých skupinách submodulů.

## Hlavní soubor: `submodules-grouped.md`

Všechny výsledky se zapisují do souboru `.scripts/submodules-grouped.md`, který obsahuje:
- Seznam všech submodulů rozdělených do skupin po 10
- Pro každou skupinu timestamp posledního spuštění progress reportu a quality checku
- Aktuální statistiky pro každý submodul

## Skripty

### 1. `generate-progress-report.ps1`

Generuje report o pokroku přidávání `// variables names: ok` komentářů.

**Použití:**
```powershell
# Aktualizovat pouze Group 1 v submodules-grouped.md
.\.scripts\generate-progress-report.ps1 -GroupNumber 1

# Generovat kompletní report do variable-renaming-progress.md (všechny skupiny)
.\.scripts\generate-progress-report.ps1
```

**Co dělá při -GroupNumber:**
- Analyzuje všechny .cs soubory v submodulech dané skupiny
- Spočítá procento souborů s komentářem `// variables names: ok`
- Aktualizuje seznam projektů v `submodules-grouped.md`
- Zapíše timestamp do řádku "**Progress report:** Last updated YYYY-MM-DD HH:MM:SS"

### 2. `check-submodules-quality.ps1`

Kontroluje kvalitu submodulů (NoWarn v .csproj, build warnings/errors).

**Použití:**
```powershell
# Kontrolovat pouze Group 6 a zapsat výsledky do submodules-grouped.md
.\.scripts\check-submodules-quality.ps1 -GroupNumber 6

# Kontrolovat všechny submoduly
.\.scripts\check-submodules-quality.ps1
```

**Co dělá při -GroupNumber:**
- Kontroluje všechny .csproj soubory v submodulech dané skupiny
- Hledá `<NoWarn>` element v .csproj souborech
- Buildí všechny projekty a hlásí warnings/errors
- Zapíše výsledky do `.scripts/submodules-quality-report.json`
- Zapíše timestamp a souhrn do řádku "**Quality check:** Last updated YYYY-MM-DD HH:MM:SS - Perfect: X, NoWarn issues: Y, Build errors: Z, Build warnings: W"
- Přidá kvalitativní indikátory ke každému submodulu:
  - `[✓]` - perfektní (bez NoWarn, bez build issues)
  - `[⚠ NoWarn]` - obsahuje `<NoWarn>` v .csproj
  - `[✗ BUILD ERRORS]` - build selhává s chybami
  - `[⚠ Warnings]` - build má pouze warnings

## Formát `submodules-grouped.md`

```markdown
## Group 6

**Progress report:** Last updated 2026-01-19 19:59:33
**Quality check:** Last updated 2026-01-19 20:18:23 - Perfect: 6, NoWarn issues: 2, Build errors: 2, Build warnings: 0

- SunamoFtp (0% - 0/37) [⚠ NoWarn]
- SunamoGetFiles (3.23% - 1/31) [✗ BUILD ERRORS]
- SunamoGetFolders (0% - 0/22) [✓]
- SunamoGitConfig (0% - 0/16) [⚠ NoWarn]
...
```

Každá skupina obsahuje:
- **Progress report timestamp**: Kdy naposledy byl spuštěn `generate-progress-report.ps1 -GroupNumber X`
- **Quality check timestamp a souhrn**: Kdy naposledy byl spuštěn `check-submodules-quality.ps1 -GroupNumber X`, včetně souhrnu (Perfect, NoWarn issues, Build errors, Build warnings)
- **Seznam submodulů** s:
  - Aktuálním procentem dokončenosti (formát: `XX% - Y/Z` kde Y = soubory s komentářem, Z = celkový počet souborů)
  - Kvalitativním indikátorem (formát: `[✓]`, `[⚠ NoWarn]`, `[✗ BUILD ERRORS]`, `[⚠ Warnings]`)

## Typický workflow

1. Pracuješ na Group 1 - opravuješ názvy proměnných
2. Spustíš `generate-progress-report.ps1 -GroupNumber 1` - vidíš aktuální pokrok
3. Po dokončení Group 1 spustíš `check-submodules-quality.ps1 -GroupNumber 1` - zkontroluje build
4. V `submodules-grouped.md` vidíš timestampy obou kontrol
5. Pokračuješ na Group 2

## Poznámky

- Skripty bez `-GroupNumber` parametru generují kompletní reporty do samostatných souborů
- `submodules-grouped.md` obsahuje vždy aktuální stav pro každou skupinu
- Timestampy umožňují sledovat, kdy naposledy byla daná skupina kontrolována
