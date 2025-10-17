# EN: Generate rich changelog with AI-style descriptions
# CZ: Generování bohatého changelogu s AI popisy

param(
    [string]$RepoPath = "C:\Proj_Net\portal-ui",
    [string]$After = "2025-08-25",
    [string]$Before = "2025-09-12"
)

# EN: Function to create descriptive text for commit based on message
# CZ: Funkce pro vytvoření popisného textu pro commit na základě zprávy
function Get-CommitDescription {
    param([string]$message, [string]$hash)

    # Patterns and descriptions
    if ($message -match "feat:.*merge.*Water|after merge") {
        return @"
- **Co se dělo**: Merge stylů a komponent z Water portálu
- **Rozsah**: Integrace Water-specific stylů do portal-ui
- **Účel**: Unifikace stylů napříč portály
"@
    }
    elseif ($message -match "ZIS-\d+") {
        $zis = $matches[0]
        return @"
- **Co se dělo**: Implementace úkolu $zis
- **Type**: Feature/Fix podle Jira ticketu
- **Rozsah**: Detaily v Jira systému
"@
    }
    elseif ($message -match "fix:.*border|table") {
        return @"
- **Co se dělo**: Oprava stylování tabulek
- **Problém**: Nekonzistentní bordery/styly
- **Řešení**: Sjednocení CSS pravidel pro tabulky
"@
    }
    elseif ($message -match "moved.*shared.*src") {
        return @"
- **Co se dělo**: Přesun shared složky do src
- **Důvod**: Lepší organizace projektu, správná struktura pro NPM balíček
- **Impact**: Všechny importy shared komponent musely být aktualizovány
"@
    }
    elseif ($message -match "mass updated files") {
        return @"
- **Co se dělo**: Hromadná aktualizace souborů
- **Rozsah**: Pravděpodobně formatting, imports nebo strukturální změny
- **Metoda**: Použití automatizačních skriptů
"@
    }
    elseif ($message -match "import type|import") {
        return @"
- **Co se dělo**: Oprava/aktualizace importů
- **Důvod**: Změny v export structure nebo přechod na import type
- **TypeScript**: Rozlišení mezi type imports a value imports
"@
    }
    elseif ($message -match "@frui\.ts/validation.*Zod") {
        return @"
- **Co se dělo**: Migrace z @frui.ts/validation na Zod
- **Důvod**: Zod je modernější, lepší TypeScript podpora
- **Rozsah**: Všechny validation schemas přepsány na Zod
- **Breaking change**: API změny v validacích
"@
    }
    elseif ($message -match "Merged PR") {
        $pr = if ($message -match "PR (\d+)") { $matches[1] } else { "?" }
        return @"
- **Co se dělo**: Merge Pull Requestu #$pr
- **Source**: Azure DevOps
- **Review**: PR prošel code review procesem
"@
    }
    elseif ($message -match "fix:.*build") {
        return @"
- **Co se dělo**: Oprava build errors
- **Typ**: Pravděpodobně TypeScript errors nebo missing dependencies
- **Priorita**: Kritická - blokovala deployment
"@
    }
    elseif ($message -match "DevOps") {
        return @"
- **Co se dělo**: DevOps/CI pipeline úpravy
- **Rozsah**: Azure DevOps konfigurace
- **Účel**: Stabilizace build procesu
"@
    }
    elseif ($message -match "rename.*index\.tsx.*component") {
        return @"
- **Co se dělo**: Přejmenování index.tsx souborů na názvy komponent
- **Před**: components/Button/index.tsx
- **Po**: components/Button/Button.tsx
- **Důvod**: Lepší dev experience, jasné file names v editoru
- **Automatizace**: Script pro hromadné přejmenování
"@
    }
    elseif ($message -match "React.*19|React\.FC") {
        return @"
- **Co se dělo**: Migrace na React 19
- **Změny**: Odstranění React.FC, nové type annotations
- **Pattern**: `FC<Props>` → `(props: Props) => JSX.Element`
- **Breaking**: React 19 má změny v API
"@
    }
    elseif ($message -match "css.*scss|replaced css") {
        return @"
- **Co se dělo**: Konverze CSS na SCSS
- **Důvod**: SCSS poskytuje variables, nesting, mixins
- **Rozsah**: Přejmenování .css → .scss, update importů
"@
    }
    elseif ($message -match "echarts.*recharts") {
        return @"
- **Co se dělo**: Migrace z echarts-for-react na recharts
- **Důvod**: recharts má lepší React integaci, menší bundle
- **Rozsah**: Přepsání všech chartů na recharts API
- **Breaking**: Kompletně jiné API chartovací knihovny
"@
    }
    elseif ($message -match "console\.log|remove.*comment") {
        return @"
- **Co se dělo**: Odstranění console.log statements a komentářů
- **Důvod**: Čištění kódu před release
- **Automatizace**: Script pro odstranění debug výpisů
"@
    }
    elseif ($message -match "VERIFIED|verified") {
        return @"
- **Co se dělo**: Manuálně ověřené změny
- **Process**: Změny byly zkontrolovány před commitem
- **Quality**: Extra pozornost na správnost
"@
    }
    elseif ($message -match "split|splitted") {
        return @"
- **Co se dělo**: Rozdělení velkých souborů na menší
- **Důvod**: Lepší organizace, jednodušší maintenance
- **Pattern**: Jeden soubor → multiple files (jeden export per file)
"@
    }
    elseif ($message -match "duplicit") {
        return @"
- **Co se dělo**: Odstranění duplikátních souborů/kódu
- **Důvod**: DRY principle, menší bundle size
- **Metoda**: Identifikace a consolidace duplicit
"@
    }
    elseif ($message -match "tsx.*ts|extension") {
        return @"
- **Co se dělo**: Přejmenování .tsx → .ts kde není JSX
- **Důvod**: .tsx by měly být jen soubory s JSX elementy
- **Impact**: Správná file extension convention
"@
    }
    elseif ($message -match "@observable.*accessor") {
        return @"
- **Co se dělo**: Přidání accessor keyword k @observable
- **Důvod**: MobX 6 requirement
- **Pattern**: `@observable prop` → `@observable accessor prop`
- **Breaking**: MobX 6 vyžaduje accessor pro auto-tracking
"@
    }
    elseif ($message -match "case-sensitivity|case.*sensitive") {
        return @"
- **Co se dělo**: Opravy case-sensitivity pro Linux builds
- **Problém**: Windows je case-insensitive, Linux ne
- **Fix**: Správné casing v import paths a file names
- **Impact**: Builds nyní fungují na Linux AgentPoolech
"@
    }
    elseif ($message -match "pipeline") {
        return @"
- **Co se dělo**: Úpravy CI/CD pipeline
- **Platform**: Azure DevOps
- **Změny**: Konfigurace build steps, triggers, nebo pool
"@
    }
    else {
        return @"
- **Co se dělo**: $message
- **Hash**: $hash
"@
    }
}

