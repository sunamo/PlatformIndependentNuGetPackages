# Contextual Analysis Process for Variable Renaming

**EN**: Step-by-step process for analyzing and renaming variables contextually
**CZ**: Krok za krokem proces pro analýzu a přejmenování proměnných kontextuálně

---

## 🎯 GOAL

Ensure EVERY variable name is:
1. **Contextually appropriate** - makes sense in the method's context
2. **Convention-compliant** - follows C# naming conventions
3. **Language-correct** - English only, no Czech words
4. **Clear and accurate** - not misleading

---

## 📋 STEP-BY-STEP PROCESS

### Phase 1: Initial Analysis

#### Step 1.1: Find ALL Variables
```bash
# Don't just look for single-letter variables!
# Find ALL parameters, local variables, fields, properties
```

**Tools**:
- `Grep` for pattern matching
- `Read` to examine files
- `Task` with Explore agent for comprehensive search

#### Step 1.2: Categorize Variables

| Category | Examples | Needs Review? |
|----------|----------|---------------|
| Single-letter | `s`, `i`, `x`, `c` | ✅ Always |
| Abbreviations | `str`, `exp`, `val` | ✅ Yes |
| Domain-specific | `artist`, `songName`, `tableName` | ✅ YES! Critical |
| Generic | `input`, `text`, `value` | ⚠️ Maybe |
| Czech words | `podlazi`, `polovina` | ✅ ALWAYS |

### Phase 2: Contextual Evaluation

#### Step 2.1: For Each Variable, Ask:

1. **What does this method do?**
   - Read the method body
   - Understand its purpose
   - Check if it's generic or domain-specific

2. **Is the variable name appropriate for THIS context?**
   ```csharp
   // Example: Method removes last character from ANY string
   public static string RemoveLastChar(string artist)

   // ❌ NO! "artist" implies music domain, but method is generic
   // ✅ Should be: string input
   ```

3. **Does the name match the method's generality?**
   - Generic method → generic name
   - Specific method → specific name OK

4. **Is it misleading?**
   ```csharp
   // ❌ MISLEADING - "newLine" suggests it only splits by newlines
   Split(string input, params string[] newLine)

   // ✅ ACCURATE
   Split(string input, params string[] delimiters)
   ```

#### Step 2.2: Create Rename Mappings

For each inappropriate name, document:
```json
{
  "File": "SunamoString\\SH.cs",
  "Line": 198,
  "Type": "Parameter",
  "OldName": "artist",
  "NewName": "input",
  "Reason": "Domain-specific (music) → Generic. Method works on ANY string",
  "Confidence": "High",
  "DataType": "string"
}
```

### Phase 3: Implementation

#### Step 3.1: Apply Renames

**Option A**: Use PinpVariableRenamer (automated)
```bash
cd .variable-rename-project/app/PinpVariableRenamer
dotnet run -- "E:\vs\Projects\PlatformIndependentNuGetPackages" --submodule=SunamoString
```

**Option B**: Manual edits (when automation fails)
```csharp
// Use Edit tool with replace_all for simple cases
Edit(file_path, old_string, new_string, replace_all=true)
```

#### Step 3.2: Verify Build

```bash
cd SunamoString
dotnet build --no-incremental
```

**Critical**: Build MUST succeed with 0 new errors!

### Phase 4: Documentation

#### Step 4.1: Document Changes

Create report:
- What was changed
- Why it was changed
- How many variables affected
- Build status

#### Step 4.2: Update Project Tracking

Update `.variable-rename-project/CÍLE-A-STAV.md`:
- Mark submodule as complete
- Document statistics
- Note any issues

---

## 🔍 DETAILED ANALYSIS EXAMPLES

### Example 1: Generic Method with Domain Name

```csharp
// FOUND:
public static string RemoveLastChar(string artist)
{
    return artist.Substring(0, artist.Length - 1);
}

// ANALYSIS:
// - Method name: "RemoveLastChar" - generic operation
// - What it does: Removes last character from ANY string
// - Parameter: "artist" - music domain specific
// - Context mismatch: Generic method, domain-specific parameter
// - Verdict: ❌ INAPPROPRIATE

// FIX:
public static string RemoveLastChar(string input)
{
    return input.Substring(0, input.Length - 1);
}
```

