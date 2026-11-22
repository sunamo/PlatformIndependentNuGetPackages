# Commits that removed code and Czech comments from .cs files

Purpose: when removed code is needed again, find it in the commit listed here (`git show <hash>` or `git log -p <hash> -- <file>`).

Commit messages (fixed, keep identical in every repo), all made 2026-11-20:

- `remove: zakomentovaný kód ze souborů .cs` — removed commented-out code
- `remove: české komentáře, ponechány jen anglické` — removed `// CZ:` lines and the `EN:` prefix
- `refactor: české komentáře přeloženy do angličtiny` — translated the remaining Czech comments (and `/// EN:`/`/// CZ:` pairs) to English; the Czech originals are in the parent of this commit

Find a commit by message in any repo: `git log --grep="zakomentovaný kód ze souborů"`.

| Repo (`.` = this parent repo) | Commented-out code removed | Czech comments removed | Czech comments translated |
|---|---|---|---|
| . | caa42405b8aee1ae133c150e897dbd1325a119af | a66f8c3a8aeb27034f8b152512a6d5d76bf581cc | 09fd095df2946b0906fc3175921bd2a872f3cf96 |
| SunamoAI | d157883e31e7a1f30645ecf3b5fc7f519fb51814 | - | - |
| SunamoAps | 94e8d4d76ac82d2941eff7125e394b9d28e58808 | 2aead393d707080f11a34bea7faba6c17b6426fe | 4f14de5bdf169975d48ef2be16c20b02b98c2252 |
| SunamoArgs | - | - | 244b9dd1ca19a413205b78f5889a87658a89f3ae |
| SunamoBitLockerManager | - | - | e5bffda39e776f23b9d8a1b4a7b55abbceb9358d |
| SunamoCl | cd9e1cbd737fc416c4f9e035bead79fd3c768e21 | 781e64e5ce2da153bbd28e353775c557ae6477d8 | 19a4e6555f6279310b4222d96f70d752ff169bd0 |
| SunamoCodeGenerator | 045bd272916ec899ec9d0e31d388b8aa765e75eb | 6f84cf31bde3db7778e4862495b1ba46e9bbd24b | - |
| SunamoCollectionOnDrive | eb7cdd44701888513b7a6390dd53260b92d7ceb9 | - | - |
| SunamoCollections | 7440a0ae3d80b42a2d69b0f306d3742beae31b37 | - | c811c441b919548ddc439d43a6129b7fcb168275 |
| SunamoCollectionsValuesTableGrid | - | d3a978cb69e739cb97897111c0f23601da44d6c3 | - |
| SunamoColors | 605b2077d64a6cfd31b453caba6e49c73efe433d | 86ec55a41a1ed7ca3f86582e6a5affa0f3ac051d | - |
| SunamoComgate | ff2d6985572ac1f2c8105270887a544038a431c7 | - | cceca1a58ca6ed049d90e92b558dcdf5074919e8 |
| SunamoCompare | - | 023e6ea72a056a94b14e96c16421e40dd436cf05 | - |
| SunamoConverters | bafd003b9dfb90f9eed9ce7fc562e674e6b2ec27 | 7ddaf954a4b0df90509c0e222a96c1d870528ff0 | - |
| SunamoCrypt | 0d9044cf646fa395ac571c4d195058f13eda20b2 | 64865bb3a92fa483b3cdb86bc69e3dcfb0bf5081 | - |
| SunamoCryptAlgorithms | - | 91182f192be1afac780a8624e648ef493150a6d8 | - |
| SunamoCSharp | 3e84b695248c83e7444510f7d6462123a178102b | e3b79bd670e7e44726e4a65dccb083953aa4a2cc | 908a821f20f19d046edaa2225dd500374b75a509 |
| SunamoCsproj | 5b29e44c4de2c93d67e54fbcdf4cc30fdafedb55 | 499051ea3164b753b0beb2197b1334197f538a96 | 808efc6bf25c3e03b69b0818c530460c53981ee9 |
| SunamoCssGenerator | - | cfb002634a1d24fdf397e62d1c9c233c4de02b74 | - |
| SunamoCsv | f8d00f43591fdba6c292c4a27eafa96153bdc611 | - | 665f00162995f03a1c2a19ffba31b5eb807ed0a4 |
| SunamoData | 6795e40bbba9a9e6621c41c83e050da4057c16f1 | a7811c107179fd965c6f52c6174f9a164e010aca | 6ec6996b03198db9993b11584b94b15eb8e1d549 |
| SunamoDateTime | ef1d8057e666ca6e81ac2703166fff56e0617998 | 8be2a97b8ea8072e1ea026072f5fb28822ef1611 | 1da040b77e1e96074bca7c5fb295474b5c869c3c |
| SunamoDebugCollection | - | be597f29ae25552f6051e1e84c93eed7f1b66817 | - |
| SunamoDebugIO | 38b27cb5084ae95daced0370d0b225adde0a1acf | - | 906f15347d168083f0fc971a957130149187218c |
| SunamoDelegates | - | 70a2b9d1b6fde5a6f66f635e3e08b37d1ebe930b | - |
| SunamoDependencyInjection | - | 9ef1f3a67932531464239a11c83a729a8adfbff5 | - |
| SunamoDevCodeBase | 1ab8e1fbdd5445c8a82d11eaacb587febe73a768 | 0817970a096ffbb3ac9ba0e33b3a5ba8168677db | 19dad81443fa0a5e1b55151faacf08dcf0afe9a9 |
| SunamoDevCodeCore | 5c13787d45878c978b73aeb85af8991f36e80140 | 0d35da2ba1b2ae6e43ada21dfce421066115442e | c45e2c3381b955bfd82328f44aa46e7dc6db8162 |
| SunamoDevCodeFileFormats | 9f2b4d075805782555fd7bb886dedfd47fd9941c | 9486252e9ce89d938ec8a42e91f6e21399636cfd | 1ad397ae095451bb5f5ed8f380cdd9d790b7a0a6 |
| SunamoDotnetCmdBuilder | - | 670f5ba3a22ed8acec91a58401e7a7843ef6e918 | - |
| SunamoDotNetZip | f3f5d94f86b19cf38a7e4b383d386443e4b5dd39 | 166e5f160c5262db1fb00231cb488415a5a3a962 | - |
| SunamoEntity | - | a85beef496abbdbe2b86e5059972dac29907c6eb | - |
| SunamoEnums | 249ecd998fb16b0fdd4cad34f78c6e9cc8e9f849 | 79e5667a9acbdd926aafecd0e38c2afe3997109c | a56ba87054d46fd6efa14485ea3f17daa30a89e8 |
| SunamoEssential | 00424ba227d61a3f40f1a45633434b4cd4f9944f | fb834a86e66ff40ab341a12677ec87e7c4a7d8ad | 8a163a730d655f4ad8681d374307bdaba4d87e15 |
| SunamoExceptions | eae3811733261e3104c30b122311bbadeda58bf2 | 3dfeb5d8b8b2bc763688450ccc44cdbb54048591 | - |
| SunamoExtensions | - | - | 7f48399eb65d8ceac998ccd6dcdafef219593530 |
| SunamoFileIO | - | 27fd9abafdcefc68430a1ef49197da314b94eb64 | ba646204f4f4dec275e3f4e77b655044ba11b5e7 |
| SunamoFilesIndex | 8a463d533f7a2c01463d99007eade10b204ba935 | - | - |
| SunamoFileSystem | c52805d5184d213ab920a6f35f4423262a553567 | adf18167a6e56851c50d16ea33ad89fe0fe6da1e | 1d3b5abfee419d09e380f4324d9659faa9b57aff |
| SunamoFtp | bd059e254e75520da913bfbc10ecc2797fd1eeb0 | - | dbc86b167a471bc1c863d27c5a336bf23c8c3867 |
| SunamoGenerators | - | 2a4a905397e90974792b57c956dba06600e99627 | - |
| SunamoGeo | - | 3797b885f67e43d609c3e6edd3df5628a51aca5f | c2e922b8fe08ad61b77306d55f3e8a7a90f8a0bb |
| SunamoGetFolders | c605e941bbefdc1ab345d458bdf61a7371af3c32 | - | - |
| SunamoGitConfig | - | a47cda5bd6eb56966ce2f4fb9b3cf7d4573606b0 | - |
| SunamoGoogleSheets | ed8c317b4643a61c93b42065b6baf56c3299cff6 | 9612b1e35ef5e0cdcd4e6607602f8b4cb1d3d721 | 35c2a44adfc26b222f5147e9a6ffdaeaaccdc5e9 |
| SunamoGoPayApi | b510afd6477adf5ef3d3a03c3283be0035565e31 | - | 391e985a51106561c8a34e627b2318c24a43a465 |
| SunamoHelpers | - | ee6e34e29bb9bce2a47d72b3751b6cf1ea23ed5e | - |
| SunamoHtml | 7f3a95765a2e9292d9cf64c16c0de86e5b8a3eed | 82afa757a8f09d54040013458a1805ca6ceec084 | 7617bdf4fb31feac6ee89a08fb271700500b888c |
| SunamoHttp | de751df08b8b904ceedd0600a9b89abd969f5feb | - | - |
| SunamoInterfaces | 41fb5d4a17fe7e0309af3c7e0ecb7881e6e06f11 | - | - |
| SunamoLogging | - | - | a54cf1031f8d1f28d8996c9dfced0103026ef618 |
| SunamoMsSqlLegacy | c684f5262f442d458bf1d88b96408dc1a1589afb | - | 6ad3ca2dab82fbf7bdd3938534e0ecac3de9e0b2 |
| SunamoNTextCat | f3fd7212b1b1ca1b327ff9b30c2805fde597c3d5 | - | 33e5001fcb89af5c76d4b662da058f63ce1df716 |
| SunamoPaths | - | - | 110c0c7e7815e4ad6360087cc6c1b9dc8614036b |
| SunamoPayments | ea3c48ca4180aea390988c275274179550553285 | - | ce8e75bcb458b6eac75e1172e8015a94908c879b |
| SunamoRL | - | 1c247287af6f2d8c85878934308b252bfd5ed329 | 9e831bfacccf4e1a298aa44f14186f917c113e1a |
| SunamoRoslyn | 26e76ffbf9394c2b6eac1bc41be02f90885b52e7 | - | - |
| SunamoSE | b52173b847cbc1d77c3f1fbfa6b16a278bf380fa | - | - |
| SunamoSharedMisc | - | 59b16926cc2e55755b4d430e34fa273431e922c0 | - |
| SunamoSolutionsIndexer | d64b6d5fa09b060e10865afdd202b92bbc8166fd | e2ae5c610ea709e17c7c72feaa925ddba62ffde7 | 08d97038d0551e63ca8f88148c6657ecf5b3f9fc |
| SunamoStorage | - | 80ebe0fcddacb1ddef9d5b98a8245afa6d524f8a | - |
| SunamoString | - | e4d825c7839de3d9e797331040e92d4dead00665 | - |
| SunamoTesseract | b1484351a9fb2d1f9872926746bcfd5712e369a4 | - | 6f248282956555f08e4b203794603725c5d08feb |
| SunamoThisApp | a128c771ea98c6c40efeffa8dff76c650ee78128 | - | - |
| SunamoToNetCore | be32db38c01a529347f541c7e9392479a1e94724 | 955ef84bc34755484bffec8718290f46258aac26 | f455c4c6f955970881c37f3a5d872afd3a72ac4c |
| SunamoTranslate | 80aca12368745e4273971fda1ff9ca331f84afcc | - | d799d75abcc51b818ac1cb80cfcff5250911ef28 |
| SunamoUri | - | - | 9b520eb765d1f1b13dcd2d64b7cd53ab55961082 |
| SunamoUriWebServices | - | d208847891c906e63e7b4124ded6741fee59a402 | e2fba371e517153da4a8a59363ec39aa9380cabd |
| SunamoValues | 34bfd618a791fdf01bf30cdc7ae4947d72037bf2 | - | 1c9450216d71bb7777059965bcbd7ad3fab4c9db |
| SunamoWinStd | f57f1728ceeac506e095fd1c309bc4b310583d73 | - | - |
| SunamoXml | - | - | 01aa9629d8371dd58e6d60658621cffaa5fc0700 |
| SunamoYt | a78c2a9875ec87e51ea6f451bcd492bfc704420f | - | 7516d2d5b6402411e8b6a6ec6255236462117a37 |

