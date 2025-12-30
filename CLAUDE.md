- všechny složky které na této úrovni vytvoříš mi dej do složek začínající tečkou. tedy .scripts místo scripts.

## PŘEJMENOVÁNÍ PROMĚNNÝCH NA SAMOPOPISNÉ NÁZVY

### Obecná pravidla

#### KRITICKÉ: Komentář "variables names: ok"
- **PRACUJ POUZE SE SOUBORY BEZ TOHOTO KOMENTÁŘE**: Při opravování názvů proměnných pracuj POUZE s .cs soubory které **NEMAJÍ** komentář `// variables names: ok` na začátku
- **IGNORUJ SOUBORY S KOMENTÁŘEM**: Soubory které mají `// variables names: ok` jsou již zkontrolované uživatelem a NESMÍŠ je měnit
- **NIKDY NEPŘIDÁVEJ** komentář `// variables names: ok` do souborů!
- Tento komentář přidává POUZE uživatel při ruční kontrole
- Tvoje práce je opravit všechny špatné názvy, NE označovat soubory jako hotové

#### Mazání nepoužívaných parametrů
- **VŽDY** maž nepoužívané parametry z hlaviček metod - pokud parametr není v těle metody použit, SMAŽ ho
- Nepoužívané parametry jsou mrtvý kód a zavádějící pro volající kód
- Výjimka: virtuální/override metody kde parametr je vyžadován signatuřou

#### KRITICKÉ: Jednopísmenné názvy jsou ZAKÁZANÉ!
- **ABSOLUTNĚ ZAKÁZANÉ** jednopísmenné názvy (`t`, `v`, `s`, `l`, `e`, `d`, etc.) pro:
  - ❌ Extension metody: `this Task t` → ✅ `this Task task`
  - ❌ Lambda parametry: `task.ContinueWith(t => ...)` → ✅ `task.ContinueWith(completedTask => ...)`
  - ❌ Parametry metod: `void Process(string s)` → ✅ `void Process(string text)`
  - ❌ Override metody: `void Post(SendOrPostCallback d, object state)` → ✅ `void Post(SendOrPostCallback callback, object state)`
  - ❌ Lokální proměnné: `var t = GetTask()` → ✅ `var task = GetTask()`
- **JEDINÁ VÝJIMKA**: For/foreach loop indexy (`i`, `j`, `k`), `item` POUZE v foreach, a `_` (underscore discard):
  ```csharp
  for (int i = 0; i < count; i++)  // OK
  foreach (var item in list)       // OK
  Post(_ => done = true, null);    // OK - _ je discard pro nepoužívaný parametr
  ```
- **DŮVOD**: Jednopísmenné názvy jsou nekomunikativní a ztěžují čitelnost kódu!

#### NEJČASTĚJŠÍ CHYBY (kontroluj VŽDY!)
1. ❌ `item` jako parametr metody → ✅ `text`, `element`, `value` (item POUZE pro foreach!)
2. ❌ Jednopísmenné parametry (`v`, `i`, `c`) → ✅ `text`, `foundIndex`, `character`
3. ❌ Doménově specifické názvy pro univerzální metody:
   - `fileName` → `text`
   - `pass`, `salt` → `firstArray`, `secondArray`
   - `tokens` → `list`
   - `columns` → `items`
4. ❌ Příliš obecné názvy:
   - `value` → `firstElement` (když je to první prvek)
   - `list` → `lines` (když je to seznam řádků)
5. ❌ Zavádějící názvy:
   - `from`, `to` v Replace → `what`, `replacement`
   - `innerMain` → `array`
6. ❌ Nepoužívané proměnné → SMAŽ je!

