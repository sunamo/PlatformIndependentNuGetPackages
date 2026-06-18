#Requires -Version 5.1
# Generates .net48/ folder with Net48 wrapper .csproj for each non-impossible submodule
# and PlatformIndependentNuGetPackages.Net48.slnx

$base = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$net48Dir = Join-Path $base ".net48"
$slnxPath = Join-Path $base "PlatformIndependentNuGetPackages.Net48.slnx"

# ─── impossible: no Net48 version possible ───────────────────────────────────
$impossible = [ordered]@{
    "SunamoLogging"             = "SunamoLogging\SunamoLogging\SunamoLogging.csproj"
    "SunamoPlatformUwpInterop"  = "SunamoPlatformUwpInterop\SunamoPlatformUwpInterop\SunamoPlatformUwpInterop.csproj"
    "SunamoMathpix"             = "SunamoMathpix\SunamoMathpix\SunamoMathpix.csproj"
    "SunamoPS"                  = "SunamoPS\SunamoPS\SunamoPS.csproj"
    "SunamoSelenium"            = "SunamoSelenium\SunamoSelenium\SunamoSelenium.csproj"
}

# ─── version downgrade map for net48 ─────────────────────────────────────────
$versionMap = @{
    "Microsoft.Extensions.Logging.Abstractions"         = "8.0.0"
    "Microsoft.Extensions.Logging"                      = "8.0.0"
    "Microsoft.Extensions.Logging.Console"              = "8.0.0"
    "Microsoft.Extensions.DependencyInjection"          = "8.0.0"
    "Microsoft.Extensions.DependencyInjection.Abstractions" = "8.0.0"
    "Microsoft.Extensions.Configuration.Json"           = "8.0.0"
    "System.Text.Json"                                  = "8.0.0"
    "System.Text.Encodings.Web"                         = "8.0.0"
    "System.Formats.Asn1"                               = "8.0.0"
    "System.Text.Encoding.CodePages"                    = "8.0.0"
    "System.Security.Permissions"                       = "8.0.0"
    "System.Security.Cryptography.ProtectedData"        = "8.0.0"
    "System.Management"                                 = "6.0.0"
    "Microsoft.Data.SqlClient"                          = "5.2.1"
    "Microsoft.EntityFrameworkCore"                     = "3.1.32"
    "Microsoft.EntityFrameworkCore.Relational"          = "3.1.32"
    "sharpconfig"                                       = "3.2.9.1"
}

# ─── packages with no net48 alternative (TODO comment) ───────────────────────
$todoPackages = @{}

