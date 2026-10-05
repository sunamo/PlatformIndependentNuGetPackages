---
schema_version: 11
type: real-app
category_override: none
file_count: 1567
file_extensions: txt:853, ps1:198, csproj:146, md:139, cs:15, json:15, js:11, noext:8, yml:6, slnx:5, bat:3, props:2, sh:2, 1:1, backup:1, backup_20250730_155445:1, backup_20250730_173610:1, backup_mainpathfix_20250730_175225:1, backup_pathfix_20250730_175138:1, jancikappdatalocaltempclaude-0b6c-cwd:1, ruleset:1, template:1
file_extensions_updated: 2026-10-04
avg_lines_per_file: 170
total_lines: 32420
metrics_lm: 2026-10-01 16:40:22
move_to_legacy_percent: 2
description_updated: 2026-10-01
links_updated: 2026-10-01
github_source_url: not found
origin_status: found
origin_checked: 2026-10-01
article_source_url: not run
article_status: pending
article_checked: not run
last_build_ok: no
last_build_date: 2026-10-02
last_tests_run_date: not run
covered_lines: not run
---

## Description

Sbírka sdílených NuGet balíčků `Sunamo*` pro všechny aplikace a zařízení. Rodičovské repo drží asi 155 balíčků jako git submoduly, sady `.net48` projektů, skripty pro správu řešení, dokumentaci (DocFX a MkDocs publikované přes GitHub Actions) a pomocné dávkové soubory. Samotný kód balíčků žije v submodulech, ne přímo v tomto repu.

## Původ zdrojáků

Staženo z GitHubu: **ne** — vlastní knihovny uživatele, repo patří účtu `sunamo` (GitHub) a `.gitmodules` míří z 151 submodulů na `git@github.com:sunamo/...` a ze 4 (SunamoComgate, SunamoPayments, SunamoTesseract, SunamoYt) na vlastní Azure DevOps `sunamocz`.

- Ověřeno: `git remote -v` (`git@github.com:sunamo/PlatformIndependentNuGetPackages.git`, vlastní účet), `git log` (2691 commitů od 2024-07-10, autoři Radek Jancik/Radek Jančík/smutekutek/sunamo.cz), `.gitmodules` (155 submodulů: 151 z `github.com:sunamo`, 4 z Azure DevOps `sunamocz`).
- `gh search repos "PlatformIndependentNuGetPackages"` vrátil jen vlastní repa `sunamo/*` (SunamoDevCodeCore, SunamoToNetCore, SunamoCodeGenerator, SunamoMsBuild, SunamoCSharp, SunamoSolutionsIndexer), žádné cizí; hash porovnání proto nebylo potřeba.

## Doporučení přesunu do legacy

Doporučení přesunu do sunamocz-legacy.visualstudio.com: **2 %** — nepřesouvat, je to centrální sbírka sdílených knihoven, na které stojí ostatní projekty.

- Aktivní (poslední commity 2026-09-30) a s dlouhou historií (2691 commitů).
- Odkazují na něj submoduly i konzumující aplikace.
- V rootu jsou dočasné soubory (build výstupy, dávky `_batches`, `_modernized_done`, skripty), které by šlo uklidit, ale nejsou důvodem k mazání.

## Vazby na moje repa

