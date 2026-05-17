#requires -Version 7.0
<#
.SYNOPSIS
  Generates DocFX and MkDocs Material configurations for ALL Sunamo* NuGet packages.

.DESCRIPTION
  Enumerates Sunamo*/Sunamo*/Sunamo*.csproj files and produces:
    .docfx/docfx.json
    .docfx/index.md
    .mkdocs/mkdocs.yml
    .mkdocs/docs/index.md
    .mkdocs/docs/packages/{Package}.md  (one per package, sourced from {Package}/README.md when present)

  Run from the repository root.
#>

[CmdletBinding()]
param(
    # When set, generates configs only for the listed package names (e.g. "SunamoString").
    # Empty array (default) means: include all discovered Sunamo* packages.
    [string[]]$OnlyPackages = @()
)

$ErrorActionPreference = 'Stop'

$repoRoot   = Resolve-Path (Join-Path $PSScriptRoot '..')
$docfxDir   = Join-Path $repoRoot '.docfx'
$mkdocsDir  = Join-Path $repoRoot '.mkdocs'
$mkdocsDocs = Join-Path $mkdocsDir 'docs'
$mkdocsPkgs = Join-Path $mkdocsDocs 'packages'

New-Item -ItemType Directory -Force -Path $docfxDir, $mkdocsDir, $mkdocsDocs, $mkdocsPkgs | Out-Null

# 1. Discover packages
$packages = Get-ChildItem -Path $repoRoot -Directory -Filter 'Sunamo*' |
    Where-Object { $_.Name -notmatch '\.Tests$' -and $_.Name -notmatch '^Runner' } |
    ForEach-Object {
        $name = $_.Name
        $csproj = Join-Path $_.FullName "$name\$name.csproj"
        if (Test-Path -LiteralPath $csproj) {
            $description = ''
            try {
                [xml]$xml = Get-Content -LiteralPath $csproj -Raw
                $description = ($xml.Project.PropertyGroup |
                    Where-Object { $_.Description } |
                    Select-Object -First 1 -ExpandProperty Description) -as [string]
                if (-not $description) { $description = '' }
                $description = $description.Trim()
            } catch {
                Write-Warning "Failed to parse $csproj : $_"
            }
            [pscustomobject]@{
                Name        = $name
                CsprojRel   = "$name/$name/$name.csproj"
                ReadmePath  = Join-Path $_.FullName 'README.md'
                Description = $description
            }
        }
    } | Sort-Object Name

if ($OnlyPackages.Count -gt 0) {
    $filter = @{}
    foreach ($name in $OnlyPackages) { $filter[$name] = $true }
    $packages = $packages | Where-Object { $filter.ContainsKey($_.Name) }
    Write-Host "Filter active: $($OnlyPackages -join ', ')"
}

Write-Host "Discovered $($packages.Count) packages"

# 2. Build .docfx/docfx.json
$docfxJson = [ordered]@{
    metadata = @(
        [ordered]@{
            src = @(
                [ordered]@{
                    files = @($packages.CsprojRel)
                    src   = '..'
                }
            )
            dest                = 'api'
            properties          = @{ TargetFramework = 'net9.0' }
            disableGitFeatures  = $false
            disableDefaultFilter = $false
        }
    )
    build = [ordered]@{
        content = @(
            [ordered]@{ files = @('api/**.yml', 'api/index.md') }
            [ordered]@{ files = @('toc.yml', '*.md', 'articles/**.md', 'articles/**/toc.yml') }
        )
        resource = @(
            [ordered]@{ files = @('images/**') }
        )
        output   = '_site'
        template = @('default', 'modern')
        globalMetadata = [ordered]@{
            _appTitle         = 'Sunamo NuGet Packages'
            _appFooter        = 'Sunamo - Platform Independent NuGet Packages | <a href="https://github.com/sunamo/PlatformIndependentNuGetPackages">GitHub</a> | MIT License'
            _enableSearch     = $true
            _disableContribution = $false
            _gitContribute    = [ordered]@{
                repo   = 'https://github.com/sunamo/PlatformIndependentNuGetPackages'
                branch = 'master'
            }
        }
    }
}
$docfxJson | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath (Join-Path $docfxDir 'docfx.json') -Encoding UTF8
Write-Host "Wrote .docfx/docfx.json with $($packages.Count) projects"