#### Pojmenování proměnných
- **NIKDY** nepoužívej nesmyslné názvy jako `newLine` pro parametr který může být jakýkoliv delimiter - použij `delimiters`
- **NIKDY** nepoužívej specifické názvy jako `isSpecial` pro obecný predikát - použij `predicate`
- **NIKDY** nepoužívej doménově specifické názvy (např. `columnCount`, `rowSize`) pro **univerzální** parametry v obecných metodách - použij obecné názvy (`groupSize`, `chunkSize`, `itemsPerGroup`)
- **NIKDY** nepoužívej jednoslovné nekomunikativní názvy (např. `s`, `v`, `l`, `a`) ani s čísly (např. `s1`, `s2`, `c1`, `c2`, `v1`, `v2`) - použij samopopisné názvy (`text`, `value`, `firstList`, `secondList`, `firstValue`, `secondValue`)
- **NIKDY** nepoužívej generické "dočasné" názvy (např. `temp`, `tmp`, `val`, `var`) pro parametry metod - použij názvy vyjadřující skutečný účel
- **NIKDY** nepoužívej příliš obecné názvy (např. `list`, `data`, `items`) když existuje **specifičtější název vyjadřující účel** (např. `args`, `values`, `lines`, `elements`)
- **NIKDY** nepoužívej `item` pro parametry metod - `item` je vyhrazeno pro iterační proměnné v foreach cyklech. Použij specifičtější názvy (`pattern`, `searchTerm`, `value`, `element`)
- **VŽDY** pojmenovávej string parametry jako `text` pokud neexistuje specifičtější název (např. `delimiter`, `separator`, `prefix`, `suffix`, `pattern`)
- **VŽDY** pojmenovávej parametry podle jejich typu - pokud je typ `SomeTypeCA`, název by měl být `someType` nebo podobný, NE něco nesouvisejícího
- **VŽDY** dbej na konzistenci pojmenování v rámci jednoho souboru - pokud ostatní metody používají `lines`, nepoužívej `content`
- **VŽDY** pojmenovávej proměnné podle jejich skutečného účelu, ne podle jednoho konkrétního případu použití

### Enum soubory
- Do souborů které obsahují **pouze enum** definice automaticky přidej na začátek komentář: `// variables names: ok`
- Použij skript `.scripts/add-enum-comments.ps1` pro hromadné přidání komentářů

### Příklady správného pojmenování

#### ❌ ŠPATNĚ:
```csharp
internal static List<string> Split(string text, params string[] newLine)
```
**Proč je to špatně:** `newLine` předpokládá že delimiter je vždy nový řádek, ale může to být čárka, středník, jakýkoliv delimiter!

#### ✅ SPRÁVNĚ:
```csharp
internal static List<string> Split(string text, params string[] delimiters)
```

#### ❌ ŠPATNĚ:
```csharp
internal static string RemoveAfterFirstFunc(string v, Func<char, bool> isSpecial, params char[] canBe)
```
**Proč je to špatně:** `isSpecial` je příliš specifické, predikát může testovat cokoliv (isDigit, isLetter, isWhitespace, atd.)!

#### ✅ SPRÁVNĚ:
```csharp
internal static string RemoveAfterFirstFunc(string v, Func<char, bool> predicate, params char[] canBe)
```

#### ❌ ŠPATNĚ - nekonzistence v rámci souboru:
```csharp
public void RemoveEmptyLinesFromStartAndEnd(List<string> lines) { ... }
public void RemoveEmptyLinesToFirstNonEmpty(List<string> content) { ... }  // content != lines
public void RemoveEmptyLinesFromBack(List<string> lines) { ... }
```

#### ✅ SPRÁVNĚ - konzistentní pojmenování:
```csharp
public void RemoveEmptyLinesFromStartAndEnd(List<string> lines) { ... }
public void RemoveEmptyLinesToFirstNonEmpty(List<string> lines) { ... }
public void RemoveEmptyLinesFromBack(List<string> lines) { ... }
```

#### ❌ ŠPATNĚ:
```csharp
public static ResultWithExceptionCollections<List<List<T>>> DivideBy<T>(List<T> items, int columnCount)
{
    // Dělí items na části o velikosti columnCount
    List<T> currentRow = new List<T>();
    if (currentRow.Count == columnCount) { ... }
}
```
**Proč je to špatně:** `columnCount` předpokládá specifický use-case (sloupce v tabulce), ale metoda je **univerzální** a dělí jakýkoliv seznam na části! Navíc název je zavádějící - parametr určuje **velikost každé skupiny** (počet prvků na řádek/part), ne počet sloupců!

#### ✅ SPRÁVNĚ:
```csharp
public static ResultWithExceptionCollections<List<List<T>>> DivideBy<T>(List<T> items, int groupSize)
{
    // Dělí items na části o velikosti groupSize
    List<T> currentGroup = new List<T>();
    if (currentGroup.Count == groupSize) { ... }
}
```
**Alternativní správné názvy:** `itemsPerGroup`, `chunkSize`, `itemsPerPart` - všechny popisují skutečný účel (velikost každé skupiny), ne konkrétní doménový use-case.

#### ❌ ŠPATNĚ:
```csharp
public static void InitFillWith<T>(List<T> list, int columns)
{
    for (var i = 0; i < columns; i++)
        list.Add(default);
}
```
**Proč je to špatně:** `columns` předpokládá že inicializujeme sloupce v tabulce, ale metoda je **univerzální** a pouze přidává N výchozích prvků do listu! Může se použít pro cokoliv, ne jen tabulky.