## Further cleanup commits (2026-11-20)

Same rules: find by message with `git log --grep="<message>"`.

### `chore: pracovní marker kontroly názvů proměnných přesunut do evidence`

marker `// variables names: ok` removed from code, files listed in `.docs/variable-names-checked.md`

| Repo | Commit |
|---|---|
| . | 49612c17323de87d17f4ce53197486a69779bad1 |
| SunamoAI | 7bc4c9d3616fd5d55f5c6a964df74322d6abb392 |
| SunamoAps | a3837cd27482260f13041d677c49c9c82389f237 |
| SunamoArgs | c3891bd75a778661d5b6b1bd133430e4a2221881 |
| SunamoAsync | dbe1b741911c7ad0945df81c03fa7f1af141cafd |
| SunamoAttributes | 6be03961e13c54229ac6c58c5580ed4768c2f330 |
| SunamoAzureDevOpsApi | c2cb6a0b9b5c003ef8a81827202dfbb3e73f90e7 |
| SunamoBazosCrawler | e2ee2f3db0fb9b7fee9978a612c720e1e79cf7d9 |
| SunamoBitLockerManager | 0caddcf464e5e8132892f461b82aa5393ab6d1be |
| SunamoBts | 308010b86a04fab8ac11acae3a9f4f7946e337e5 |
| SunamoChar | e3d63f61afa17b9e2b2b946f1acfcf2909aa8b9a |
| SunamoCl | 4b0cc265589eb85d98d065200c0ea2f30595b459 |
| SunamoClearScript | 3612be63db99a63677405396778e1de299ba2187 |
| SunamoClipboard | 4c7ae78732337727a08fca0acce244fac6c5269e |
| SunamoCollectionOnDrive | 4107e9174f76ccb12e845280f8500f51d9650a86 |
| SunamoCollections | 528ab5077baf3fb1fc5e70aa41364e1b78ef87b0 |
| SunamoCollectionsChangeContent | f91fb99f92cf989fac233917ba7086ad50052fcd |
| SunamoCollectionsGeneric | 808345485a4fb4b8756ffddd1d0ea13aca465012 |
| SunamoCollectionsIndexesWithNull | 006e58d597ffe7673f5cb6ad8d0411e00a2f31f6 |
| SunamoCollectionsNonGeneric | 97f4b61aba3e981430d9065055a539b8433322e5 |
| SunamoCollectionsTo | 28e6eea60dcadf1a1f67e9cc1ec3a13adf2c8439 |
| SunamoCollectionsValuesTableGrid | 2e542fff9683ab5fdf2a54ea8d80b8a16155e699 |
| SunamoCollectionWithoutDuplicates | d1f5754d6c9724a0beaec0182f0d49c4f76e6bcf |
| SunamoColors | 52e4bfcf7d606033627f4988866877b0e0fb6670 |
| SunamoCompare | 0028d0823974df4773e334fef518812a1758bc63 |
| SunamoConverters | c3b0635f8e24a321f7bfbe797715f16945dda30f |
| SunamoCrypt | 127c75ace1402eb9f3a01ad794b7e18fe5d71876 |
| SunamoCryptAlgorithms | 13c857513a76cafd3918f96623721a3193b0ca40 |
| SunamoCSharp | 290fbb48cb0562a05485afd4da2117500fdb1e49 |
| SunamoCsproj | 4dd64f5270b5d6e0bfee1e5dc562f251aac8d1d6 |
| SunamoCssGenerator | 7a458a461deb593053ca7cc762e90062e2dee623 |
| SunamoCsv | 9eec70c09508cd4210aaae82062a6e9093097e98 |
| SunamoData | 9f55ae322d2c1f271ec122435e039cadc7f0e74c |
| SunamoDateTime | fd2437af047aeed4efac77b43aa22e3adb5ba807 |
| SunamoDebugCollection | 720e306cf4f1eab88449c7d5d8299eec0f9ebf37 |
| SunamoDebugging | 18237a1a93b7d531bae14957d2928762dc78c6b9 |
| SunamoDebugIO | 52f1c59a2570fc8ab3b8ee66ca0a9c8530edeb8c |
| SunamoDelegates | 9ad39a91ff396c63b66d1f5fa8ac61793437e47e |
| SunamoDependencyInjection | 29307985b540a475f4293dd3d6dc021dbb089a33 |
| SunamoDevCodeBase | be832c0cac35e1e224c47a9fea025c4862468357 |
| SunamoDevCodeCore | ac7fe92d3b061964054f53d6fde1a6df2f55b0f3 |
| SunamoDevCodeFileFormats | cfea04ceeeeb4d5c4f556fd950e9dfd76ed898f3 |
| SunamoDictionary | fa3d317c179ac94e5b291f0f4bb2f31aa5db9e9d |
| SunamoDotnetCmdBuilder | f65f1f45d0a84f925a5508ee01a8ff0d674b4a4d |
| SunamoDotNetZip | 3920c8986c266d83d543a41fe2b539f8fc988fd2 |
| SunamoEditorConfig | 4dded5e9e577493cec2bf0b39ecedff0330d9de3 |
| SunamoEmbeddedResources | c3ebb87b24330b91564ee7aa1beffd9a05529db1 |
| SunamoEmoticons | 9fd981b032ee7f623b6d57e7b1459228a80c54cc |
| SunamoEntity | 690bd38da19653035d5cdd84804ed24cee585726 |
| SunamoEnums | ff518c79d5198b320347955776933bf0e4cd09c6 |
| SunamoEnumsHelper | 6ac8cfbeedeaea1a4eb6365b18c30e6bd9f5c319 |
| SunamoEssential | ace29ecd4e01f175c057246dddd2813bb9414042 |
| SunamoExceptions | 88052382feae2301049e3b654c58a39b192482c6 |
| SunamoExtensions | 8ae65c7099a1e971828272202533efff4c948111 |
| SunamoFileExtensions | 59640961ab84af2db20edad7e8dd93b8d5c21a55 |
| SunamoFileIO | 643e5f4be3fe32b7ace6fa03831a615a90ebc736 |
| SunamoFilesIndex | 482355350a355b4aab0c485eb0f2eb6a74cc9a0f |
| SunamoFileSystem | 747377944e7f5085bcb828adc484655f02b5c41a |
| SunamoFluentFtp | 22ce25e470f939dc89cbfef195efcbe5188cb431 |
| SunamoFtp | 3468f431dadc2946b624c20219be18f338520f86 |
| SunamoGenerators | e22fbc3d1501425619c829e5d22a2634439efbd4 |
| SunamoGeo | 61e8fc6b4e2196d3223fd44af00ca94915340b80 |
| SunamoGetFiles | c9fa4721fdd376ff850194ee00b51f83f500e7de |
| SunamoGetFolders | 0d998f6eba5076c8d75df04144bc57d575b84ec6 |
| SunamoGitConfig | 3c3db8ae64a01cf0628846ed9e3770f4aeba034b |
| SunamoGoogleMyMaps | 947f6bc48e1d78c257b4adcc9b9c0b221845cb88 |
| SunamoGoogleSheets | 1ffa48840459581b1173b528c3b5d91ee5885930 |
| SunamoGpx | ee88a9a070174a92496f1f55fdf616b6e5929bfa |
| SunamoHelpers | 57743e47d1c6385344576d4ce079070d178edda1 |
| SunamoHtml | 0d858f9b041efb3973e748f2dbc77b308dc0d714 |
| SunamoHttp | d3fde02b6f62c9510eb7187dde0f993ffc540af2 |
| SunamoIni | 1f1eecc873b334af4d8d46a6db605fd872afb6a6 |
| SunamoInterfaces | 6d62dcbcd942893604033d7853a95da31bf83a0d |
| SunamoLazy | 35292666b1256400fc1e159ef76786ed7e693128 |
| SunamoMarkdown | 94cde08da47d9578cb07ad0b0177854e2f8a3cdb |
| SunamoPerformance | fb00d4e7392da85a40af99c633e9892732c015df |
| SunamoPlatformUwpInterop | 522d794dc9538654219bc37f55ec3841b87b6f70 |
| SunamoPS | 27a16b36d77bb93eefdca4f8602108e231cc1bd3 |
| SunamoRL | 7d4ceb1ea0191d8ed3c6fba81a051c13938fcab5 |
| SunamoRuleset | 448cf22c66f276b03581cc2e8959324b6969948a |
| SunamoSE | a1c86afd6e7d1002ddaac0c862f83bad2bf9c0c0 |
| SunamoSharedMisc | 4a38bf80fe21918cee74251ee93438370e98f285 |
| SunamoSolutionsIndexer | cfc57e0968f02e77dda12b758a579afaaac85953 |
| SunamoStorage | 00535cc9b027ad13628b1832519fc787c3cf66ba |
| SunamoStreams | f9f780ad96cdf09b6dc44b47cbb0edd96d453c3c |
| SunamoString | 5aac23f68253f3b3f0beaf1e4e1f806a38e584e4 |
| SunamoStringGetLines | 93ad2f35d5136e7b4bc66dbba98623b68a4eb791 |
| SunamoTest | dac82b98fcde6afe8cfe83b4fe9da106618aeb22 |
| SunamoThread | 152e8744947834519e86def05e04e17f9cae20f7 |
| SunamoThreading | d5c480093e30327e250fd32f2fa172c6917976b7 |
| SunamoTidy | d088ea974a3e237af9a016436fa4f8f3bbd48e59 |
| SunamoToNetCore | a7a1163dad4c4f1fcdb3de4aa48b5aa430e4393e |
| SunamoToUnixLineEnding | 2663f477d9bb81a241b3f7ea7230f8bc89c30e75 |
| SunamoTwoWayDictionary | 58e42b3296e5ef1c6c87fec29c61fbc6190a4b4e |
| SunamoTypes | 690713a32c75ba8e77caad3f5bc359c3bd514d7e |
| SunamoUnderscore | 34b3e7e6c8290da54412638a1bb08c42037292a9 |
| SunamoUri | 5f47573a589fff51e75a7b181ffb9554011524c9 |
| SunamoUriWebServices | f11d44882cc2f1f829a633e35a194e7b990b9669 |
| SunamoValues | a27c877d4d4c441085fc40f88436101a96bab2ad |