# ─── project definitions: Name -> @("Package|Version", ...) ──────────────────
# Format: "PackageName|Version"  or  "PackageName"  (version from versionMap or TODO)
# Packages that are build-only (SourceLink, test runners) are omitted
$projects = [ordered]@{
    # Logging.Abstractions 9.0.0: Mscc.GenerativeAI 2.0.0 transitively requires >= 9.0.0 (NU1605)
    "SunamoAI"                        = @("Mscc.GenerativeAI|2.0.0", "Microsoft.Extensions.Logging.Abstractions|9.0.0")
    "SunamoArgs"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoAsync"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoAttributes"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoAzureDevOpsApi"            = @("Microsoft.TeamFoundationServer.Client|19.225.2", "Microsoft.VisualStudio.Services.Client|19.225.2", "Newtonsoft.Json|13.0.4", "Microsoft.Extensions.Logging.Abstractions", "System.Data.SqlClient|4.9.0")
    "SunamoBazosCrawler"              = @("HtmlAgilityPack|1.12.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoBts"                       = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoChar"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCl"                        = @("Microsoft.Extensions.Logging.Abstractions", "System.Collections.Immutable|8.0.0", "CommandLineParser|2.9.1", "Microsoft.Extensions.Configuration.Json", "Microsoft.Extensions.DependencyInjection", "Microsoft.Extensions.DependencyInjection.Abstractions", "Microsoft.Extensions.Logging", "Microsoft.Extensions.Logging.Console", "ShellProgressBar|5.2.0", "TextCopy|6.2.1")
    "SunamoClearScript"               = @("Microsoft.ClearScript.Core|7.5.0", "Microsoft.ClearScript.V8|7.5.0", "Microsoft.ClearScript.V8.Native.win-x86|7.5.0", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoClipboard"                 = @("Microsoft.Extensions.Logging.Abstractions", "TextCopy|6.2.1")
    "SunamoCollectionOnDrive"         = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollections"               = @("Diacritics|4.1.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionsChangeContent"  = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionsGeneric"        = @("Microsoft.Extensions.Logging.Abstractions", "System.Collections.Immutable|8.0.0")
    "SunamoCollectionsIndexesWithNull"= @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionsNonGeneric"     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionsTo"             = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionsValuesTableGrid"= @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCollectionWithoutDuplicates"= @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoColors"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCompare"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoConverters"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCrypt"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCsproj"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCssGenerator"              = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoCsv"                       = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoData"                      = @("Newtonsoft.Json|13.0.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoDateTime"                  = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDebugCollection"           = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDebugging"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDebugIO"                   = @("TextCopy|6.2.1", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoDelegates"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDependencyInjection"       = @("Microsoft.Extensions.Logging.Abstractions")
    # CaseDotNet.Extensions 0.2.46: 0.3.36 does not exist on nuget.org (NU1102)
    "SunamoDevCode"                   = @("CaseDotNet|0.3.36", "CaseDotNet.Extensions|0.2.46", "Diacritics|4.1.4", "Google.Apis.Core|1.68.0", "HtmlAgilityPack|1.12.4", "Microsoft.Extensions.Logging.Abstractions", "ResXResourceReader.NetStandard|1.1.1", "TextCopy|6.2.1")
    "SunamoDictionary"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDotnetCmdBuilder"          = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoDotNetZip"                 = @("System.Security.Permissions", "System.Text.Encoding.CodePages", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoEditorConfig"              = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoEmbeddedResources"         = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoEmoticons"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoEnums"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoEnumsHelper"               = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoExceptions"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoExtensions"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoFileExtensions"            = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoFileIO"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoFilesIndex"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoFileSystem"                = @("Diacritics|4.1.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoFluentFtp"                 = @("FluentFTP|51.0.0", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoFtp"                       = @("Ftp.dll|2.0.25239.1915", "System.Formats.Asn1", "System.Text.Encodings.Web", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoGetFiles"                  = @("Microsoft.Extensions.Logging", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoGetFolders"                = @("Microsoft.Extensions.Logging.Abstractions", "System.Text.Encodings.Web", "WildcardMatch|1.0.7")
    "SunamoGitConfig"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoGoogleMyMaps"              = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoGoogleSheets"              = @("Google.Apis.Auth|1.73.0", "Google.Apis.Sheets.v4|1.73.0.4061", "Google.Apis.Drive.v3|1.73.0.3987", "Microsoft.Extensions.Logging.Abstractions")
    # SharpGPX 2.22.302: last netstandard2.0 version (2.25.x is netstandard2.1-only, NU1202)
    # SmartFormat.NET 3.6.1: 3.7.3 does not exist on nuget.org (NU1102)
    "SunamoGpx"                       = @("BlueToque.SharpGPX|2.22.302", "Microsoft.Extensions.Logging.Abstractions", "Geo|1.0.0", "SmartFormat.NET|3.6.1")
    "SunamoHtml"                      = @("Microsoft.Extensions.Logging.Abstractions", "HtmlAgilityPack|1.12.4", "TextCopy|6.2.1")
    "SunamoHttp"                      = @("Microsoft.AspNetCore.Http|2.3.9", "Microsoft.Extensions.Logging", "Microsoft.Extensions.Logging.Abstractions", "System.Text.Encodings.Web")
    "SunamoIni"                       = @("sharpconfig", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoInterfaces"                = @("HtmlAgilityPack|1.12.4", "Newtonsoft.Json|13.0.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoJson"                      = @("Microsoft.Extensions.Logging.Abstractions", "Newtonsoft.Json|13.0.4")
    "SunamoLang"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoLaTeX"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoMail"                      = @("Microsoft.Extensions.Logging.Abstractions", "MailKit|4.14.1", "Microsoft.Extensions.Logging", "MimeKit|4.15.1", "System.Text.Json")
    # Html2Markdown 5.1.0.703: last version with netstandard2.0 (7.x is net8.0-only, NU1202)
    "SunamoMarkdown"                  = @("Html2Markdown|5.1.0.703", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoMime"                      = @("FileSignatures|5.0.0", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoMsgReader"                 = @("MsgReader|6.0.6", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoMsSqlServer"               = @("Microsoft.Data.SqlClient", "Microsoft.EntityFrameworkCore", "Microsoft.EntityFrameworkCore.Relational", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoNuGetProtocol"             = @("Microsoft.Extensions.Logging.Abstractions", "NuGet.Protocol|7.0.1", "System.Formats.Asn1", "System.Text.Encodings.Web")
    "SunamoNumbers"                   = @("Microsoft.Extensions.Logging.Abstractions", "xunit|2.9.3")
    "SunamoOctokit"                   = @("Octokit|14.0.0", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoPackageJson"               = @("Newtonsoft.Json|13.0.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoParsing"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoPaths"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoPercentCalculator"         = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoPInvoke"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoRandom"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoReflection"                = @("System.Collections.Immutable|8.0.0", "ObjectDumper.NET|4.3.2", "YamlDotNet|16.3.0", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoRegex"                     = @("Microsoft.Extensions.Logging.Abstractions", "xunit|2.9.3")
    "SunamoResult"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoRobotsTxt"                 = @("Microsoft.Extensions.Logging.Abstractions")
    # 9.0.0 versions: Microsoft.CodeAnalysis.Workspaces.MSBuild 5.0.0 transitively requires >= 9.0.0 (NU1605)
    "SunamoRoslyn"                    = @("Microsoft.CodeAnalysis|5.0.0", "Microsoft.CodeAnalysis.CSharp|5.0.0", "Microsoft.CodeAnalysis.CSharp.Scripting|5.0.0", "Microsoft.CodeAnalysis.CSharp.Workspaces|5.0.0", "Microsoft.CodeAnalysis.Workspaces.MSBuild|5.0.0", "System.Formats.Asn1|9.0.0", "System.Text.Encodings.Web|9.0.0", "System.Text.Json|9.0.0", "Microsoft.Extensions.Logging.Abstractions|9.0.0")
    "SunamoRss"                       = @("Microsoft.SyndicationFeed.ReaderWriter|1.0.2")
    "SunamoRuleset"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoSecurity"                  = @("System.Security.Cryptography.ProtectedData", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoSerializer"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoShared"                    = @("Microsoft.Extensions.Logging.Abstractions", "Diacritics|4.1.4", "Newtonsoft.Json|13.0.4", "System.Security.Cryptography.ProtectedData")
    "SunamoStopwatch"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoString"                    = @("Microsoft.Extensions.Logging.Abstractions", "Diacritics|4.1.4")
    "SunamoStringFormat"              = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringGetLines"            = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringGetString"           = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringJoin"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringJoinPairs"           = @()
    "SunamoStringParts"               = @("Microsoft.Extensions.Logging.Abstractions", "System.Collections.Immutable|8.0.0")
    "SunamoStringReplace"             = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringSplit"               = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringSubstring"           = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoStringTrim"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTest"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoText"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTextIndexing"              = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTextOutputGenerator"       = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoThisApp"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoThread"                    = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoThreading"                 = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTidy"                      = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoToUnixLineEnding"          = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTwoWayDictionary"          = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoTypes"                     = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoUnderscore"                = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoUri"                       = @("CaseDotNet|0.3.36", "Diacritics|4.1.4", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoUriWebServices"            = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoValues"                    = @("Microsoft.Extensions.Logging.Abstractions")
    # MixERP.Net.VCards 1.0.7: 1.2.0 does not exist on nuget.org (NU1102)
    "SunamoVcf"                       = @("MixERP.Net.VCards|1.0.7", "System.Text.Encodings.Web", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoWikipedia"                 = @("Microsoft.Extensions.Logging.Abstractions", "HtmlAgilityPack|1.12.4")
    "SunamoWinStd"                    = @("Microsoft.Extensions.Logging.Abstractions", "System.Management", "TextCopy|6.2.1")
    "SunamoXlfKeys"                   = @("Microsoft.Extensions.Logging.Abstractions")
    "SunamoXliffParser"               = @("System.Collections.Immutable|8.0.0", "ResXResourceReader.NetStandard|1.1.1", "Microsoft.Extensions.Logging.Abstractions")
    "SunamoXml"                       = @("Microsoft.Extensions.Logging.Abstractions", "System.Collections.Immutable|8.0.0")
    "SunamoYaml"                      = @("Microsoft.Extensions.Logging.Abstractions", "YamlDotNet|16.3.0")
    "SunamoYouTube"                   = @("Google.Apis.YouTube.v3|1.68.0", "Microsoft.Extensions.Logging.Abstractions")
}

# ─── helpers ──────────────────────────────────────────────────────────────────
function Resolve-PackageRef {
    param([string]$spec)

    if ($spec -match '^(.+)\|(.+)$') {
        $name    = $Matches[1]
        $version = $Matches[2]
    } else {
        $name    = $spec
        $version = $null
    }

    # Apply version downgrade map only when no explicit version is given
    # (explicit version wins - e.g. SunamoAI/SunamoRoslyn need 9.0.0, NU1605)
    if (-not $version -and $versionMap.ContainsKey($name)) {
        $version = $versionMap[$name]
    }

    if ($todoPackages.ContainsKey($name)) {
        $comment = $todoPackages[$name]
        if ($version) {
            return "    <!-- $comment -->`n    <PackageReference Include=`"$name`" Version=`"$version`" />"
        } else {
            return "    <!-- $comment -->`n    <!-- <PackageReference Include=`"$name`" Version=`"REPLACE`" /> -->"
        }
    }

    if ($version) {
        return "    <PackageReference Include=`"$name`" Version=`"$version`" />"
    } else {
        return "    <!-- WARNING: unknown version for $name -->`n    <PackageReference Include=`"$name`" Version=`"FIXME`" />"
    }
}

function Get-OriginalCompileItems {
    # Mirrors compile item configuration from the original csproj:
    # - Removes: <Compile Remove="..."> (e.g. SunamoExceptions ThrowExOther.cs -> CS0111)
    # - Includes: <Compile Include="..."> (re-included files or explicit whitelist)
    # - ExplicitOnly: original has EnableDefaultCompileItems=false (e.g. SunamoArgs whitelist)
    param([string]$projectName)

    $result = @{ Removes = @(); Includes = @(); ExplicitOnly = $false }
    $originalCsproj = Join-Path $base "$projectName\$projectName\$projectName.csproj"
    if (-not (Test-Path $originalCsproj)) { return $result }

    $xml = [xml](Get-Content $originalCsproj -Raw)
    foreach ($propertyGroup in @($xml.Project.PropertyGroup)) {
        if ("$($propertyGroup.EnableDefaultCompileItems)".Trim() -eq 'false') {
            $result.ExplicitOnly = $true
        }
    }
    foreach ($itemGroup in @($xml.Project.ItemGroup)) {
        foreach ($compile in @($itemGroup.Compile)) {
            if ($null -eq $compile) { continue }
            if ($compile.Remove)  { $result.Removes  += $compile.Remove }
            if ($compile.Include) { $result.Includes += $compile.Include }
        }
    }
    return $result
}

function New-Net48Csproj {
    param([string]$projectName, [string[]]$packages)

    $sourceRelPath = "..\$projectName\$projectName"
    $pkgLines = ($packages | ForEach-Object { Resolve-PackageRef $_ }) -join "`n"
    $pkgBlock = if ($pkgLines.Trim()) {
        "  <ItemGroup>`n$pkgLines`n  </ItemGroup>`n"
    } else { "" }

    $compileItems = Get-OriginalCompileItems $projectName

    if ($compileItems.ExplicitOnly) {
        # original whitelists files explicitly - mirror the same list
        $compileLines = ($compileItems.Includes | ForEach-Object {
            "    <Compile Include=`"$sourceRelPath\$_`" />"
        }) -join "`n"
    } else {
        $excludes = @("$sourceRelPath\obj\**\*", "$sourceRelPath\bin\**\*")
        foreach ($remove in $compileItems.Removes) {
            $excludes += "$sourceRelPath\$remove"
        }
        $excludeAttr = $excludes -join ';'
        $compileLines = @(
            "    <Compile Include=`"$sourceRelPath\**\*.cs`""
            "             Exclude=`"$excludeAttr`" />"
        )
        # re-include files the original adds back from removed folders
        foreach ($include in $compileItems.Includes) {
            $compileLines += "    <Compile Include=`"$sourceRelPath\$include`" />"
        }
        $compileLines = $compileLines -join "`n"
    }

    return @"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net48</TargetFramework>
    <LangVersion>latest</LangVersion>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <AssemblyName>$projectName</AssemblyName>
    <RootNamespace>$projectName</RootNamespace>
    <EnableDefaultCompileItems>false</EnableDefaultCompileItems>
    <IsPackable>false</IsPackable>
    <DefineConstants>`$(DefineConstants);ASYNC</DefineConstants>
  </PropertyGroup>

  <ItemGroup>
$compileLines
  </ItemGroup>

$pkgBlock</Project>
"@
}

# ─── run ──────────────────────────────────────────────────────────────────────
New-Item -ItemType Directory -Force $net48Dir | Out-Null

# Directory.Build.props - per-project obj/bin + shared references for all wrappers
$directoryBuildPropsContent = @'
<Project>
  <!-- All Net48 wrapper csproj live in this single folder. Without per-project
       obj/bin paths their project.assets.json overwrite each other and projects
       get compiled against another project's package references. -->
  <PropertyGroup>
    <BaseIntermediateOutputPath>obj\$(MSBuildProjectName)\</BaseIntermediateOutputPath>
    <BaseOutputPath>bin\$(MSBuildProjectName)\</BaseOutputPath>
  </PropertyGroup>

  <ItemGroup>
    <!-- net48 framework assemblies that SDK-style projects do not reference implicitly -->
    <Reference Include="Microsoft.CSharp" />
    <Reference Include="System.Net.Http" />
    <Reference Include="System.Web" />
  </ItemGroup>

  <ItemGroup>
    <!-- implicit usings on net48 do not include System.Net.Http (sources rely on it from net8+) -->
    <Using Include="System.Net.Http" />
  </ItemGroup>

  <ItemGroup>
    <!-- source-generated polyfills: Index/Range, init, required, nullable attributes,
         SupportedOSPlatform, CallerArgumentExpression, interpolated string handler, ... -->
    <PackageReference Include="PolySharp" Version="1.15.0" PrivateAssets="all" />
  </ItemGroup>
</Project>
'@

Set-Content (Join-Path $net48Dir "Directory.Build.props") $directoryBuildPropsContent -Encoding UTF8
Write-Host "Created Directory.Build.props"

# generate per-project csproj files
$createdCount = 0
foreach ($name in $projects.Keys) {
    $csprojPath = Join-Path $net48Dir "$name.Net48.csproj"
    $content = New-Net48Csproj -projectName $name -packages $projects[$name]
    Set-Content $csprojPath $content -Encoding UTF8
    $createdCount++
}
Write-Host "Created $createdCount Net48 .csproj files"

# ─── generate .slnx ───────────────────────────────────────────────────────────
$slnxLines = @('<Solution>')

foreach ($name in $projects.Keys) {
    $slnxLines += "  <Project Path=`".net48\$name.Net48.csproj`" />"
}

$slnxLines += ""
$slnxLines += "  <!-- impossible: no net48 version possible (SunamoLogging, SunamoPlatformUwpInterop, SunamoMathpix, SunamoPS, SunamoSelenium) - intentionally not included -->"

$slnxLines += '</Solution>'

Set-Content $slnxPath ($slnxLines -join "`n") -Encoding UTF8
Write-Host "Created PlatformIndependentNuGetPackages.Net48.slnx"
Write-Host ""
Write-Host "Done. Summary:"
Write-Host "  Net48 projects : $createdCount"
Write-Host "  Impossible      : $($impossible.Count) (original csproj in slnx)"
Write-Host "  Output dir      : $net48Dir"