#### ✅ SPRÁVNĚ:
```csharp
public static void InitFillWith<T>(List<T> list, int count)
{
    for (var i = 0; i < count; i++)
        list.Add(default);
}
```
**Alternativní správné názvy:** `elementCount`, `itemCount`, `size` - všechny popisují skutečný účel (počet prvků k přidání).

#### ❌ ŠPATNĚ:
```csharp
public static bool ContainsAnyFromElementBool(string s, IList<string> list)
{
    foreach (var item in list)
        if (s.Contains(item))
            return true;
    return false;
}
```
**Proč je to špatně:** `s` je **jednoslovný nekomunikativní název** - neříká NIC o tom co obsahuje! Je to kryptické, nesrozumitelné. Co je `s`? String čeho?

#### ✅ SPRÁVNĚ:
```csharp
public static bool ContainsAnyFromElementBool(string text, IList<string> list)
{
    foreach (var item in list)
        if (text.Contains(item))
            return true;
    return false;
}
```
**Alternativní správné názvy:** `value`, `searchText`, `input` - všechny jsou samopopisné a srozumitelné.

#### ❌ ŠPATNĚ:
```csharp
public static List<string> Format(string formatString, List<string> list)
{
    for (var i = 0; i < list.Count(); i++)
        list[i] = string.Format(formatString, list[i]);
    return list;
}
```
**Proč je to špatně:** `list` je **příliš obecný** - je to seznam čeho? Název neříká NIC o účelu parametru. V kontextu formátování by měl název vyjadřovat že jde o argumenty/hodnoty pro formátování.

#### ✅ SPRÁVNĚ:
```csharp
public static List<string> Format(string formatString, List<string> args)
{
    for (var i = 0; i < args.Count(); i++)
        args[i] = string.Format(formatString, args[i]);
    return args;
}
```
**Alternativní správné názvy:** `values`, `items` - lepší než `list`, ale `args` je nejlepší pro kontext formátování.

#### ❌ ŠPATNĚ:
```csharp
public static List<string> WithEndSlash(List<string> folders)
{
    for (var i = 0; i < folders.Count; i++)
        folders[i] = folders[i].TrimEnd('\\') + "\\";
    return folders;
}
```
**Proč je to špatně:** `folders` předpokládá že to budou POUZE složky, ale metoda je **univerzální** a pracuje s jakýmikoliv stringy! Může se použít pro cesty k souborům, URL, nebo jakékoliv stringy které potřebují backslash na konci.

#### ✅ SPRÁVNĚ:
```csharp
public static List<string> WithEndSlash(List<string> paths)
{
    for (var i = 0; i < paths.Count; i++)
        paths[i] = paths[i].TrimEnd('\\') + "\\";
    return paths;
}
```
**Alternativní správné názvy:** `items`, `values` - ale `paths` je nejlepší protože backslash se typicky používá v cestách.

#### ❌ ŠPATNĚ:
```csharp
public static List<string> ToLower(List<string> words)
{
    for (var i = 0; i < words.Count; i++)
        words[i] = words[i].ToLower();
    return words;
}
```
**Proč je to špatně:** `words` předpokládá že to budou POUZE jednotlivá slova, ale metoda je **univerzální** a pracuje s jakýmikoliv stringy! Může se použít pro věty, názvy souborů, URL, nebo jakékoliv jiné texty.

#### ✅ SPRÁVNĚ:
```csharp
public static List<string> ToLower(List<string> items)
{
    for (var i = 0; i < items.Count; i++)
        items[i] = items[i].ToLower();
    return items;
}
```
**Alternativní správné názvy:** `values`, `strings` - všechny jsou obecnější než `words` a nevnucují konkrétní use-case.

#### ❌ ŠPATNĚ:
```csharp
public static List<byte> JoinBytesArray(byte[] pass, byte[] salt)
```
**Proč je to špatně:** `pass` a `salt` jsou doménově specifické (password, salt pro kryptografii), ale metoda je univerzální a joinuje jakékoliv dva byte arraye!

#### ✅ SPRÁVNĚ:
```csharp
public static List<byte> JoinBytesArray(byte[] firstArray, byte[] secondArray)
```

#### ❌ ŠPATNĚ:
```csharp
public static string[] JoinVariableAndArray(object value, IList columns)
```
**Proč je to špatně:** `value` je příliš obecné, `columns` je doménově specifické (sloupce v tabulce)!

#### ✅ SPRÁVNĚ:
```csharp
public static string[] JoinVariableAndArray(object firstElement, IList items)
```