### `chore: úprava csproj balíčků (optimalizace, README, SourceLink, poznámky k vydání)`

removed `Optimize=false` and junk `PackageReleaseNotes`, added missing docs file/SourceLink/readme reference

| Repo | Commit |
|---|---|
| SunamoAI | 0a802d50e270028b01c94ee6e8bf3a89da688faf |
| SunamoAps | 09a022f0c0e627e6b0652f351d7c5d217149e04c |
| SunamoArgs | 5ad4020fbba46455bf648de0665c51df007dec73 |
| SunamoAsync | 26eb51a0c9e704cb6411489728a6fcbc2355034f |
| SunamoAttributes | c29405c6cae44d2844c35021c883905e6a497fce |
| SunamoAzureDevOpsApi | 4aacfb96c69be43213401fe5a77c8fd388734332 |
| SunamoBazosCrawler | 432bc4422e2162a2d24ba4a7390b5aa6c870e2ab |
| SunamoBitLockerManager | 8c3d4721e9ad4d4f5fc2c6ae48c2d5a78b6c775a |
| SunamoBts | 81419f995c7c8e5884fdbce4e5b2dd8f63baa0dd |
| SunamoChar | 2978a0051cf8894b43e1693df3efa27cd2eabe56 |
| SunamoCl | 2287ca9d925d7e8ccba85ded80ccf369424dec30 |
| SunamoClearScript | 2b0710f691edca80f555fb8da9766db0b1a171ea |
| SunamoClipboard | f0412ce4827a5c515652d37ea680dd38f8e7523b |
| SunamoCodeGenerator | 43a64e843fba75cca9eb6511ebfbd10f6a3e9c27 |
| SunamoCollectionOnDrive | 99cb9f3ef8695bdf2b0ca380ace9a3d534c72099 |
| SunamoCollections | 3b7c4652beea3700d39d89c3addcfc4c8ea830c5 |
| SunamoCollectionsChangeContent | 5fc31edca1fa567c04b1bca4094801ce96a04f52 |
| SunamoCollectionsGeneric | b253d061299bddc5c05e166bca863ccea0401b3d |
| SunamoCollectionsIndexesWithNull | a60318771617f1efa0f1265b37b26a595d6633ad |
| SunamoCollectionsNonGeneric | e89c285acf971b6e7d9e6559323489ac077ecd97 |
| SunamoCollectionsTo | 012a62e50eed5849292ff53a0a150e945fc2c79d |
| SunamoCollectionsValuesTableGrid | 902f74868d23276745ab47f14eee7b8e67336377 |
| SunamoCollectionWithoutDuplicates | 28ae1ea0787c62528f3bbbf2de4fb4a5efe1f063 |
| SunamoColors | e800acc0b965f8521e0e6d12ece4ac59366f51df |
| SunamoComgate | 202775dca930f30253d0968bfdd4850ff8b72cc6 |
| SunamoCompare | a4f438f1742726bd374fee6456dc143dc453be78 |
| SunamoConverters | 49c2875120c092154e60633484853d7cff4aece5 |
| SunamoCrypt | 68555a48db604a9d9cff33b76d358ef4889e2f88 |
| SunamoCryptAlgorithms | e82f4086ea1c6dcdfb309b496fb7af4403212a22 |
| SunamoCSharp | 27ff9e9869e22f5240dfe14c91a05dc3081f5de1 |
| SunamoCsproj | 021c801901ca575c72b230e53c59237283352788 |
| SunamoCssGenerator | 4fd6f2428baf02e2ebaf5593b02f553bb5abd781 |
| SunamoCsv | c83ce7fe8d8fdfa80948c3510d5ca764f636b0f8 |
| SunamoData | f2b06fb2de0d56c49e0f81b589e9de3f31e258b2 |
| SunamoDateTime | bf21dbe4f67362089e553e61838fca0cc8fab075 |
| SunamoDebugCollection | 1b03c13a2b5e9998d8bb085612f0b3e3fdbd1feb |
| SunamoDebugging | 79478b1910d114132bd0214f627271c32177fe0b |
| SunamoDebugIO | a25c19fa94d59b4b7618f6495699ac164c201ad5 |
| SunamoDelegates | 7e32b610d0543fe9e925bba2d802e3eed065a411 |
| SunamoDependencyInjection | fbdfe11004d3ea6822d4e97007e8ef4c89d0fe62 |
| SunamoDevCodeBase | 68d696c76981b0b1b632d88635f6d0053665808f |
| SunamoDevCodeCore | d5aa960b3cd4246bb9c715ffeb3795b6b6d24855 |
| SunamoDevCodeFileFormats | 79b880adf6ea4c3d49825c63ba2c4556a497a0f8 |
| SunamoDictionary | 54d93d577ab8b3241c5000fb1b0b79d21cb80969 |
| SunamoDotnetCmdBuilder | ff44ddbe94f3b76d719275badadcb4576f10f1f9 |
| SunamoDotNetZip | 1ff416d490e8a2dbc6bd2f8658f2eb70b09a0679 |
| SunamoEditorConfig | 3fe589954a4a170857b652e00895669a700742ec |
| SunamoEmbeddedResources | 40834b052ce6459070db95d929abb411143274da |
| SunamoEmoticons | fbc1d965a55e311250a3e9b4b14c40f0b46dbc18 |
| SunamoEntity | 6889f60ab55d5c5b8c6f23f9ce46049387c02967 |
| SunamoEnums | 8215449bb3914cde4b2c5c39a52943b649e06698 |
| SunamoEnumsHelper | e2ce4127c15d483cc2c4afb458ca3c26d21f3bb2 |
| SunamoEssential | 179aafe223664450622654ec0c34f37aeb81ab27 |
| SunamoExceptions | 16b3248f6aae9e6817da47d9483d3bb13682314b |
| SunamoExtensions | 2fe898347f57fa59d23fab81966b1e9cf27b9992 |
| SunamoFileExtensions | 2eb5cd1a326630ccd10b87fd40e80a9d8f1758a9 |
| SunamoFileIO | 0bcdbc3ae2513b0a7dbe5a9f56dab860ebef47ea |
| SunamoFilesIndex | d750157e4e695ee5127371a62194eb9934d4574b |
| SunamoFileSystem | 48627683be7695dea69a9039bce171309b50bd21 |
| SunamoFluentFtp | ed3e6c1769796ecd5913574b762a9d74e36ccced |
| SunamoFtp | 33ad2de6ed6db9639284a4ad2fb3f3d63d62d1d3 |
| SunamoGenerators | a693986c05821f8bbaeeea80a5b70d26e4bb3f9f |
| SunamoGeo | 9ec09b442cb2cbbe30d60b5931d775ff0dfe4b91 |
| SunamoGetFiles | d41d4f5b3f7ffed3818b0aca67519672110c1134 |
| SunamoGetFolders | 16fb6ef3336937d4b7b6997dad12c6678f680b8a |
| SunamoGitConfig | e4033f9d4872d47d8ea1d9e2a088a37b2d32d0fb |
| SunamoGoogleMyMaps | 3f31b8c56296154e176b1cb3fb1c2a7bafac4db4 |
| SunamoGoogleSheets | 33e7b983d2236352daea1159979fc4410c8a8127 |
| SunamoGoPayApi | 358bb4147c4b524981dc44a15f14ab3cb9310dd3 |
| SunamoGpx | 015953665cec9851f3e995c2a023e6107f812584 |
| SunamoHelpers | 378264df871832eca44f2280c2438fd5b7bf8362 |
| SunamoHtml | 92255c5f3a8a742b770969a0e692fcb7510b8ce5 |
| SunamoHttp | 9ef4d8ebe4bbc29a8defc7f6e482ae24ab933aa8 |
| SunamoIni | eaf0dd89a58f3da0705b0563ae81e8bbe10b7e02 |
| SunamoInterfaces | 9208f1db6387d31902117d50033826ddf09b994e |
| SunamoJson | 156dad888651d0379dd8a89dcaefab94763a29f0 |
| SunamoLang | 6940b54b94eae3af3550b6b60cdb808f985a2c45 |
| SunamoLaTeX | 3b66cb7a56a7a4c46040cc702193f8a853e2d175 |
| SunamoLazy | 8f8e0b8b37de0255cc41b7d42f0db76ea0656a64 |
| SunamoLogging | 1ec425ea1944ece986cb0b8833518f6e2534be49 |
| SunamoMail | af823f313aabafabc7c5961cba562b050dfb4c27 |
| SunamoMarkdown | 469149bcaf9f58acc9e54e7f518a35ff1e51b29a |
| SunamoMathpix | 56c6e8a8a9854e730f1268e92252f6c32492e234 |
| SunamoMime | 961a33d687b9ef6e355ef31b4159ea995ffa7923 |
| SunamoMsBuild | 3f09807ef75bc118f2c5e6831b311bfecfb6b19f |
| SunamoMsgReader | 3ea89dabb989717358ab74194296d555bdbaa2ef |
| SunamoMsSqlLegacy | 0bfd65c5bff5846cdcfe2b585b25cfab7a853937 |
| SunamoMsSqlServer | b81605698c41505ff844dc4c20cb70af18e20f7a |
| SunamoNTextCat | 824fe68ce396f5562f499e994083b42e2e75d664 |
| SunamoNuGetProtocol | b50f81e497b36a86127f8ff75345de7d15f06ba1 |
| SunamoNumbers | cc737013564e3ece4d6b2abe4bfd6cc88be7a28c |
| SunamoOctokit | 80f2813027f45158b70c397b3930d3b109a35cd8 |
| SunamoPackageJson | 28b88d2a59e3fdb64c7458a086051c375953037f |
| SunamoParsing | b9cf117fc098bea4961e98b50b9b967391cee73c |
| SunamoPaths | f871b2c1046a756a27a7c6c324bcb585f42ce77f |
| SunamoPayments | 531c83a2849fe3df2e870c6900aa1e08c7f2a297 |
| SunamoPercentCalculator | 3023003c7ebfb9fabd5a64182907c92061e94c6a |
| SunamoPerformance | d8612c23e726a3ca04b2fa78aee3d8a2ce45ca63 |
| SunamoPInvoke | 9539def46b891d2ab1aa410cb215f8509cc7fe27 |
| SunamoPlatformUwpInterop | 43cdd7c17b973f65e3af62e6b6abf171f5cad335 |
| SunamoPS | 4cc4f58a4bd5aa528e299eaa0ceb27513c0930ae |
| SunamoRandom | 3e539d5f9f9516381c81cfd8ccac07c9f4a61e98 |
| SunamoReflection | 5998090b577afedcf3c857d89a4e0a3c1e8177b6 |
| SunamoRegex | 0758997910a439ae81684781b477ec14273beab3 |
| SunamoResult | 3b2394d334e8f05e254ec8e1cbf2e56c2658fa4e |
| SunamoRL | 56414201372fae2a4c8666348bf76fd6f571eb63 |
| SunamoRobotsTxt | f367525af1351981ea0fea1c5577487fa0e36b6f |
| SunamoRoslyn | 045f292c1e8cbda5a67c2f91498e6d62b5e6da08 |
| SunamoRss | 46958ed8377d22e4636c84075915d777dc21e666 |
| SunamoRuleset | 4a7d690d9723d9b677bee1a6783c4923fdbd940b |
| SunamoSE | b09ee571a93eaac4e32642741ffdecb720f72212 |
| SunamoSecurity | 1144b0e4f28511adb2596f518d28c17e4b0e226d |
| SunamoSelenium | 59a27c6e4321d11c760714399d132d2268fe4f82 |
| SunamoSerializer | b398234323078780618d64c67b864c4b3baeb630 |
| SunamoSharedMisc | 10cd27e59178265004b9c5cfeeb55053ca9e1f25 |
| SunamoSlnGen | 084c5085f7d322e54d21fd7e78f8cbc8c9986a68 |
| SunamoSolutionsIndexer | 47157ab433fd7d60edc265eb193353f36d781c34 |
| SunamoStopwatch | 12431571ae9ce111b98aca13528f97ada3021f17 |
| SunamoStorage | c041fff240c5bd733cd13aa0c3cde451b0479b4b |
| SunamoStreams | 42669663915a3e01ce5304030b36ca8b3fa8b574 |
| SunamoString | 12348d9bbee024740c6f34e75c4438b5557dae98 |
| SunamoStringFormat | 6e86400915000fc94289128053d183a32729f885 |
| SunamoStringGetLines | 789e14f303a5e0f7f265778077b89c2cf0fc13bb |
| SunamoStringGetString | 584826c79243e5aa222942ffe6d186c373994579 |
| SunamoStringJoin | 1590990860d450c66019a111c6e3bfb8ec11b8ab |
| SunamoStringJoinPairs | 1a95c02f3c6dcb0d59a0db7b85c8a600a5480146 |
| SunamoStringParts | f175de76f1beb3e13c404d203af8fe38105db0f2 |
| SunamoStringReplace | bd14602c0758a531a2bcdb23d07b030b665f6fa4 |
| SunamoStringSplit | 5a11e159e017eb7aea3a574c9c49dd388df8cdce |
| SunamoStringSubstring | 14d13d7de7e060a9717d7ce77372f30d59b8f0e8 |
| SunamoStringTrim | 7d88d1b2440cfa3343f780cffd895a04fd8fd427 |
| SunamoTesseract | a107ffdb0f862edf453e460ba9b72387457620de |
| SunamoTest | 40c50e0e349117fed0ec544aadd68c60fc894b49 |
| SunamoText | 863c706f9fdaf6e48768c74d5e113257ca03e079 |
| SunamoTextIndexing | b8c9c46aae0bda5ba9d2b94e1903ac75e49b0b8c |
| SunamoTextOutputGenerator | 60cf014854e87d23cee3dfbf4d259ab157a787f1 |
| SunamoThisApp | 755d2946a05bcb522ebaa385b89289dc09f9dce8 |
| SunamoThread | 2aa8215b905fa242df8be089bb2a53cd83a3ae26 |
| SunamoThreading | a8d23070948711a3c8be9431211cf5ae15610bed |
| SunamoTidy | 097bd26f327f3cab2cfef1002567af6dca83cc5c |
| SunamoToNetCore | 839c4b72fb9f1f99f484b07cd0746a7c5a9d0e3d |
| SunamoToUnixLineEnding | 2a4bf11bd3a5261abb87330e11480569fcdeca21 |
| SunamoTranslate | c24ab4a7a99685d36c4491f54d6e7a32e0727155 |
| SunamoTwoWayDictionary | c01cfb1559d6e182fc1555d7bf9678c1f25dec5c |
| SunamoTypes | f336fb88663eec78717f64da63b371e5024c15d1 |
| SunamoUnderscore | a6b95258e28edfa57215f7e711e8fd180f5b5bf2 |
| SunamoUri | d4cd92edf21e1d552c85be002a1cb9185f843d40 |
| SunamoUriWebServices | de7d50396b3c50bdc5f27ec8eaf9ed229eeba0e1 |
| SunamoValues | a99b099a6b13685e900273e070c9accae979a79c |
| SunamoVcf | 8eba9b11d9eac0803f8f06130710883084d139f3 |
| SunamoWikipedia | ba2d18a6902d810cac1c00881b3a0093dc332523 |
| SunamoWinStd | 2c274d7b159533bdf3b7c1c93c669de1e7f6690b |
| SunamoXlfKeys | fa233b5094d3d24eddf63f10945e480157c4732d |
| SunamoXliffParser | 02a7a3a4f30f19174ce5a49f9d421b02adf58cd4 |
| SunamoXml | a18fec2490b7b574fa3e68832eaf0e13f706219a |
| SunamoYaml | adeb1cac8132d58c166b0fca39f61347a7bc6544 |
| SunamoYouTube | 0c92cb049b5cdc6c78d3c68f3d1dc9f63f9fbce4 |
| SunamoYt | dd48f529237633ee52ed3f95ce34a3cd34ab18ac |

