# Next Steps - Variable Renaming Project

**Last Updated**: 2025-12-14
**Current Status**: SunamoString & SunamoCollections COMPLETE ✅

---

## 🎯 WHAT TO DO NEXT

### Immediate Next Step: Choose Next Submodule

Pick the next submodule from the list below and apply the same contextual analysis process.

**Recommended order** (start with most commonly used):
1. ✅ **SunamoString** - COMPLETE (35 fixes, 2025-11-27)
2. ✅ **SunamoCollections** - COMPLETE (72 fixes, 2025-12-14) - **ALL files including _public and _sunamo**
3. **SunamoData** - data structures and models (NEXT RECOMMENDED)
4. **SunamoFileIO** - file I/O operations
5. **SunamoExceptions** - exception handling
6. ... (see full list below)

---

## 📋 PROCESS TO FOLLOW

### Step 1: Analysis Phase

```bash
# Use Task tool with Explore agent to find ALL variables
Task(
  subagent_type="Explore",
  description="Find contextually inappropriate variables",
  prompt="Search through [SubmoduleName] and find ALL variables that are:
  1. Domain-specific names in generic methods
  2. Czech words
  3. Misleading parameter names
  4. Internal members with camelCase (should be PascalCase)

  For each finding provide:
  - File path and line number
  - Current name and suggested rename
  - Reason why it's inappropriate"
)
```

### Step 2: Create Mappings

Create JSON mappings file:
```json
{
  "File": "SubmoduleName\\ClassName.cs",
  "Line": 123,
  "Type": "Parameter",
  "OldName": "inappropriateName",
  "NewName": "appropriateName",
  "Reason": "Contextual mismatch explanation",
  "Confidence": "High",
  "DataType": "string"
}
```

Save to: `.variable-rename-project/mappings/[SubmoduleName]-contextual-fixes.json`

### Step 3: Apply Renames

**Option A** - PinpVariableRenamer (if it works):
```bash
cd .variable-rename-project/app/PinpVariableRenamer
dotnet run -- "E:\vs\Projects\PlatformIndependentNuGetPackages" --submodule=[SubmoduleName]
```

**Option B** - Manual edits (if automation fails):
- Use Edit tool with `replace_all=true` for simple renames
- Manually verify each change

### Step 4: Verify Build

```bash
cd [SubmoduleName]
dotnet build --no-incremental
```

**Must have**: 0 compilation errors!

### Step 5: Document

Create report in `.variable-rename-project/reports/[SubmoduleName]-complete.md`

Update `NEXT-STEPS.md` to mark submodule as complete.

---

## 📊 SUBMODULES STATUS

### ✅ Completed (2/50+)

| Submodule | Status | Variables Fixed | Date |
|-----------|--------|-----------------|------|
| SunamoString | ✅ COMPLETE | 35 | 2025-11-27 |
| SunamoCollections | ✅ COMPLETE | 72 | 2025-12-14 |

### ⏳ Pending (priority order)

| Priority | Submodule | Reason |
|----------|-----------|--------|
| 🔥 HIGH | SunamoData | Data models, likely naming issues |
| 🔥 HIGH | SunamoFileIO | File operations, likely domain-specific names |
| 🔥 HIGH | SunamoExceptions | Exception handling |
| 📌 MEDIUM | SunamoAsync | Async utilities |
| 📌 MEDIUM | SunamoCollectionsGeneric | Generic collections |
| 📌 MEDIUM | SunamoConverters | Type converters |
| 📌 MEDIUM | SunamoDateTime | Date/time utilities |
| 📌 MEDIUM | SunamoDictionary | Dictionary helpers |
| 📌 MEDIUM | SunamoExtensions | Extension methods |
| 📌 MEDIUM | SunamoFileSystem | File system operations |
| 📌 MEDIUM | SunamoReflection | Reflection utilities |
| 📌 MEDIUM | SunamoRegex | Regex helpers |
| 📌 MEDIUM | SunamoHtml | HTML utilities |
| 📌 MEDIUM | SunamoHttp | HTTP utilities |
| 📌 MEDIUM | SunamoLogging | Logging |
| 📌 MEDIUM | SunamoSerializer | Serialization |
| 🔽 LOWER | All others | Less frequently used |

### 📝 Full List of Submodules