### Example 2: Misleading Parameter Name

```csharp
// FOUND:
internal static List<string> Split(string input, params string[] newLine)
{
    return input.Split(newLine, StringSplitOptions.RemoveEmptyEntries).ToList();
}

// ANALYSIS:
// - Method name: "Split" - generic split operation
// - Parameter: "newLine" - suggests it only splits by newlines
// - Actual usage: Can split by ANY delimiters (strings)
// - Verdict: ❌ MISLEADING

// FIX:
internal static List<string> Split(string input, params string[] delimiters)
{
    return input.Split(delimiters, StringSplitOptions.RemoveEmptyEntries).ToList();
}
```

### Example 3: Naming Convention Violation

```csharp
// FOUND:
internal class NumConsts
{
    internal const int mOne = -1;
    internal const int defaultPortIfCannotBeParsed = 587;
    internal const long kB = 1024;
}

// ANALYSIS:
// - Access modifier: "internal" - visible outside class
// - Convention: internal = PascalCase (like public)
// - Current casing: camelCase
// - Verdict: ❌ CONVENTION VIOLATION

// FIX:
internal class NumConsts
{
    internal const int MOne = -1;
    internal const int DefaultPortIfCannotBeParsed = 587;
    internal const long KB = 1024;
}
```

### Example 4: Czech Word in Code

```csharp
// FOUND:
public static string InBrackets(string podlazi)
{
    return GetTextBetweenTwoCharsInts(podlazi, podlazi.IndexOf('('), podlazi.IndexOf(')'));
}

// ANALYSIS:
// - Parameter: "podlazi" - Czech word for "floor"
// - Language: Code must be in English
// - Domain: Building-specific in generic method
// - Verdict: ❌ DOUBLE VIOLATION (Czech + wrong domain)

// FIX:
public static string InBrackets(string input)
{
    return GetTextBetweenTwoCharsInts(input, input.IndexOf('('), input.IndexOf(')'));
}
```

---

## 📊 ANALYSIS CHECKLIST

For each variable, check:

- [ ] Is the name in English?
- [ ] Does it match the method's context (generic vs specific)?
- [ ] Does the casing match the access modifier?
- [ ] Is it clear and not misleading?
- [ ] Could someone misunderstand what the method does based on the parameter name?

If ANY checkbox is unchecked → rename needed!

---

## 🎓 COMMON PATTERNS

### Pattern 1: Copy-Paste Reuse
```csharp
// Original method (specific):
public static string FormatSongTitle(string songName) { ... }

// Copied and reused (now generic):
public static string RemoveLastChar(string songName) { ... }
// ❌ Wrong! Parameter name not updated for new context
```

### Pattern 2: Hungarian Notation Remnants
```csharp
internal const string strEmpty = "";  // ❌
internal const string Empty = "";     // ✅
```

### Pattern 3: Over-Specific Names
```csharp
// Method: Converts any plural word to singular
public static string ConvertPluralToSingleEn(string tableName)  // ❌
public static string ConvertPluralToSingleEn(string pluralWord) // ✅
```

---

## 🛠️ TOOLS

1. **Grep**: Find all occurrences of a pattern
2. **Read**: Examine file contents
3. **Edit**: Rename variables manually
4. **Task + Explore**: Comprehensive codebase analysis
5. **PinpVariableRenamer**: Automated renaming using Roslyn

---

## 📈 SUCCESS METRICS

A successful contextual analysis results in:
- ✅ 0 compilation errors
- ✅ All internal members use PascalCase
- ✅ No Czech words in code
- ✅ Generic methods have generic parameter names
- ✅ No misleading parameter names
- ✅ Build succeeds

---

**Created**: 2025-11-27
**For**: All PINP submodules
**Process Owner**: AI variable analysis system