### `chore: doplněn README balíčku`

generated readme.md for packages that had none

| Repo | Commit |
|---|---|
| SunamoAps | f5397f0cb5e9b0191dcecda14975869a3f7573fb |
| SunamoCodeGenerator | 7676a8ff4d2879866b4bc0035c4e099bd80e8c2b |
| SunamoComgate | cf4858686cce135a05253f5c057c9cd859948df0 |
| SunamoCSharp | a01beb2544b5ade3ccae021824c105c6860b1504 |
| SunamoDevCodeBase | aa5bdb4cb805e4abed64cf1c27d6aa63357dc7b1 |
| SunamoDevCodeCore | b6d3c543c952ad9995ee90f4688f30e8c3228025 |
| SunamoDevCodeFileFormats | 2ce01c6c4ee1cdb4891ebd8fc746f64e9b95a5d4 |
| SunamoGoPayApi | 00592223c03942b792e3eb42129ee76b973b5cf5 |
| SunamoMsBuild | 9625be1d5dde9523b46a8af9c473fa22a4a606a7 |
| SunamoNTextCat | df5bc8187c071b6c4cc74bc6168fb55843508d5c |
| SunamoPayments | 9300f2fd8cf73c980d9a4adaba4fba7e83763272 |
| SunamoSlnGen | 29ae87dfd5ba529690f78549d400d766857c38d1 |
| SunamoSolutionsIndexer | 0c98f061128afb06c448c406e821ff949b097b1b |
| SunamoTesseract | b5320ef09e42146c1481a8127af6b26dd90b2b36 |
| SunamoToNetCore | 3810d55039c08ea4eea27e3aa2104ab69ba8274b |
| SunamoTranslate | e96c24852a2499fac7f2999fe93e697fe9643695 |
| SunamoYt | 7e42df700e21d423c64806fc8e9412cab6af10e2 |