#### ❌ ŠPATNĚ:
```csharp
public static object[] ConvertListStringWrappedInArray(object[] innerMain)
```
**Proč je to špatně:** `innerMain` je nesmyslné - inner čeho? main čeho?

#### ✅ SPRÁVNĚ:
```csharp
public static object[] ConvertListStringWrappedInArray(object[] array)
```

#### ❌ ŠPATNĚ:
```csharp
private static string Replace(string text, string from, string to)
```
**Proč je to špatně:** `from` a `to` jsou zavádějící - v Replace metody jsou to `what` (co nahrazuji) a `replacement` (čím nahrazuji).

#### ✅ SPRÁVNĚ:
```csharp
private static string Replace(string text, string what, string replacement)
```

#### ❌ ŠPATNĚ:
```csharp
public static bool RemoveAndLeading(List<string> tokens, string value)
```
**Proč je to špatně:** `tokens` je doménově specifické (tokenizace), ale metoda pracuje s jakýmkoliv listem stringů!

#### ✅ SPRÁVNĚ:
```csharp
public static bool RemoveAndLeading(List<string> list, string value)
```

#### ❌ ŠPATNĚ:
```csharp
public static bool EndsWith(string fileName, List<string> allowedExtensions)
```
**Proč je to špatně:** `fileName` a `allowedExtensions` jsou doménově specifické (soubory), ale metoda je univerzální!

#### ✅ SPRÁVNĚ:
```csharp
public static bool EndsWith(string text, List<string> suffixes)
```

#### ❌ ŠPATNĚ:
```csharp
public static List<int> ReturnWhichContainsIndexes(string item, IList<string> terms)
```
**Proč je to špatně:** `item` je ZAKÁZÁNO pro parametry metod! Vyhrazeno pouze pro foreach iterační proměnné!

#### ✅ SPRÁVNĚ:
```csharp
public static List<int> ReturnWhichContainsIndexes(string text, IList<string> terms)
```

#### ❌ ŠPATNĚ:
```csharp
public static string StartWith(string prefix, IList<string> candidates, out int i)
```
**Proč je to špatně:** `i` je jednopísmenná proměnná - i jako out parametr musí mít popisný název!

#### ✅ SPRÁVNĚ:
```csharp
public static string StartWith(string prefix, IList<string> candidates, out int foundIndex)
```

#### ❌ ŠPATNĚ:
```csharp
public static void RemoveWhichContains(List<string> list, string item, bool wildcard)
{
    for (var i = list.Count - 1; i >= 0; i--)
        if (list[i].Contains(item))
            list.RemoveAt(i);
}
```
**Proč je to špatně:** `item` je **vyhrazeno pro iterační proměnné** v foreach cyklech (např. `foreach (var item in list)`). Použití `item` jako parametru metody je matoucí a může kolidovat s iteračními proměnnými. Navíc neříká co to je - vyhledávací vzor? Term? Hodnota?

#### ✅ SPRÁVNĚ:
```csharp
public static void RemoveWhichContains(List<string> list, string pattern, bool wildcard)
{
    for (var i = list.Count - 1; i >= 0; i--)
        if (list[i].Contains(pattern))
            list.RemoveAt(i);
}
```
**Alternativní správné názvy:** `searchTerm`, `value`, `term` - všechny jsou specifičtější a nevytvářejí konflikt s iteračními proměnnými.

## NOVÉ POZNATKY Z SUNAMOASYNC PROJEKTU (2025-12-20)

### České slova v kódu - VŽDY nahradit!

#### ❌ ŠPATNĚ - ČESKÉ SLOVO:
```csharp
internal static void InitFillWith(List<string> list, int pocet, string initWith = "")
{
    for (int i = 0; i < pocet; i++)
        list.Add(initWith);
}
```
**Proč je to špatně:** `pocet` je ČESKÉ slovo ("počet" = count)! Kód musí být VŽDY v angličtině!

#### ✅ SPRÁVNĚ:
```csharp
internal static void InitFillWith(List<string> list, int count, string initWith = "")
{
    for (int i = 0; i < count; i++)
        list.Add(initWith);
}
```

#### Další české slova nalezené v projektu:
- `nad` → `path` ("nad" = above, používáno pro cestu k souboru)
- `slozkyKVytvoreni` → `foldersToCreate` ("slozkyKVytvoreni" = folders to create)
- `kopia` → zbytečná proměnná, SMAZAT (navíc "kopia" = copy)
- `datas` → `list` (špatný plurál)

### Zkratky v názvech proměnných

#### ❌ ŠPATNĚ - ZKRATKY:
```csharp
public static AsyncHelper ci = new();
T ret = default;
List<T> arr = new();
readonly static StringBuilder sb = new();
internal static readonly Type tAction = typeof(Action);
```

