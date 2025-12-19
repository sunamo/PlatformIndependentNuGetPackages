# Variable Naming Rules for PINP Projects

**EN**: Universal naming rules for all PlatformIndependentNuGetPackages submodules
**CZ**: Univerzální pravidla pro pojmenování pro všechny PINP submoduly

---

## 🎯 CORE PRINCIPLE: Contextual Appropriateness

**It's not enough for a variable name to be "self-descriptive" - it must be CONTEXTUALLY APPROPRIATE!**

### Example of Contextually Inappropriate Names

```csharp
// ❌ BAD - Domain-specific name in generic method
public static string RemoveLastChar(string artist)
public static string RemoveAfterLast(string nameSolution, object delimiter)
public static string InBrackets(string podlazi)  // Czech word + wrong domain!

// ✅ GOOD - Generic name in generic method
public static string RemoveLastChar(string input)
public static string RemoveAfterLast(string input, object delimiter)
public static string InBrackets(string input)
```

---

## 📋 NAMING CONVENTIONS

### 1. Access Modifiers → Casing

| Access Level | Casing | Example |
|-------------|--------|---------|
| `public` | PascalCase | `PublicMethod()`, `PublicProperty` |
| `internal` | **PascalCase** | `InternalMethod()`, `InternalField` |
| `protected` | PascalCase | `ProtectedMethod()`, `ProtectedField` |
| `private` | camelCase | `privateField`, `privateMethod()` |
| Local variables | camelCase | `localVariable`, `tempValue` |
| Parameters | camelCase | `parameter`, `inputValue` |

**CRITICAL**: `internal` members are visible outside the class → must use PascalCase!

### 2. Constants and Static Fields

```csharp
// ✅ CORRECT
internal const int MOne = -1;
internal const int DefaultPortIfCannotBeParsed = 587;
internal static short NDtMinVal = 10101;
internal const long KB = 1024;
internal const int One = 1;

// ❌ WRONG - internal must be PascalCase
internal const int mOne = -1;
internal const int defaultPortIfCannotBeParsed = 587;
internal const int kB = 1024;
```

---

## 🔍 CONTEXTUAL ANALYSIS RULES

### Rule 1: Generic Methods Need Generic Names

```csharp
// ❌ Domain-specific parameter in generic method
public static List<string> Split(string input, params string[] newLine)
public static string ConvertPluralToSingleEn(string tableName)
public static bool ContainsOnly(string floorS, List<char> chars)

// ✅ Generic parameter names
public static List<string> Split(string input, params string[] delimiters)
public static string ConvertPluralToSingleEn(string pluralWord)
public static bool ContainsOnly(string input, List<char> chars)
```

### Rule 2: Avoid Domain-Specific Names Unless Necessary

**Bad Examples (generic methods with domain names)**:
- `artist` in `RemoveLastChar()` - works on ANY string, not just artists
- `songName` in `InsertEndingBracket()` - balances brackets in ANY string
- `phoneNumber` in generic string method - should be `input`
- `tableName` for plural-to-singular conversion - should be `pluralWord`
- `hash` in `GetOddIndexesOfWord()` - extracts characters from ANY string

**Good Practice**: Use `input`, `text`, `value`, `source` for generic string parameters.

### Rule 3: No Czech Words in Code

```csharp
// ❌ WRONG - Czech words
internal static string InBrackets(string podlazi)  // "podlaží" = floor
var polovina = hash.Length / 2;  // "polovina" = half

// ✅ CORRECT - English
internal static string InBrackets(string input)
var half = input.Length / 2;
```

### Rule 4: Misleading Parameter Names

```csharp
// ❌ MISLEADING - "newLine" suggests it only splits by newlines
public static List<string> Split(string input, params string[] newLine)

// ✅ ACCURATE - can split by any delimiters
public static List<string> Split(string input, params string[] delimiters)
```

### Rule 5: Parameter Names Must Reflect Purpose, Not Implementation Details

```csharp
// ❌ BAD - "builder" suggests building, but method shuffles existing array
public static T[] JumbleUp<T>(T[] builder)

// ✅ GOOD - clearly indicates input data
public static T[] JumbleUp<T>(T[] array)
// or
public static T[] JumbleUp<T>(T[] items)

// ❌ BAD - "divs" is meaningless, "countOfColumn" is backwards word order
public static ResultWithExceptionCollections<List<List<T>>> DivideBy<T>(List<T> divs, int countOfColumn)

// ✅ GOOD - clear purpose
public static ResultWithExceptionCollections<List<List<T>>> DivideBy<T>(List<T> items, int columnCount)
// or
public static ResultWithExceptionCollections<List<List<T>>> DivideBy<T>(List<T> source, int itemsPerColumn)
```