# 3. Shared landing-page renderer (used by both DocFX and MkDocs)
function New-LandingMarkdown {
    param(
        [Parameter(Mandatory)] [object[]]$Packages,
        [Parameter(Mandatory)] [string]$ApiLinkBase,    # e.g. 'api/' for DocFX, '../api/' for MkDocs
        [Parameter(Mandatory)] [string]$GuideLinkBase   # e.g. 'guide/packages/' for DocFX, 'packages/' for MkDocs
    )
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('# Sunamo NuGet Packages')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('Platform-independent .NET NuGet packages — shared libraries for all apps & devices.')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('Each package has two documentation entry points:')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('- **API** — auto-generated reference (DocFX, namespaces, types, members).')
    [void]$sb.AppendLine('- **Guide** — narrative documentation built from each package README (MkDocs Material).')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## Quick links')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('- [GitHub repository](https://github.com/sunamo/PlatformIndependentNuGetPackages)')
    [void]$sb.AppendLine('- [NuGet profile](https://www.nuget.org/profiles/sunamo)')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Packages ($($Packages.Count))")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('| Package | Description | Docs |')
    [void]$sb.AppendLine('| --- | --- | --- |')
    foreach ($pkg in $Packages) {
        $desc = if ($pkg.Description) { $pkg.Description -replace '\|', '\|' -replace "`r?`n", ' ' } else { '' }
        $apiLink   = "$ApiLinkBase$($pkg.Name).html"
        $guideLink = "$GuideLinkBase$($pkg.Name)/"
        $nugetLink = "https://www.nuget.org/packages/$($pkg.Name)"
        [void]$sb.AppendLine("| **$($pkg.Name)** | $desc | [API]($apiLink) · [Guide]($guideLink) · [NuGet]($nugetLink) |")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## License')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('All packages are released under [MIT](https://github.com/sunamo/PlatformIndependentNuGetPackages/blob/master/LICENSE.txt).')
    return $sb.ToString()
}

# 4. .docfx/index.md
$docfxLanding = New-LandingMarkdown -Packages $packages -ApiLinkBase 'api/' -GuideLinkBase 'guide/packages/'
Set-Content -LiteralPath (Join-Path $docfxDir 'index.md') -Value $docfxLanding -Encoding UTF8
Write-Host "Wrote .docfx/index.md"

# 5. .mkdocs/mkdocs.yml
$navPackages = ($packages | ForEach-Object { "      - $($_.Name): packages/$($_.Name).md" }) -join "`n"
$mkdocsYaml = @"
site_name: Sunamo NuGet Packages
site_description: Platform-independent .NET NuGet packages — guides & usage notes.
site_url: https://sunamo.github.io/PlatformIndependentNuGetPackages/guide/
repo_url: https://github.com/sunamo/PlatformIndependentNuGetPackages
repo_name: sunamo/PlatformIndependentNuGetPackages
edit_uri: edit/master/
docs_dir: docs
site_dir: site

theme:
  name: material
  features:
    - navigation.instant
    - navigation.tracking
    - navigation.sections
    - navigation.top
    - search.suggest
    - search.highlight
    - content.code.copy
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

markdown_extensions:
  - admonition
  - attr_list
  - def_list
  - footnotes
  - tables
  - toc:
      permalink: true
  - pymdownx.details
  - pymdownx.highlight:
      anchor_linenums: true
  - pymdownx.inlinehilite
  - pymdownx.snippets
  - pymdownx.superfences
  - pymdownx.tabbed:
      alternate_style: true

plugins:
  - search

extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/sunamo
    - icon: fontawesome/brands/microsoft
      link: https://www.nuget.org/profiles/sunamo

nav:
  - Overview: index.md
  - Packages:
$navPackages
"@
Set-Content -LiteralPath (Join-Path $mkdocsDir 'mkdocs.yml') -Value $mkdocsYaml -Encoding UTF8
Write-Host "Wrote .mkdocs/mkdocs.yml"

# 6. .mkdocs/docs/index.md
$mkdocsLanding = New-LandingMarkdown -Packages $packages -ApiLinkBase '../api/' -GuideLinkBase 'packages/'
Set-Content -LiteralPath (Join-Path $mkdocsDocs 'index.md') -Value $mkdocsLanding -Encoding UTF8
Write-Host "Wrote .mkdocs/docs/index.md"

# 7. .mkdocs/docs/packages/{Package}.md  (one per package)
foreach ($pkg in $packages) {
    $target = Join-Path $mkdocsPkgs "$($pkg.Name).md"
    $header = @"
# $($pkg.Name)

$( if ($pkg.Description) { $pkg.Description } else { '' } )

- **NuGet**: [`$($pkg.Name)`](https://www.nuget.org/packages/$($pkg.Name))
- **Source**: [GitHub](https://github.com/sunamo/$($pkg.Name))
- **API reference**: [`../../api/$($pkg.Name).html`](../../api/$($pkg.Name).html)

---

"@
    if (Test-Path -LiteralPath $pkg.ReadmePath) {
        $readme = Get-Content -LiteralPath $pkg.ReadmePath -Raw
        # Strip the first H1 if it matches the package name (avoid duplicate heading).
        $readme = [regex]::Replace($readme, '^\s*#\s+' + [regex]::Escape($pkg.Name) + '\s*\r?\n', '', 'IgnoreCase')
        Set-Content -LiteralPath $target -Value ($header + $readme) -Encoding UTF8
    } else {
        $stub = $header + "_README not yet available for this package._`n"
        Set-Content -LiteralPath $target -Value $stub -Encoding UTF8
    }
}
Write-Host "Wrote $($packages.Count) per-package pages under .mkdocs/docs/packages/"

# 8. Remove stale per-package files for packages that no longer exist
$validNames = @{}
foreach ($pkg in $packages) { $validNames[$pkg.Name] = $true }
Get-ChildItem -LiteralPath $mkdocsPkgs -Filter '*.md' -File | ForEach-Object {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    if (-not $validNames.ContainsKey($base)) {
        Write-Host "Removing stale: $($_.Name)"
        Remove-Item -LiteralPath $_.FullName -Force
    }
}

Write-Host "`nDone."