#### ✅ SPRÁVNĚ:
```csharp
public static AsyncHelper Instance = new();
T result = default;
List<T> list = new();
readonly static StringBuilder stringBuilder = new();
internal static readonly Type ActionType = typeof(Action);
```

**Zkratky které byly opraveny:**
- `ci` → `Instance` (singleton instance)
- `ret` → `result` (return value)
- `arr` → `list` (array)
- `sb` → plný název (ale pozor na PascalCase u internal!)
- `t` prefix pro typy → plný název s `Type` suffixem

### Parametry metod s čísly

#### ❌ ŠPATNĚ - ČÍSELNÉ SUFFIXY:
```csharp
public T RunSync<T, T1>(Func<T1, T> task, T1 a1)
public T RunSync<T, T1, T2>(Func<T1, T2, T> task, T1 a1, T2 a2)
public T RunSync<T, T1, T2, T3>(Func<T1, T2, T3, T> task, T1 a1, T2 a2, T3 a3)
```
**Proč je to špatně:** `a1`, `a2`, `a3` jsou nekomunikativní - co znamená "a"? Co je to za parametr?

#### ✅ SPRÁVNĚ:
```csharp
public T RunSync<T, T1>(Func<T1, T> task, T1 argument1)
public T RunSync<T, T1, T2>(Func<T1, T2, T> task, T1 argument1, T2 argument2)
public T RunSync<T, T1, T2, T3>(Func<T1, T2, T3, T> task, T1 argument1, T2 argument2, T3 argument3)
```
**Alternativní názvy:** `param1`, `param2`, `param3` nebo ještě lépe specifické názvy podle účelu.

### Doménově specifické názvy pro delimiters

#### ❌ ŠPATNĚ - ZAVÁDĚJÍCÍ NÁZEV:
```csharp
internal static List<string> SplitChar(string text, params char[] dot)
{
    return text.Split(dot, StringSplitOptions.RemoveEmptyEntries).ToList();
}
```
**Proč je to špatně:** `dot` (tečka) je ZAVÁDĚJÍCÍ - parametr může být jakýkoliv delimiter (čárka, středník, mezera, cokoliv), ne jen tečka!

#### ✅ SPRÁVNĚ:
```csharp
internal static List<string> SplitChar(string text, params char[] delimiters)
{
    return text.Split(delimiters, StringSplitOptions.RemoveEmptyEntries).ToList();
}
```

### Nepoužívané proměnné - VŽDY SMAZAT!

#### ❌ ŠPATNĚ - NEPOUŽÍVANÁ PROMĚNNÁ:
```csharp
private class ExclusiveSynchronizationContext : SynchronizationContext
{
    private static Type type = typeof(ExclusiveSynchronizationContext);  // NIKDE SE NEPOUŽÍVÁ!
    // ... rest of code
}
```

#### ✅ SPRÁVNĚ - SMAZAT:
```csharp
private class ExclusiveSynchronizationContext : SynchronizationContext
{
    // Nepoužívaná proměnná byla smazána
    // ... rest of code
}
```

### Zbytečné pomocné proměnné

#### ❌ ŠPATNĚ - ZBYTEČNÁ PROMĚNNÁ:
```csharp
foreach (string item in foldersToCreate)
{
    string folder = item;  // ZBYTEČNÉ!
    if (!Directory.Exists(folder))
        Directory.CreateDirectory(folder);
}
```

#### ✅ SPRÁVNĚ - POUŽÍT PŘÍMO:
```csharp
foreach (string item in foldersToCreate)
{
    if (!Directory.Exists(item))
        Directory.CreateDirectory(item);
}
```

### Internal static fields - MUSÍ být PascalCase!

#### ❌ ŠPATNĚ - camelCase pro internal:
```csharp
readonly static StringBuilder sbAdditionalInfoInner = new();
readonly static StringBuilder sbAdditionalInfo = new();
```
**Proč je to špatně:** `internal` members jsou viditelné mimo třídu, takže MUSÍ používat PascalCase!

#### ✅ SPRÁVNĚ - PascalCase:
```csharp
internal readonly static StringBuilder AdditionalInfoInnerStringBuilder = new();
internal readonly static StringBuilder AdditionalInfoStringBuilder = new();
```

### Extension metody a Lambda výrazy - ŽÁDNÉ jednopísmenné názvy!