**Common violations**:
- `builder` when nothing is being built (use `array`, `items`, `source`)
- Abbreviated/truncated names: `divs`, `vals`, `elems` (use full words: `items`, `values`, `elements`)
- Backwards word order: `countOfColumn` → `columnCount`, `nameOfFile` → `fileName`
- Implementation details in names instead of purpose
- SQL keywords as generic parameters: `where` → `items`, `array`
- Single-letter generic params: `v` → `index`, `value`
- Redundant type in name: `sourceList` when type is already `List<T>` → just `items`
- Output-sounding names for input params: `result` as input → `list`, `items`

### Rule 6: Use Generic Parameter Names Consistently

**Preferred generic names for common types**:
```csharp
// ✅ Arrays
T[] array, T[] items

// ✅ Lists
List<T> list, List<T> items

// ✅ Collections (when not specific)
IEnumerable<T> items, IList<T> collection

// ✅ Integers for indexes/counts
int index, int count, int length

// ❌ AVOID
T[] builder  // implies building
List<T> sourceList  // redundant "List"
List<T> result  // sounds like output
T[] where  // SQL keyword
int v  // single letter (except i,j,k in loops)
```

---

## 🚨 COMMON VIOLATIONS FOUND

### Category 1: Music Domain in Generic Methods
- `artist`, `songName`, `title`, `remix`
- **Fix**: Use `input`, `firstPart`, `secondPart`, `mainText`, `bracketedText`

### Category 2: Database/Solution Domain
- `nameSolution`, `tableName`, `nameTrim`
- **Fix**: Use `input`, `pluralWord`

### Category 3: Building/Infrastructure Domain
- `podlazi` (Czech!), `floorS`
- **Fix**: Use `input`

### Category 4: File System Domain
- `path` in methods that work on ANY string
- **Fix**: Use `input` or keep `path` only if method is file-system specific

### Category 5: Redundant Names
- `textWithDiacritics` in `TextWithoutDiacritic()` - method name already says it!
- **Fix**: Use `input`

---

## ✅ VERIFICATION CHECKLIST

Before finalizing any variable rename:

1. **Context Check**: Does this variable name make sense in THIS method's context?
2. **Generality Check**: If the method is generic, is the parameter name generic?
3. **Language Check**: Are all names in English?
4. **Convention Check**: Does the casing match the access modifier?
5. **Clarity Check**: Is the name clear without being overly specific?

---

## 🛠️ PROCESS FOR ANALYZING VARIABLES

### Step 1: Read the Method
Understand what the method actually does, not what the parameter name suggests.

### Step 2: Identify Method Type
- **Generic utility method**: Use generic names (`input`, `text`, `value`)
- **Domain-specific method**: Domain names are OK (`phoneNumber` in `FormatPhoneNumber()`)

### Step 3: Check All Variables
Don't just check single-letter variables - check ALL variables for contextual appropriateness!

### Step 4: Rename Systematically
Use PinpVariableRenamer or manual edits, then verify build succeeds.

---

## 📚 EXAMPLES FROM SUNAMOSTRING

### Fixed Issues

| Before | After | Reason |
|--------|-------|--------|
| `string artist` | `string input` | Generic method, not music-specific |
| `string nameSolution` | `string input` | Generic method, not solution-specific |
| `string podlazi` | `string input` | Czech word + wrong domain |
| `params string[] newLine` | `params string[] delimiters` | Misleading - works with any delimiters |
| `string tableName` | `string pluralWord` | Method converts plural→singular, not DB-specific |
| `var polovina` | `var half` | Czech word |
| `internal const int mOne` | `internal const int MOne` | Internal must be PascalCase |
| `internal const int kB` | `internal const int KB` | Internal must be PascalCase |

---

## 🎓 KEY LESSONS LEARNED

1. **Samopopisnost ≠ Kontextuální vhodnost**
   - "Self-descriptive" doesn't mean "contextually appropriate"
   - `nameSolution` is self-descriptive but wrong in generic methods

2. **AI musí vyhodnotit KAŽDOU proměnnou v kontextu**
   - Not just single-letter variables
   - Not just "obviously bad" names
   - ALL variables must be evaluated for contextual fit

3. **Internal = Public naming**
   - `internal` members are visible outside the class
   - Must use PascalCase, not camelCase

4. **Generic methods → Generic names**
   - If a method works on ANY string, don't use domain-specific names
   - Use `input`, `text`, `value`, `source`

5. **Misleading names are worse than generic names**
   - `newLine` when it accepts ANY delimiter is misleading
   - Better to be generic (`delimiters`) than misleading

---

## 📄 APPLICATION TO OTHER SUBMODULES

These rules apply to **ALL** PINP submodules:
- SunamoString ✅ (35 fixes completed)
- SunamoCollections
- SunamoData
- SunamoFileIO
- ... and all others

**Process**:
1. Read all variables in context
2. Apply contextual analysis
3. Fix naming convention violations (internal = PascalCase)
4. Verify build succeeds
5. Document changes

---

**Last Updated**: 2025-11-27
**Applies to**: All PlatformIndependentNuGetPackages submodules