### `build: aktualizace Microsoft.SourceLink.GitHub na 11.0.100 (oprava zranitelnosti)`

SourceLink 10.0.102 -> 11.0.100 (NU1902 vulnerability)

| Repo | Commit |
|---|---|
| SunamoAI | 90d7313b71779907d0d41fd9afd4bc2bc542dc4c |
| SunamoAps | 6a0e50fe4c42317229f4e4a0fd75c3f3bcc2656a |
| SunamoArgs | 63e23b0a2523869b2c6b53a8a81e403d2651bb58 |
| SunamoAsync | bbaa6b9382dbf6f04cf02b54c9fcb44405fe8efb |
| SunamoAttributes | b068a3d088f8243873bbd9e2b76e8a9c43d03378 |
| SunamoAzureDevOpsApi | b279997e92bde5d415db6f93a46eccba0794cf95 |
| SunamoBazosCrawler | 273d1f62a55200e505935b7e5bd24899d41815a8 |
| SunamoBitLockerManager | 2ba60e797251fc1df250210608b8a2a27d126da7 |
| SunamoBts | 3819487a0f6e9d0dadbce7d6966f5b25e8809afe |
| SunamoChar | 44b2943dba5289c56ed84b7b6511e80f4f6c236e |
| SunamoCl | 76083b383af2071aedccd1a8830dca1eca5b1878 |
| SunamoClearScript | a5626fccc15644dcc668fa6a7e3f0b6d6589bc2f |
| SunamoClipboard | 46c3d49299ac07a2e00feade335752eb5e4fed83 |
| SunamoCodeGenerator | 1c3d81d85d6fe362fa1f7f97971a668a668b6a8c |
| SunamoCollectionOnDrive | abd0f45402a23040fc23699691bb6305d4c55a23 |
| SunamoCollections | 59772c2e6fbd1e4f496e1a01afe7d19105cb10da |
| SunamoCollectionsChangeContent | a15bef2aa01a9cd4683fcbcdc1cba39273cf829f |
| SunamoCollectionsGeneric | 2bcedf1bff552104af5346e415c199c055bf665b |
| SunamoCollectionsIndexesWithNull | ca0c1d6d08f3b8814ac5b9b6638fa8652bfbcecc |
| SunamoCollectionsNonGeneric | ea276c479d8b53b4e3a3c5d123013325466415fe |
| SunamoCollectionsTo | 77805e86af43a14cd61d6fcb37d4eb51c15ba523 |
| SunamoCollectionsValuesTableGrid | 842d0857c3f30ee44260ba9608be40ebb0826644 |
| SunamoCollectionWithoutDuplicates | 9cb1525b767e898017342614cdfbe5eb6264fdc8 |
| SunamoColors | d2e04f25bcb807cba39e4d2cce354a2f9e841862 |
| SunamoComgate | 90a7a33ce6686405509bbe0167f5e0d3d92d9b4d |
| SunamoCompare | feae222107aadd81a88458a4ba93c53502502f46 |
| SunamoConverters | 1953e2ef9e3527110f6de36571837f1362cf7155 |
| SunamoCrypt | fb6b39cc7b7cde0829f5a1baa816e2d30f5adfe1 |
| SunamoCryptAlgorithms | ff3808594b7ca3bf54595b4aa3afc9a7e38c8a62 |
| SunamoCSharp | f35b263fbacf36e692d9697f70e4d4832a97fb30 |
| SunamoCsproj | df4fce106f482ec0a33c54f429f7f1c4f14321fd |
| SunamoCssGenerator | 2507301b44326e4a5ff246b9975e7bac4e858968 |
| SunamoCsv | 931e904f67defb9dc8528a104c937e8b87bb178f |
| SunamoData | 4060982e469641bdf098fb1fe2d40c92fa3ea9e6 |
| SunamoDateTime | 4cadb32e4c7368ef56b09e71082d4f6a4834fca6 |
| SunamoDebugCollection | 79a1ad42289feed63fd68e9c4e7e37617de8d11e |
| SunamoDebugging | 431dc478b5995067f622ea2ec3a7f9745dac08e5 |
| SunamoDebugIO | 3ef1df8b9a0e43dfe5ccdffa4656be1c888df509 |
| SunamoDelegates | 946e0d4064233e6b2315093c091d3547981c9f95 |
| SunamoDependencyInjection | ee582696c5eb667b05ef17f39db37616077a8a92 |
| SunamoDevCodeBase | fc7e87367d3a503f6ffa9af9a1ce70a8bf8857f6 |
| SunamoDevCodeCore | d77949631bb994cb459a5eae5b83421baf236067 |
| SunamoDevCodeFileFormats | b962b537c96a9e55adfa29dbc93da6d6fd8b3ef2 |
| SunamoDictionary | 239416dc5515680f53d665a931e5240a79b154a2 |
| SunamoDotnetCmdBuilder | 83f5f27398d0a830b1d4d4ab83b7946f42d204f1 |
| SunamoDotNetZip | c5a605a1772dd1315ed945d541dee44eb6b3c0d1 |
| SunamoEditorConfig | f0724e331c345ca4a34a6aa522a73317d9d0fb7f |
| SunamoEmbeddedResources | 3e319fbba02e3ce8c203216c9483cda05dc257d0 |
| SunamoEmoticons | b85a0cd0623b8292e7bfedc5e4658ad19a396849 |
| SunamoEntity | facb798f162eebb089a6eae770bbb76d4a3eca47 |
| SunamoEnums | 62c95d85e577ffb5ef64b158735e735e4b0652d4 |
| SunamoEnumsHelper | 857a86e96c7b87987eac316ebeedffb434c0823c |
| SunamoEssential | 8bd668361bb5e21a6d0c81b5d972608619609c13 |
| SunamoExceptions | ac1c5ae620f7dc5dacbbefa348c80ed881d15604 |
| SunamoExtensions | 0bc6c483b691f23edc64194410da8959c911d916 |
| SunamoFileExtensions | b188633b968c1a6f1ab7064e4ed1087ef261bbd7 |
| SunamoFileIO | 149d4f9bc63d672e2ad0e42b7017f1a55b8efb79 |
| SunamoFilesIndex | f274f911bbd92c68fd3ac6a18da802b8af9fc0e9 |
| SunamoFileSystem | d069ede0428b55afa55b7d8485370297a6eb3f61 |
| SunamoFluentFtp | f21e8c33365756171405c4d7e6454e25e1229e4c |
| SunamoFtp | 9762936e2f059e58629812c91f3f10ea3e69aec2 |
| SunamoGenerators | f3d74518908538b859890482b25d962623e6deef |
| SunamoGeo | af134eeaab81cb1dd33ebfe9d32a5c072085b162 |
| SunamoGetFiles | 28966b0fe994325b9c766e7184679fbcb9a3eccd |
| SunamoGetFolders | 57890f40d4dc35470caf120b2239bb00793fc3ca |
| SunamoGitConfig | 8b1370388cde46797d66c0200bca08beac756742 |
| SunamoGoogleMyMaps | d602294986370fe878e4974afabd73339182954f |
| SunamoGoPayApi | 02257407c6e31700103299cbc124c4b4ff9b94ae |
| SunamoGpx | f827b7d806347a3f61fc3cb32f2b486da1b8bb16 |
| SunamoHelpers | 855fc13823b5405a4e2bc43b4a5f1c9f0a53156e |
| SunamoHtml | f2c5c79974cf4eae15f605199d30cd294e85fcf6 |
| SunamoHttp | a064f69737dc28d80ab88dbee7e0862deaa19267 |
| SunamoIni | 132b4ede55535680ec8a84a329145438c5f8dedd |
| SunamoInterfaces | adc5c406d040b6c17bb5542d8af6ac2f389ff442 |
| SunamoJson | 1458ee3e0038900278b6eeafc6791545727ebb16 |
| SunamoLang | 82ab222e76ea67b30831a6c8d35310066b0878bf |
| SunamoLaTeX | e61df3a5ce334a940f06e535b74bb558f65d68ed |
| SunamoLazy | 8c346fb1cc5d1854f46c14d07f68a74adbb8f8b7 |
| SunamoLogging | 09769456065bc943db99dffcfc83eb1457f6a97a |
| SunamoMail | 4ebfa9c57c8f74c5c2937726866799875476f8b9 |
| SunamoMarkdown | 25b24115ac6ca6f205ccb3fc6bcebdeda5a77730 |
| SunamoMathpix | 5982a8afadcb3a5481cb22ae48de793af114d49a |
| SunamoMime | 023d37678b17c5a9a26273e7d0f863280c59f566 |
| SunamoMsBuild | 89dd1ea8e32aa6138bf27225efe300107cb6f589 |
| SunamoMsgReader | 7b5dd2474198f375b050d833d194e0029b18cd5a |
| SunamoMsSqlLegacy | 07d546d22c052df4a2b15a659a6b3ac6ac73b0ae |
| SunamoMsSqlServer | 74ce0899e1b36798911060bce73b6d8b50be17b6 |
| SunamoNTextCat | 6622b80e69bf751e5165e070d5662f45ec2102db |
| SunamoNuGetProtocol | 4571d7afb8c063c1bb052cd681b530f8e29a9a5e |
| SunamoNumbers | 1b2f13e5294ead4bbf503466108edff5dbc252d0 |
| SunamoOctokit | fd073a340c3b830f3a54ec794f458d7a80329110 |
| SunamoPackageJson | e3bab1689a4d532f41419c12d758320390f77184 |
| SunamoParsing | 59b1eca23a3bf3096f7b90108ad42a8700d0300b |
| SunamoPaths | 7b94f7031a72bf0491bf037a0787a9de161db1d6 |
| SunamoPayments | 798a6d227dad74758967d05fd28697b563ec3d2d |
| SunamoPercentCalculator | 88e95464c2a915d72847bb389469f382df12ece6 |
| SunamoPerformance | 0da7bb9834c2c082f8a647936e5ec2e33bb601c1 |
| SunamoPInvoke | fece96f491a6952907691d351496f008164a0a47 |
| SunamoPlatformUwpInterop | 07b3eda9eb8068889e01470e01f5243b762ae0cc |
| SunamoPS | f63477ce2ff8ed8ca82da77278622f9563af03c3 |
| SunamoRandom | 0a49cd57652c397e6844e89c3a2bb0f4fe8457ff |
| SunamoReflection | 6313ba2d85bd99bc5d1f966667bd737ac7dc7781 |
| SunamoRegex | 8b4a4b809d96c6162e6f82e8f620a6274199acef |
| SunamoResult | bb30abb1dd42a15573b58dd6b4b91311c4f3dd2b |
| SunamoRL | 177817fc695fbc548d792e264a306bc4a1e0b73a |
| SunamoRobotsTxt | 0398f296135d62645dd645b46e3891b51fa8c1e4 |
| SunamoRoslyn | b0a05e8119254aced55702d54ee8ed9087de7133 |
| SunamoRss | a9d1c082b2e16258a4ad54ffff05d7d782b8daa9 |
| SunamoRuleset | aa931a42ef78184ed353fec96e88def0abf79f78 |
| SunamoSE | 707af413a0b4b3e450f4b43cc62eba68ae6722e4 |
| SunamoSecurity | 08e15c84a9043f0874b2de3b3b689055e6e4f0ea |
| SunamoSelenium | e8d60d7694c8032504e7113ff104d94b2dc502a7 |
| SunamoSerializer | 5a76c2d8710c51e9ab38d4e64dfa48a3d94faa4d |
| SunamoSharedMisc | b0dd489c24e2a32ea38c00c5e43dddce969d57d4 |
| SunamoSlnGen | 3a9a0cfc3ca40289668557e59ef6df78dcd7af42 |
| SunamoSolutionsIndexer | c8aeb91686f802c55f32647dcd65bcd73615c878 |
| SunamoStopwatch | 2198492bbc661c7844ac52c6ac7d9a1e569428a3 |
| SunamoStorage | 6ddf64b8da93af3318957753c8de85273a1b9077 |
| SunamoStreams | 69327874dd99933075b13c0bd39b18d0a3f3a665 |
| SunamoString | df4e90a85c86289279941de7182f184d9239e3d6 |
| SunamoStringFormat | fb1aec1f5a542fb8db248c48db0ab06d37b31e92 |
| SunamoStringGetLines | d1a4c38705bdfd6440d37c568948eea90bafcabd |
| SunamoStringGetString | 8c6068d11652fea7526f0c971bf70a90b0dea4ef |
| SunamoStringJoin | cac06930a0439970511a6fa5d2ce0f7e82f74201 |
| SunamoStringJoinPairs | 824d39ed16a1e33e718a24c13e6f24c4d9f40e79 |
| SunamoStringParts | f88aa26bc1718b9aad19641012cdeaa30c86cd6f |
| SunamoStringReplace | bf47d0abc4c541d6fa345a1386d81cc028814ef0 |
| SunamoStringSplit | a5a583b99f8b7962012ac750cfda00ab7e724563 |
| SunamoStringSubstring | 58a4bcece15d304bbb05dbd02612f8a1bd81ad63 |
| SunamoStringTrim | 596f95b549032b1bc13bb19463f132c118f1f353 |
| SunamoTesseract | 8c8b7c7ecbab6fbee1793a492ec0217d0c705302 |
| SunamoTest | 3e999767c80833286a2b26033544ba9a7ab89afc |
| SunamoText | aa1de9e7028f13833ed4b81f664cfc383cd24728 |
| SunamoTextIndexing | 03474cfdb63c6255feae80a199aa845e07ea676d |
| SunamoTextOutputGenerator | 96107eeaf71dd0f668380261eb51aa61b565e9a6 |
| SunamoThisApp | a9235d1a106221d6ed1d4a65e628cb1d725fd818 |
| SunamoThread | ed24c0ef4a7525da1ec45a1c077347ab152c791c |
| SunamoThreading | adbfd916b347df190c0be39deb2a321d35a4abe6 |
| SunamoTidy | 232bdf881aaf1305bed2736d4f8c38f89cbcd6e2 |
| SunamoToNetCore | 805edef4209ea9facdfe08b787528b3151896b04 |
| SunamoToUnixLineEnding | d2633c86ab4227d2251c4016105aee4220809f88 |
| SunamoTranslate | f6be2a2147b8a5cb8e97de0b09d044539e5fd2c5 |
| SunamoTwoWayDictionary | 32d5ada6a2af9c27dc942483eb28a39ea24ecb2a |
| SunamoTypes | 3267c92be2699b597721dc842a19e98b8e295884 |
| SunamoUnderscore | 5c0c51124ef06df55b4cbafb0bb9639b8aa425fd |
| SunamoUri | de2a7ea41be29e36421ee9140a1fab71602b0f87 |
| SunamoUriWebServices | ca49834cd81531d9034868766702ea303258d281 |
| SunamoValues | ea472284085891d070e6143e15ea19e3b8ec62b7 |
| SunamoVcf | d0bfef3772b68ea97ad60ce79b62cd6c69795233 |
| SunamoWikipedia | a2b413048ff1bcf3428c9586982dcfaca98ea76b |
| SunamoWinStd | 7c03c774d8aba4cff93447b7942f711e5bdbbf09 |
| SunamoXlfKeys | d59858a0122b0ba1772fa95150c27a9ffa083963 |
| SunamoXliffParser | 6f28413194d0a654bff6edaec0e4798b4202c3bb |
| SunamoXml | bf5a7d6452f33721717e7386bc5d14f6854f86a8 |
| SunamoYaml | 07e8e925a0e4ea84510b3d313288d6a5c9080f49 |
| SunamoYouTube | 53458883e43f7cff4971ce378a1cde496cf56069 |
| SunamoYt | 0f80e11c950ad5eb32454514c9350ad673398f85 |