#### ❌ ŠPATNĚ - JEDNOPÍSMENNÉ NÁZVY:
```csharp
internal static ConfiguredTaskAwaitable Conf(this Task t)
{
    return t.ConfigureAwait(true);
}

internal static void LogExceptions(this Task task)
{
    task.ContinueWith(t =>
        {
            var aggException = t.Exception.Flatten();
            throw new Exception(Exceptions.TextOfExceptions(aggException));
        },
        TaskContinuationOptions.OnlyOnFaulted);
}
```
**Proč je to špatně:**
- `t` jako parametr extension metody je NEKOMUNIKATIVNÍ!
- `t` v lambda výrazu je NEKOMUNIKATIVNÍ - co je `t`? Task? Terminated? Temp?

#### ✅ SPRÁVNĚ - SAMOPOPISNÉ NÁZVY:
```csharp
internal static ConfiguredTaskAwaitable Conf(this Task task)
{
    return task.ConfigureAwait(true);
}

internal static void LogExceptions(this Task task)
{
    task.ContinueWith(completedTask =>
        {
            var aggException = completedTask.Exception.Flatten();
            throw new Exception(Exceptions.TextOfExceptions(aggException));
        },
        TaskContinuationOptions.OnlyOnFaulted);
}
```
**Proč je to správně:**
- `task` jasně říká že jde o Task
- `completedTask` v lambda říká že jde o dokončený task (kontext ContinueWith)
- Kód je okamžitě srozumitelný i bez dokumentace!

### Override metody - I ty musí mít samopopisné názvy!

#### ❌ ŠPATNĚ - JEDNOPÍSMENNÝ PARAMETR V OVERRIDE:
```csharp
public override void Post(SendOrPostCallback d, object state)
{
    lock (items)
    {
        items.Enqueue(Tuple.Create(d, state));
    }
    workItemsWaiting.Set();
}

public override void Send(SendOrPostCallback d, object state)
{
    throw new Exception("WeCannotSendToOurSameThread");
}
```
**Proč je to špatně:** `d` je NEKOMUNIKATIVNÍ - co je to `d`? Delegate? Data? Descriptor?

#### ✅ SPRÁVNĚ - SAMOPOPISNÝ NÁZEV:
```csharp
public override void Post(SendOrPostCallback callback, object state)
{
    lock (items)
    {
        items.Enqueue(Tuple.Create(callback, state));
    }
    workItemsWaiting.Set();
}

public override void Send(SendOrPostCallback callback, object state)
{
    throw new Exception("WeCannotSendToOurSameThread");
}
```
**Proč je to správně:** `callback` jasně říká že parametr je callback funkce!

## NOVÉ POZNATKY Z SUNAMO DATETIME PROJEKTU (2025-12-31)

### KRITICKÉ: Internal members MUSÍ být PascalCase!

**VŠECHNY `internal` members (fields, properties, methods, constants) MUSÍ používat PascalCase!**

#### ❌ ŠPATNĚ - camelCase pro internal konstanty:
```csharp
internal class DTConstants
{
    internal const long secondsInMinute = 60;
    internal const long secondsInHour = secondsInMinute * 60;
    internal const long secondsInDay = secondsInHour * 24;
    internal static readonly List<string> daysInWeekEN = new List<string> { "Monday", "Tuesday", ... };
    internal static readonly List<string> monthsInYearEN = new List<string> { "January", "February", ... };
    internal static DateTime unixTimeStartEpoch = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
}
```
**Proč je to špatně:** `internal` members jsou viditelné mimo třídu (v celém assembly), takže MUSÍ používat PascalCase podle C# konvencí!

#### ✅ SPRÁVNĚ - PascalCase:
```csharp
internal class DTConstants
{
    internal const long SecondsInMinute = 60;
    internal const long SecondsInHour = SecondsInMinute * 60;
    internal const long SecondsInDay = SecondsInHour * 24;
    internal static readonly List<string> DaysInWeekEN = new List<string> { "Monday", "Tuesday", ... };
    internal static readonly List<string> MonthsInYearEN = new List<string> { "January", "February", ... };
    internal static DateTime UnixTimeStartEpoch = new DateTime(1970, 1, 1, 0, 0, 0, 0, DateTimeKind.Utc);
}
```

**DŮLEŽITÉ:** Když přejmenuješ internal konstanty, MUSÍŠ najít a opravit VŠECHNA jejich použití v celém projektu!

```powershell
# Příklad: Najít všechna použití starých názvů
rg "\b(secondsInMinute|secondsInHour|secondsInDay)\b"
```

### Další doménově specifické názvy nalezené v SunamoDateTime

