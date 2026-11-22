# Known failing tests

Measured on net10.0 on 2026-11-20 with `.scripts/run-tests.py` and `.scripts/test-failures.py`.
These are older tests; the list is the starting point for fixing or deleting them one by one.

Total: 55 failing tests in 18 packages.

## Expected value differs from the actual result (outdated expectation or real defect, needs review) (26)

- `SunamoCSharp`: CSharpHelperTests.RemoveComments2Test
- `SunamoCSharp`: CSharpHelperTests.RemoveCommentsTest
- `SunamoCsproj`: CsprojNsHelperTests.ParseSharpIfToFirstCodeElementTest
- `SunamoCsproj`: CsprojNsHelperTests.ParseSharpIfToFirstCodeElementTest2_MustThrowExceptionNamespaceOutsideCsprojNsHelper
- `SunamoCsproj`: CsprojNsHelperTests.ParseSharpIfToFirstCodeElementTest3
- `SunamoCsproj`: CsprojNsHelperTests.WriteNewTest
- `SunamoEmoticons`: UnitTest1.GetAllEmotions_ContainsCommonEmoticons
- `SunamoEmoticons`: UnitTest1.GetAllEmotions_ReturnsMultipleEmoticons
- `SunamoEmoticons`: UnitTest1.GetAllEmotions_ReturnsNonEmptyList
- `SunamoFileIO`: CloudProvidersHelperTests.TestPropertiesValues
- `SunamoFileSystem`: FSTests.GetNameWithoutSeries8
- `SunamoFileSystem`: FSTests.GetRelativePathTest
- `SunamoFileSystem`: FSTests.GetRelativePathTest2
- `SunamoFileSystem`: FSTests.GetRelativePathTest4
- `SunamoFileSystem`: FSTests.GetRelativePathTest5
- `SunamoFileSystem`: FSTests.GetRelativePathTest6
- `SunamoFileSystem`: FSTests.InsertBetweenFileNameAndExtensionTest
- `SunamoFileSystem`: FSTests.PathSpecialAndLevelTest
- `SunamoFileSystem`: FSTests.ReplaceIncorrectCharactersFileTest
- `SunamoGetFolders`: SHGetFoldersTests.GetFoldersTest2
- `SunamoGoogleSheets`: SheetsHelperTests.SplitFromGoogleSheetsRowTest2
- `SunamoHtml`: HtmlAgilityHelperTests.CreateHtmlDocumentTest
- `SunamoIni`: UnitTest1.WriteIni
- `SunamoPS`: PowershellRunnerTests.ParseToPartsTest
- `SunamoRoslyn`: RoslynCommentServiceTests.RemoveCommentsTest
- `SunamoWinStd`: JunctionPointTests.GetTargetTest

## Depends on a local path or tool that is not in the repository (21)

- `SunamoCSharp`: CSharpHelperTests.IsEmptyCommentedOrOnlyWithNamespaceTest
- `SunamoCsproj`: CsprojInstanceTests.AddRemoveNoWarnTest2
- `SunamoCsproj`: CsprojInstanceTests.CreateOrReplaceMicrosoft_Extensions_Logging_AbstractionsTest
- `SunamoCsproj`: CsprojInstanceTests.ItemsInItemGroupTest
- `SunamoCsproj`: CsprojInstanceTests.PropertyGroupItemContentTest
- `SunamoCsproj`: CsprojInstanceTests.RemoveDuplicatesInItemGroupTest
- `SunamoCsproj`: CsprojInstanceTests.RemoveSingleItemGroupTest
- `SunamoDevCodeCore`: AddOrEditNamespaceServiceTests.AddOrEditNamespaceForSingleFileAndSaveTest
- `SunamoDevCodeCore`: TFCsFormatTests.WriteAllLinesTest2
- `SunamoFileIO`: TFTests.ReadAllLinesTest_CantRemoveEmptyLines
- `SunamoFileSystem`: FSTests.DeleteAllEmptyDirectoriesTest
- `SunamoFileSystem`: FSTests.MoveDirectoryNoRecursiveTest
- `SunamoFileSystem`: FSTests.MoveFileTest
- `SunamoFileSystem`: FSTests.RenameDirectoryTest
- `SunamoGitConfig`: GitConfigFileHelperTests.ParseTest
- `SunamoHtml`: HtmlAgilityHelperTests.Test1
- `SunamoWinStd`: JunctionPointTests.MklinkHardLinkTest
- `SunamoWinStd`: PHWinTests.CodeInsiderTest
- `SunamoWinStd`: PHWinTests.CodeTest
- `SunamoWinStd`: PHWinTests.CodeWithLineTest
- `SunamoWinStd`: PHWinTests.CodiumTest

## Unfinished stub (NotImplementedException) (2)

- `SunamoYaml`: YamlHelperTests.LoadYaml
- `SunamoYaml`: YamlHelperTests.SaveYaml

## Exception thrown by the code under test (expectation outdated or input invalid) (6)

- `SunamoExceptions`: ThrowExTests.IsNullOrWhitespaceTest
- `SunamoFileSystem`: FSTests.GetAbsolutePath2Test
- `SunamoFileSystem`: FSTests.GetAbsolutePathTest
- `SunamoFileSystem`: FSTests.InsertBetweenFileNameAndPathTest
- `SunamoRegex`: WildcardTests.WildcardTest
- `SunamoRegex`: WildcardTests.WildcardWithXmlAttributeTest
