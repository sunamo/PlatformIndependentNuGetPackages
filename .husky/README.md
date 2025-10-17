# Husky.NET Centralized Configuration
# CZ: Centralizovaná konfigurace Husky.NET

This directory contains the centralized Husky.NET configuration for all projects in this repository.

CZ: Tato složka obsahuje centralizovanou konfiguraci Husky.NET pro všechny projekty v tomto repozitáři.

## Structure / CZ: Struktura

```
.husky/
├── scripts/
│   └── check-czech-characters.ps1  # Pre-commit hook to check for Czech characters
│                                    # CZ: Pre-commit hook pro kontrolu českých znaků
├── task-runner.json                 # Husky.NET task configuration
│                                    # CZ: Konfigurace úkolů pro Husky.NET
└── README.md                        # This file / CZ: Tento soubor
```

## Pre-commit Hooks / CZ: Pre-commit hooky

### Czech Characters Check / CZ: Kontrola českých znaků

**Purpose:** Prevents Czech characters from being committed in `.cs` files across all projects.

**CZ: Účel:** Zabraňuje commitování českých znaků v `.cs` souborech napříč všemi projekty.

**How it works / CZ: Jak to funguje:**
1. Scans all `.cs` files (excluding `obj/` and `bin/` directories)
2. Detects Czech characters: `á, č, ď, é, ě, í, ň, ó, ř, š, ť, ú, ů, ý, ž` (and their uppercase variants)
3. Blocks commit if Czech characters are found
4. Allows exceptions on specific lines using a special comment

CZ:
1. Skenuje všechny `.cs` soubory (s výjimkou složek `obj/` a `bin/`)
2. Detekuje české znaky: `á, č, ď, é, ě, í, ň, ó, ř, š, ť, ú, ů, ý, ž` (a jejich velké varianty)
3. Zablokuje commit pokud jsou nalezeny české znaky
4. Povoluje výjimky na konkrétních řádcích pomocí speciálního komentáře

### Exception Comment / CZ: Výjimkový komentář

To allow Czech characters on a specific line, add this comment **on the line before** the code with Czech characters:

CZ: Pro povolení českých znaků na konkrétním řádku, přidejte tento komentář **na řádek před** kód s českými znaky:

```csharp
// husky-allow-czech
public string CzechText = "Toto je český text";
```

**Example / CZ: Příklad:**

```csharp
namespace SunamoLang;

public class CzechHelper
{
    // This will be blocked / CZ: Toto bude zablokováno
    public string Name = "Příklad";

    // husky-allow-czech
    public string AllowedCzech = "Toto je povolený český text";

    // This will also be blocked / CZ: Toto bude také zablokováno
    public string AnotherName = "Jméno";
}
```

## Setup / CZ: Nastavení

### Initial Setup for All Projects / CZ: Úvodní nastavení pro všechny projekty

Run the setup script from the repository root:

CZ: Spusťte setup skript z rootu repozitáře:

```powershell
pwsh -NoProfile -File scripts/setup-husky-all-projects.ps1
```

This will:
- Install Husky.NET for all solution files
- Configure pre-commit hooks
- Link to the centralized configuration

CZ: Toto provede:
- Instalaci Husky.NET pro všechny solution soubory
- Konfiguraci pre-commit hooků
- Propojení na centralizovanou konfiguraci

### Adding Husky.NET to a New Project / CZ: Přidání Husky.NET do nového projektu

For new projects added to the repository, you can either:

CZ: Pro nové projekty přidané do repozitáře můžete buď:

1. **Run the full setup script** (will skip already configured projects):
   ```powershell
   pwsh -NoProfile -File scripts/setup-husky-all-projects.ps1
   ```

2. **Manually configure for a specific solution**:
   ```powershell
   cd path/to/your/solution
   dotnet tool install Husky
   dotnet husky install
   dotnet husky add pre-commit -c "dotnet husky run"
   ```

## Testing the Hook / CZ: Testování hooku

To test if the pre-commit hook is working:

CZ: Pro otestování zda pre-commit hook funguje:

```powershell
# Run the check script manually on a specific directory
# CZ: Spusťte kontrolní skript manuálně na konkrétní složce
pwsh -NoProfile -File .husky/scripts/check-czech-characters.ps1 "E:\vs\Projects\PlatformIndependentNuGetPackages\SunamoArgs"
```

## Configuration Files / CZ: Konfigurační soubory

### task-runner.json

Defines the tasks that Husky.NET will run on pre-commit:

CZ: Definuje úkoly které Husky.NET spustí při pre-commit:

```json
{
  "tasks": [
    {
      "name": "check-czech-characters",
      "group": "pre-commit",
      "command": "pwsh",
      "args": [
        "-NoProfile",
        "-File",
        "${hooksDir}/scripts/check-czech-characters.ps1"
      ],
      "pathMode": "absolute"
    }
  ]
}
```

## Troubleshooting / CZ: Řešení problémů

### Hook not running / CZ: Hook se nespouští

1. Verify Husky.NET is installed:
   ```powershell
   dotnet tool list
   ```

2. Check if `.husky` directory exists in your solution
3. Verify the `pre-commit` file exists in `.husky/`

CZ:
1. Ověřte že Husky.NET je nainstalován
2. Zkontrolujte zda složka `.husky` existuje ve vašem řešení
3. Ověřte že soubor `pre-commit` existuje v `.husky/`

### PowerShell script not executing / CZ: PowerShell skript se nespouští

Ensure PowerShell execution policy allows running scripts:

CZ: Ujistěte se že PowerShell execution policy povoluje spouštění skriptů:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### False positives / CZ: Falešné pozitivní detekce

If legitimate Czech characters are being blocked (e.g., in localization files, comments, or test data), use the exception comment:

CZ: Pokud jsou blokovány legitimní české znaky (např. v lokalizačních souborech, komentářích nebo testovacích datech), použijte výjimkový komentář:

```csharp
// husky-allow-czech
```

## Maintenance / CZ: Údržba

### Updating the Hook Script / CZ: Aktualizace hook skriptu

To update the check script for all projects:

CZ: Pro aktualizaci kontrolního skriptu pro všechny projekty:

1. Edit `.husky/scripts/check-czech-characters.ps1`
2. Changes will automatically apply to all projects on next commit (since they reference the centralized script)

CZ:
1. Editujte `.husky/scripts/check-czech-characters.ps1`
2. Změny se automaticky projeví ve všech projektech při dalším commitu (protože odkazují na centralizovaný skript)

### Adding New Checks / CZ: Přidání nových kontrol

To add new pre-commit checks:

CZ: Pro přidání nových pre-commit kontrol:

1. Create a new script in `.husky/scripts/`
2. Add a new task to `.husky/task-runner.json`
3. Each project will automatically pick up the new check

CZ:
1. Vytvořte nový skript v `.husky/scripts/`
2. Přidejte nový úkol do `.husky/task-runner.json`
3. Každý projekt automaticky převezme novou kontrolu

## Repository Statistics / CZ: Statistiky repozitáře

- **Total solutions configured:** 131
- **Centralized configuration:** Yes
- **Active hooks:** 1 (Czech character check)

CZ:
- **Celkem nakonfigurovaných řešení:** 131
- **Centralizovaná konfigurace:** Ano
- **Aktivní hooky:** 1 (kontrola českých znaků)

## References / CZ: Reference

- [Husky.NET Documentation](https://alirezanet.github.io/Husky.Net/)
- [Git Hooks Documentation](https://git-scm.com/docs/githooks)

---

**Last updated:** 2025-10-12
**CZ: Poslední aktualizace:** 2025-10-12