#### ❌ ŠPATNĚ - `altitudes` pro univerzální metodu:
```csharp
internal static List<int> ToInt2(IList altitudes, int requiredLength, int startFrom)
{
    return ToNumber<int>(BTS.TryParseInt, altitudes, requiredLength, startFrom);
}
```
**Proč je to špatně:** `altitudes` (nadmořské výšky) je DOMÉNOVĚ SPECIFICKÝ název! Metoda je univerzální a může zpracovat jakoukoliv kolekci čísel - ceny výrobků, teploty, skóre, cokoliv!

#### ✅ SPRÁVNĚ:
```csharp
internal static List<int> ToInt2(IList list, int requiredLength, int startFrom)
{
    return ToNumber<int>(BTS.TryParseInt, list, requiredLength, startFrom);
}
```

#### ❌ ŠPATNĚ - `enumerable` pro IList:
```csharp
internal static List<T> ToNumber<T>(Func<string, T, T> tryParse, IList enumerable, int requiredLength)
{
    int enumerableCount = enumerable.Count;
    foreach (var item in enumerable)
    {
        // ...
    }
}
```
**Proč je to špatně:** `enumerable` je MATOUCÍ - typ je `IList`, ne `IEnumerable`! Navíc je to příliš obecný název.

#### ✅ SPRÁVNĚ:
```csharp
internal static List<T> ToNumber<T>(Func<string, T, T> tryParse, IList list, int requiredLength)
{
    int listCount = list.Count;
    foreach (var item in list)
    {
        // ...
    }
}
```

### Další zkratky nalezené v SunamoDateTime

#### ❌ ŠPATNĚ - zkratky v lokálních proměnných:
```csharp
List<T> vr = new List<T>(finalLength);  // vr = ???
T y = default(T);                        // y = ???
var yy = tryParse.Invoke(item.ToString(), y);  // yy = ???
List<string> ts = GetValues();           // ts = ???
long mal = 365;                          // mal = malý? (české slovo!)
```

#### ✅ SPRÁVNĚ - plné názvy:
```csharp
List<T> result = new List<T>(finalLength);
T defaultValue = default(T);
var parsedValue = tryParse.Invoke(item.ToString(), defaultValue);
List<string> values = GetValues();
long daysInYear = 365;
```

**Seznam zakázaných zkratek:**
- `vr` → `result` (variable result)
- `ret` → `result` (return value)
- `ts` → `values` / `items` (to string?)
- `sb` → `stringBuilder` (nebo `StringBuilder` pro internal)
- `y`, `yy` → `defaultValue`, `parsedValue` (jednopísmenné)
- `mal` → `daysInYear` (české slovo "málo")
- `i` (mimo for loop) → `currentIndex` / `index`

### Jednopísmenné proměnné mimo for loop - VŽDY ZAKÁZANÉ!

#### ❌ ŠPATNĚ - `i` jako counter mimo for loop:
```csharp
T i = default(T);
foreach (var item in list)
{
    if (i.CompareTo(startFrom) != 0)
    {
        continue;
    }
    // ... použití i jako counter
}
```
**Proč je to špatně:** `i` je vyhrazeno POUZE pro indexy v `for` cyklech! Ve `foreach` nebo jako obecný counter je ZAKÁZANÉ!

#### ✅ SPRÁVNĚ:
```csharp
T currentIndex = default(T);
foreach (var item in list)
{
    if (currentIndex.CompareTo(startFrom) != 0)
    {
        continue;
    }
    // ... použití currentIndex jako counter
}
```

### Checklist pro přejmenování internal konstant:

1. ✅ **Najdi soubor s konstantami** (např. DTConstants.cs)
2. ✅ **Přejmenuj všechny internal members na PascalCase**
3. ✅ **Najdi VŠECHNA použití** starých názvů v projektu:
   ```bash
   rg "\b(starýNázev1|starýNázev2|starýNázev3)\b"
   ```
4. ✅ **Oprav VŠECHNA použití** na nové PascalCase názvy
5. ✅ **Zkontroluj že nezůstaly žádné staré názvy**:
   ```bash
   rg "\b(starýNázev1|starýNázev2|starýNázev3)\b"  # Mělo by vrátit 0 výsledků
   ```
6. ✅ **Parametry metod s camelCase verzí** (např. `long secondsInHour` jako parametr) jsou OK - parametry jsou vždy camelCase!

### České názvy s číselnými suffixy - DVOJITÝ PROBLÉM!

Kombinace českého názvu + číselný suffix je **DVOJITĚ ŠPATNĚ**:

