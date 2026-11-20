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