- Submoduly: `SunamoAI`, `SunamoAps`, `SunamoArgs`, `SunamoAsync`, `SunamoAttributes`, `SunamoAzureDevOpsApi`, `SunamoBazosCrawler`, `SunamoBitLockerManager`, `SunamoBts`, `SunamoCSharp`, `SunamoChar`, `SunamoCl`, `SunamoClearScript`, `SunamoClipboard`, `SunamoCodeGenerator`, `SunamoCollectionOnDrive`, `SunamoCollectionWithoutDuplicates`, `SunamoCollections`, `SunamoCollectionsChangeContent`, `SunamoCollectionsGeneric`, `SunamoCollectionsIndexesWithNull`, `SunamoCollectionsNonGeneric`, `SunamoCollectionsTo`, `SunamoCollectionsValuesTableGrid`, `SunamoColors`, `SunamoComgate`, `SunamoCompare`, `SunamoConverters`, `SunamoCrypt`, `SunamoCryptAlgorithms`, `SunamoCsproj`, `SunamoCssGenerator`, `SunamoCsv`, `SunamoData`, `SunamoDateTime`, `SunamoDebugCollection`, `SunamoDebugIO`, `SunamoDebugging`, `SunamoDelegates`, `SunamoDependencyInjection`, `SunamoDevCodeBase`, `SunamoDevCodeCore`, `SunamoDevCodeFileFormats`, `SunamoDictionary`, `SunamoDotNetZip`, `SunamoDotnetCmdBuilder`, `SunamoEditorConfig`, `SunamoEmbeddedResources`, `SunamoEmoticons`, `SunamoEntity`, `SunamoEnums`, `SunamoEnumsHelper`, `SunamoEssential`, `SunamoExceptions`, `SunamoExtensions`, `SunamoFileExtensions`, `SunamoFileIO`, `SunamoFileSystem`, `SunamoFilesIndex`, `SunamoFluentFtp`, `SunamoFtp`, `SunamoGenerators`, `SunamoGeo`, `SunamoGetFiles`, `SunamoGetFolders`, `SunamoGitConfig`, `SunamoGoPayApi`, `SunamoGoogleMyMaps`, `SunamoGoogleSheets`, `SunamoGpx`, `SunamoHelpers`, `SunamoHtml`, `SunamoHttp`, `SunamoIco`, `SunamoIni`, `SunamoInterfaces`, `SunamoJson`, `SunamoLaTeX`, `SunamoLang`, `SunamoLazy`, `SunamoLogging`, `SunamoMail`, `SunamoMarkdown`, `SunamoMathpix`, `SunamoMime`, `SunamoMsBuild`, `SunamoMsSqlLegacy`, `SunamoMsSqlServer`, `SunamoMsgReader`, `SunamoNTextCat`, `SunamoNuGetProtocol`, `SunamoNumbers`, `SunamoOctokit`, `SunamoPInvoke`, `SunamoPS`, `SunamoPackageJson`, `SunamoParsing`, `SunamoPaths`, `SunamoPayments`, `SunamoPercentCalculator`, `SunamoPerformance`, `SunamoPlatformUwpInterop`, `SunamoRL`, `SunamoRandom`, `SunamoReflection`, `SunamoRegex`, `SunamoResult`, `SunamoRobotsTxt`, `SunamoRoslyn`, `SunamoRss`, `SunamoRuleset`, `SunamoSE`, `SunamoSecurity`, `SunamoSelenium`, `SunamoSerializer`, `SunamoSharedMisc`, `SunamoSlnGen`, `SunamoSolutionsIndexer`, `SunamoStopwatch`, `SunamoStorage`, `SunamoStreams`, `SunamoString`, `SunamoStringFormat`, `SunamoStringGetLines`, `SunamoStringGetString`, `SunamoStringJoin`, `SunamoStringJoinPairs`, `SunamoStringParts`, `SunamoStringReplace`, `SunamoStringSplit`, `SunamoStringSubstring`, `SunamoStringTrim`, `SunamoTesseract`, `SunamoTest`, `SunamoText`, `SunamoTextIndexing`, `SunamoTextOutputGenerator`, `SunamoThisApp`, `SunamoThread`, `SunamoThreading`, `SunamoTidy`, `SunamoToNetCore`, `SunamoToUnixLineEnding`, `SunamoTranslate`, `SunamoTwoWayDictionary`, `SunamoTypes`, `SunamoUnderscore`, `SunamoUri`, `SunamoUriWebServices`, `SunamoValues`, `SunamoVcf`, `SunamoWikipedia`, `SunamoWinStd`, `SunamoXlfKeys`, `SunamoXliffParser`, `SunamoXml`, `SunamoYaml`, `SunamoYouTube`, `SunamoYt`
- ProjectReference / PackageReference: žádné