### `refactor: české identifikátory a komentáře přeloženy do angličtiny`

Renamed Czech identifiers (mapping in `.scripts/shared/czech-identifiers.json`) and translated the remaining Czech comments and `#region` names; MSSloupecDB* files renamed to MSColumnDB*.

| Repo | Commit |
|---|---|
| . | fe49de96ad3bddda0068f5adbd0b8ed44c6af23f |
| SunamoAI | 8459cccb3bfc35f93bd2fa516345d7d7766c9635 |
| SunamoAps | 9d3bacf0c0627dbd54592fa11c55d8b2600138b8 |
| SunamoArgs | 3697dab0209a988e99b1a9f436226396ec07730e |
| SunamoChar | abd53bdd284a321c584019bdb2628f9bca1e8a13 |
| SunamoCollections | 40ddfee8c4b595dc301eba0969b6d00307df14fb |
| SunamoComgate | df5ed0118c746015979a2c08780980edda8ecf58 |
| SunamoConverters | 7096ee5540ad201fed5c35b183370a1f6ad20243 |
| SunamoCryptAlgorithms | dfc3c5ea1248c48641855dedd53cc13952b995e5 |
| SunamoCSharp | cf18cad435efc4813ffe21d66bd7f44dc00d3951 |
| SunamoCsproj | 61fcb07c9fd97b22e49eae3ddb6c47300632d08b |
| SunamoData | 8e831d38d39d27b7014a451f194615084888dee4 |
| SunamoDateTime | 3306cf9cba482c77871c6e843372e4d6235c924c |
| SunamoDelegates | 41be10ef837526fc272bed2cb6b721951ca51f0e |
| SunamoDevCodeBase | 01c25b4c60e631d6c9ce92f5d5c46054d9b4ac97 |
| SunamoDevCodeCore | 14ebb1398ffc04528fcf86e9f4b7c10a600068d9 |
| SunamoDevCodeFileFormats | 5a22697ebcb0df6aebec4f8a56318933f6a8ad64 |
| SunamoDotNetZip | 03d81602b716745d5884d1fbe9129978ca9f6c7c |
| SunamoEntity | e87a75b5407e29c251bde9f3aabc07af054f7bcb |
| SunamoEnums | 1762afa6060526523264371dea102636eba3d984 |
| SunamoEssential | e400a5e2e5bed8e97d59fa1c529dba6e9a3c87cc |
| SunamoFileExtensions | cc456c3b55274e23a57e6007a9cf8503078e37ac |
| SunamoFileSystem | 55d2445ac20c5354e054c309ca28c1c982d61377 |
| SunamoFtp | 72d15d936108591becd3587281869ed2be591122 |
| SunamoGenerators | 445d581e77e6402362c2a84570fbd00c02518a82 |
| SunamoGeo | 72dbf18efc56205a917410b26cb88ae02b3bd9b6 |
| SunamoGoogleSheets | c6bca4ac69c808fe3f6de9b82d5af69d7f7e7858 |
| SunamoGoPayApi | 951a7777e2868c02b7706bca79dfdafaeda7f4d6 |
| SunamoHelpers | 5bd2b96d0ac25e9331b1c98645f39da76ddd6ba3 |
| SunamoHtml | 26723ff88f2d3a61b5dee056bbbc4da0951fe35b |
| SunamoHttp | 8befcc3b440bc907df130dc0e469b8dd75ccf99c |
| SunamoLang | 24b509cd2e9c187cdc504ea328de19ae5d1cc090 |
| SunamoMsSqlLegacy | ec6bec8d6d88e4ced283be50549e5e8dc5dee8ed |
| SunamoNTextCat | ac48c4ee71bc7cb8f3bc8d8ef3be95b0cafbf392 |
| SunamoRandom | 80dbcd7a02531c35728bd9638043abde545452e6 |
| SunamoRL | 3ab029b2da6ae1cf59570c00b06ec2ef9fa0c6e3 |
| SunamoSharedMisc | ea7d7e4e30a29ee683a50c8918ca01e626f7525d |
| SunamoSlnGen | 5f3304e8a3efe87db2fb2f5a98c8304a72c5aed0 |
| SunamoSolutionsIndexer | 621cf06dfd06442d6f70d6237895a2d9eb4ac57d |
| SunamoStorage | 09a768532be412e2d13e48a8200b2f790f35e283 |
| SunamoTesseract | de7b7de6902e9f4811aaf997102e0d0d0f5e228f |
| SunamoToNetCore | 74ac9429a4048ba7b9bd9f7290d2551da6489fcf |
| SunamoTranslate | 51dbee7a4400b3ab569af4e0f33c0712bdf6b1e2 |
| SunamoValues | f6743fb0174d2270b89f833d83e9a87688dc38cb |
| SunamoWinStd | 2908116a084dff9910c2fe478b9b9752eb8ab091 |
| SunamoXml | ad94c4a539660c732fbcf2d68f3f6cd18ec7fd3e |
| SunamoYt | 9f163d976f63da47d285161669ed34197c3178cc |