# Main script
Write-Host "Generating rich changelog..."  -ForegroundColor Cyan

$commits = git -C $RepoPath log --all --after=$After --before=$Before --reverse --format="%ai|%h|%s"

$currentDate = ""
$output = @"
# Detailní Changelog s popisy

Vygenerováno: $(Get-Date -Format 'dd.MM.yyyy HH:mm')
Období: $After až $Before
Celkem commitů: $($commits.Count)

---

"@

foreach ($commit in $commits) {
    $parts = $commit -split '\|', 3
    $datetime = $parts[0]
    $hash = $parts[1]
    $message = $parts[2]

    $date = $datetime.Substring(0, 10)
    $time = $datetime.Substring(11, 8)

    $dateParts = $date -split '-'
    $day = $dateParts[2]
    $month = switch ($dateParts[1]) {
        "08" { "srpna" }
        "09" { "září" }
        default { "?" }
    }
    $year = $dateParts[0]

    # New date header
    if ($date -ne $currentDate) {
        if ($currentDate -ne "") {
            $output += "`n"
        }
        $output += "## $day. $month $year`n`n"
        $currentDate = $date
    }

    # Commit entry with description
    $description = Get-CommitDescription -message $message -hash $hash
    $output += "### **$hash** - $message ($time)`n"
    $output += "$description`n`n"
}

$outputPath = "C:\Proj_Net\_ZaPo\portal-ui\ChangeLog\rich-changelog-sample.md"
$output | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "Rich changelog saved to: $outputPath" -ForegroundColor Green
Write-Host "Total commits processed: $($commits.Count)" -ForegroundColor Yellow