#### ❌ ŠPATNĚ - ČESKÉ NÁZVY S ČÍSLY:
```csharp
public static DateTime IsValidDateTimeText(string datum)
{
    DateTime vr = DateTime.MinValue;
    int indexMezery = datum.IndexOf(' ');
    if (indexMezery != -1)
    {
        var datum2 = DateTime.Today;
        var cas2 = DateTime.Today;
        var datum3 = datum.Substring(0, indexMezery);
        var cas3 = datum.Substring(indexMezery + 1);
        // ...
        if (datum2 != DateTime.MinValue && cas2 != DateTime.MinValue)
        {
            vr = new DateTime(datum2.Year, datum2.Month, datum2.Day, cas2.Hour, cas2.Minute, cas2.Second);
        }
    }
    return vr;
}
```
**Proč je to špatně:**
- `datum` = ČESKÉ slovo (date)
- `cas` = ČESKÉ slovo (time)
- `indexMezery` = ČESKÉ slovo (mezery = space)
- `datum2`, `cas2`, `datum3`, `cas3` = ČESKÉ názvy + číselné suffixy!
- `vr` = zkratka (variable result)

#### ✅ SPRÁVNĚ - ANGLICKÉ NÁZVY BEZ ČÍSEL:
```csharp
public static DateTime IsValidDateTimeText(string text)
{
    DateTime result = DateTime.MinValue;
    int spaceIndex = text.IndexOf(' ');
    if (spaceIndex != -1)
    {
        var parsedDate = DateTime.Today;
        var parsedTime = DateTime.Today;
        var dateText = text.Substring(0, spaceIndex);
        var timeText = text.Substring(spaceIndex + 1);
        // ...
        if (parsedDate != DateTime.MinValue && parsedTime != DateTime.MinValue)
        {
            result = new DateTime(parsedDate.Year, parsedDate.Month, parsedDate.Day, parsedTime.Hour, parsedTime.Minute, parsedTime.Second);
        }
    }
    return result;
}
```
**Proč je to správně:**
- `text` = anglický, obecný název pro string parametr
- `result` = anglický, samopopisný název pro return value
- `spaceIndex` = anglický, popisuje co obsahuje
- `parsedDate`, `parsedTime` = anglické, vyjadřují co proměnná obsahuje (naparsované hodnoty)
- `dateText`, `timeText` = anglické, vyjadřují co proměnná obsahuje (substring s datem/časem)
- ŽÁDNÉ číselné suffixy!

**Další české názvy pro indexy nalezené v SunamoDateTime:**
- `indexTecky` → `dotIndex` ("tečky" = dots, genetiv plurálu od "tečka")
- `indexMezery` → `spaceIndex` ("mezery" = space, genetiv singulár od "mezera")
- `indexCiarky` → `commaIndex` ("čárky" = comma)

### Public static fields s "x" prefixem - MUSÍ být PascalCase!

#### ❌ ŠPATNĚ - camelCase s "x" prefixem:
```csharp
public static string xNotIndicated = "NotIndicated";
public static string xfilesFounded = "filesFounded";
```
**Proč je to špatně:** `public` static fields MUSÍ být PascalCase! Prefix "x" (pravděpodobně znamená "export" nebo "external") sám o sobě je diskutabilní, ale pokud tam je, musí být velký.

#### ✅ SPRÁVNĚ - PascalCase:
```csharp
public static string XNotIndicated = "NotIndicated";
public static string XFilesFounded = "filesFounded";
```
**Nebo ještě lépe - bez "x" prefixu:**
```csharp
public static string NotIndicated = "NotIndicated";
public static string FilesFounded = "filesFounded";
```

### Konvence pro speciální typy - SunamoDateTime

#### Typ `LangsDt` - VŽDY pojmenovat `lang`

V celém SunamoDateTime projektu platí:
- **VŠECHNY** parametry typu `LangsDt` MUSÍ být pojmenovány `lang`, NIKDY `l`!

#### ❌ ŠPATNĚ:
```csharp
public string ToString(LangsDt l)
{
    if (l == LangsDt.cs)
        return ToStringDateTime(l);
}

public static string TimeToString(DateTime d, LangsDt l, DateTime dtMinVal)
{
    if (l == LangsDt.cs) { ... }
}
```

#### ✅ SPRÁVNĚ:
```csharp
public string ToString(LangsDt lang)
{
    if (lang == LangsDt.cs)
        return ToStringDateTime(lang);
}

public static string TimeToString(DateTime dateTime, LangsDt lang, DateTime dtMinVal)
{
    if (lang == LangsDt.cs) { ... }
}
```

**Důvod:** `LangsDt` je doménově specifický typ který reprezentuje jazyk (Language). Název `lang` je standardní zkratka pro "language" a je dostatečně samopopisný. `l` je jednopísmenná zkratka která je ZAKÁZANÁ.