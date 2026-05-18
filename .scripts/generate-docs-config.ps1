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
        [Parameter(Mandatory)] [AllowEmptyString()] [string]$PackageLinkBase   # '' for DocFX root, '../' for MkDocs nested
    )
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine('# Sunamo NuGet Packages')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('Platform-independent .NET NuGet packages — shared libraries for all apps & devices.')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('Each package has its own page with two entry points:')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('- **API reference** — auto-generated from source (DocFX).')
    [void]$sb.AppendLine('- **Guide** — narrative documentation from the package README (MkDocs Material).')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## Quick links')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('- [GitHub repository](https://github.com/sunamo/PlatformIndependentNuGetPackages)')
    [void]$sb.AppendLine('- [NuGet profile](https://www.nuget.org/profiles/sunamo)')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## Packages ($($Packages.Count))")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('| Package | Description |')
    [void]$sb.AppendLine('| --- | --- |')
    foreach ($pkg in $Packages) {
        $desc = if ($pkg.Description) { $pkg.Description -replace '\|', '\|' -replace "`r?`n", ' ' } else { '' }
        $pkgLink = "$PackageLinkBase$($pkg.Name)/"
        [void]$sb.AppendLine("| [**$($pkg.Name)**]($pkgLink) | $desc |")
    }
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('## License')
    [void]$sb.AppendLine()
    [void]$sb.AppendLine('All packages are released under [MIT](https://github.com/sunamo/PlatformIndependentNuGetPackages/blob/master/LICENSE.txt).')
    return $sb.ToString()
}

# Per-package mini-landing page (standalone static HTML, copied verbatim into _site/{Package}/)
function New-MiniLandingHtml {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [string]$Description = ''
    )
    $descSafe = [System.Net.WebUtility]::HtmlEncode($Description)
    return @"
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>$Name — Sunamo NuGet Packages</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
  :root { color-scheme: light dark; }
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 760px; margin: 4rem auto; padding: 0 1.25rem; line-height: 1.55; color: #222; background: #fafafa; }
  .breadcrumb { font-size: .9rem; margin-bottom: 1.5rem; }
  .breadcrumb a { color: #4a76b8; text-decoration: none; }
  .breadcrumb a:hover { text-decoration: underline; }
  h1 { margin: 0 0 .35rem; font-size: 2.25rem; font-weight: 600; }
  .lead { color: #555; margin: 0 0 2.5rem; font-size: 1.05rem; }
  .actions { display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1rem; margin-bottom: 2rem; }
  a.btn { display: block; padding: 1.75rem 1.5rem; border-radius: 14px; text-decoration: none; border: 1px solid #d0d0d0; background: #fff; color: inherit; transition: transform .12s ease, border-color .12s ease, box-shadow .12s ease; }
  a.btn:hover { transform: translateY(-2px); border-color: #4a76b8; box-shadow: 0 6px 18px rgba(74, 118, 184, .12); }
  a.btn h2 { margin: 0 0 .4rem; font-size: 1.2rem; color: #4a76b8; font-weight: 600; }
  a.btn p { margin: 0; color: #555; font-size: .92rem; }
  .footer { margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid #e5e5e5; font-size: .9rem; color: #666; }
  .footer a { color: #4a76b8; text-decoration: none; margin-right: 1rem; }
  .footer a:hover { text-decoration: underline; }
  @media (prefers-color-scheme: dark) {
    body { background: #161616; color: #eaeaea; }
    .lead { color: #b3b3b3; }
    a.btn { background: #1f1f1f; border-color: #333; }
    a.btn h2 { color: #8ab4f8; }
    a.btn p { color: #b3b3b3; }
    a.btn:hover { border-color: #8ab4f8; box-shadow: 0 6px 18px rgba(138, 180, 248, .15); }
    .footer { border-color: #2a2a2a; color: #999; }
    .footer a { color: #8ab4f8; }
    .breadcrumb a { color: #8ab4f8; }
  }
</style>
</head>
<body>
  <nav class="breadcrumb"><a href="../">← All packages</a></nav>
  <h1>$Name</h1>
  <p class="lead">$descSafe</p>
  <div class="actions">
    <a class="btn" href="../api/$Name.html">
      <h2>API reference →</h2>
      <p>Auto-generated from source. Namespaces, types, members, signatures.</p>
    </a>
    <a class="btn" href="../guide/packages/$Name/">
      <h2>Guide →</h2>
      <p>Narrative documentation built from the package README.</p>
    </a>
  </div>
  <div class="footer">
    <a href="https://www.nuget.org/packages/$Name">NuGet</a>
    <a href="https://github.com/sunamo/$Name">GitHub source</a>
    <a href="../">All packages</a>
  </div>
</body>
</html>
"@
}

# 4. .docfx/index.md  — global landing, package name links to per-package mini-landing at /{Package}/
$docfxLanding = New-LandingMarkdown -Packages $packages -PackageLinkBase ''
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

# 6. .mkdocs/docs/index.md  — package name links to mini-landing one level up from /guide/
$mkdocsLanding = New-LandingMarkdown -Packages $packages -PackageLinkBase '../'
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

# 8. Per-package mini-landing HTML pages (copied into _site/{Package}/ by the workflow)
$landingsDir = Join-Path $repoRoot '.landings'
New-Item -ItemType Directory -Force -Path $landingsDir | Out-Null
foreach ($pkg in $packages) {
    $pkgDir = Join-Path $landingsDir $pkg.Name
    New-Item -ItemType Directory -Force -Path $pkgDir | Out-Null
    $html = New-MiniLandingHtml -Name $pkg.Name -Description $pkg.Description
    Set-Content -LiteralPath (Join-Path $pkgDir 'index.html') -Value $html -Encoding UTF8
}
Write-Host "Wrote $($packages.Count) mini-landing pages under .landings/"

# 9. Remove stale per-package files for packages that no longer exist
$validNames = @{}
foreach ($pkg in $packages) { $validNames[$pkg.Name] = $true }
Get-ChildItem -LiteralPath $mkdocsPkgs -Filter '*.md' -File | ForEach-Object {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    if (-not $validNames.ContainsKey($base)) {
        Write-Host "Removing stale mkdocs page: $($_.Name)"
        Remove-Item -LiteralPath $_.FullName -Force
    }
}
Get-ChildItem -LiteralPath $landingsDir -Directory | ForEach-Object {
    if (-not $validNames.ContainsKey($_.Name)) {
        Write-Host "Removing stale landing: $($_.Name)"
        Remove-Item -LiteralPath $_.FullName -Recurse -Force
    }
}

Write-Host "`nDone."