Based on git status, there are 50+ submodules in PINP:
- SunamoArgs
- SunamoAsync
- SunamoBazosCrawler
- SunamoBts
- SunamoCl
- SunamoCollectionOnDrive
- SunamoCollections
- SunamoCollectionsGeneric
- SunamoConverters
- SunamoCrypt
- SunamoCsv
- SunamoData
- SunamoDateTime
- SunamoDependencyInjection
- SunamoDevCode
- SunamoDictionary
- SunamoEnumsHelper
- SunamoExceptions
- SunamoExtensions
- SunamoFileExtensions
- SunamoFileIO
- SunamoFileSystem
- SunamoFilesIndex
- SunamoFluentFtp
- SunamoFtp
- SunamoGetFiles
- SunamoGoogleSheets
- SunamoHtml
- SunamoHttp
- SunamoLaTeX
- SunamoLang
- SunamoLogging
- SunamoMarkdown
- SunamoMime
- SunamoNuGetProtocol
- SunamoNumbers
- SunamoOctokit
- SunamoPInvoke
- SunamoPS
- SunamoPlatformUwpInterop
- SunamoRandom
- SunamoReflection
- SunamoRegex
- SunamoRoslyn
- SunamoSelenium
- SunamoSerializer
- SunamoShared
- SunamoString ✅
- SunamoStringGetLines
- SunamoStringJoin
- SunamoStringReplace
- SunamoStringSplit
- SunamoText
- SunamoTextOutputGenerator
- SunamoTidy
- SunamoUri
- SunamoUriWebServices
- SunamoValues
- SunamoWinStd
- SunamoXml

---

## 🔍 WHAT TO LOOK FOR

### Critical Issues (always fix):

1. **Internal members with camelCase**
   ```csharp
   // ❌ WRONG
   internal const int myConstant = 42;
   internal static string myField;

   // ✅ CORRECT
   internal const int MyConstant = 42;
   internal static string MyField;
   ```

2. **Czech words in code**
   ```csharp
   // ❌ WRONG
   string podlazi, polovina, vstup

   // ✅ CORRECT
   string floor, half, input
   ```

3. **Domain-specific names in generic methods**
   ```csharp
   // ❌ WRONG - generic method with music domain name
   public static string RemoveLastChar(string artist)

   // ✅ CORRECT
   public static string RemoveLastChar(string input)
   ```

4. **Misleading parameter names**
   ```csharp
   // ❌ MISLEADING - suggests only newlines
   Split(string input, params string[] newLine)

   // ✅ ACCURATE
   Split(string input, params string[] delimiters)
   ```

---

## 📚 REFERENCE DOCUMENTS

**Read these before starting next submodule**:

1. `VARIABLE-NAMING-RULES.md` - Comprehensive naming rules
2. `CONTEXTUAL-ANALYSIS-PROCESS.md` - Step-by-step process
3. `SUNAMOSTRING-COMPLETION-SUMMARY.md` - Example of completed analysis
4. `.variable-rename-project/reports/SunamoString-contextual-fixes-complete.md` - Detailed report

---

## 🎯 SUCCESS CRITERIA

For each submodule, you're done when:

- ✅ All internal members use PascalCase
- ✅ No Czech words in code
- ✅ Generic methods have generic parameter names
- ✅ No misleading parameter names
- ✅ Build succeeds with 0 errors
- ✅ 0 new warnings introduced
- ✅ Documentation created

---

## 🚀 QUICK START COMMAND

**For next session**, start with:

```
I want to continue with variable renaming for PINP submodules.
Last completed: SunamoString (35 fixes).
Next recommended: SunamoCollections.

Please:
1. Read VARIABLE-NAMING-RULES.md
2. Read CONTEXTUAL-ANALYSIS-PROCESS.md
3. Analyze SunamoCollections for contextually inappropriate variables
4. Apply the same process as SunamoString
```

---

## 📊 OVERALL PROJECT GOALS

- **Total submodules**: 50+
- **Completed**: 1 (SunamoString)
- **Remaining**: 49+
- **Target**: All PINP submodules with perfect naming

**Estimated effort per submodule**:
- Small submodules: ~10-20 fixes
- Medium submodules: ~30-40 fixes (like SunamoString)
- Large submodules: ~50+ fixes

---

## 💡 TIPS FOR NEXT AI SESSION

1. **Start by reading the reference docs** - they contain all the rules and examples
2. **Use Task + Explore agent** for comprehensive analysis
3. **Don't just fix single-letter variables** - look for contextual issues!
4. **Verify build after every change**
5. **Document everything** - future sessions need to know what was done

---

## 🔧 TOOLS AVAILABLE

1. **Grep** - Find patterns in code
2. **Read** - Examine files
3. **Edit** - Manual variable renames
4. **Task + Explore** - Comprehensive analysis
5. **PinpVariableRenamer** - Automated renaming (when it works)
6. **Bash** - Build verification

---

**Ready to continue**: YES ✅
**Next submodule**: SunamoCollections (recommended)
**Reference docs**: All created and available in PINP root
**Process**: Fully documented and repeatable

---

**Last Session Date**: 2025-11-27
**Next Session**: Ready to start SunamoCollections or any other submodule
