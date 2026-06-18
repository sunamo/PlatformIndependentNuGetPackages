#Requires -Version 7.0
# Makes the 123 NuGet source projects compile for net48 (wrappers in .net48/) and
# adds netstandard2.0 to the original csproj files.
#
# Phases (each can be skipped):
#   1. -SkipTransforms : mechanical .cs rewrites that are version-neutral
#        - ArgumentNullException.ThrowIfNull(x)        -> if (x == null) throw new ArgumentNullException(nameof(x));
#        - string.Join('x', ...)                       -> string.Join("x", ...)
#        - Enum.GetValues<T>()                         -> ((T[])Enum.GetValues(typeof(T)))
#        - nint.Zero                                   -> 0
#        - File.*Async(                                -> FileAsync.*Async(   (helper in Net48Polyfills.cs)
#   2. -SkipPolyfills  : writes Net48Polyfills.cs into each project root
#   3. -SkipCsproj     : original csproj: + netstandard2.0, LangVersion latest, PolySharp,
#                        conditional Microsoft.CSharp / System.Collections.Immutable for netstandard2.0

param(
    [switch]$SkipTransforms,
    [switch]$SkipPolyfills,
    [switch]$SkipCsproj
)

$base = "E:\vs\Projects\PlatformIndependentNuGetPackages"
$projectNames = Get-ChildItem "$base\.net48" -Filter "*.Net48.csproj" | ForEach-Object { $_.BaseName -replace '\.Net48$', '' } | Sort-Object

function Get-SourceFiles {
    param([string]$sourceDir)
    Get-ChildItem $sourceDir -Recurse -Filter "*.cs" |
        Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' -and $_.Name -ne 'Net48Polyfills.cs' }
}

function Save-TextPreservingBom {
    param([string]$filePath, [string]$content, [bool]$hadBom)
    $encoding = [System.Text.UTF8Encoding]::new($hadBom)
    [System.IO.File]::WriteAllText($filePath, $content, $encoding)
}

# ─── Phase 1: .cs transforms ──────────────────────────────────────────────────
if (-not $SkipTransforms) {
    $totalCounts = [ordered]@{ ThrowIfNull2 = 0; ThrowIfNull1 = 0; JoinChar = 0; EnumGetValues = 0; NintZero = 0; FileAsync = 0 }
    foreach ($name in $projectNames) {
        $sourceDir = Join-Path $base "$name\$name"
        if (-not (Test-Path $sourceDir)) { Write-Warning "missing source dir: $sourceDir"; continue }
        foreach ($file in Get-SourceFiles $sourceDir) {
            $original = [System.IO.File]::ReadAllText($file.FullName)
            $hadBom = $false
            $bytes = [System.IO.File]::ReadAllBytes($file.FullName) | Select-Object -First 3
            if ($bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $hadBom = $true }
            $content = $original

            # ThrowIfNull two-arg first (more specific)
            $content = [regex]::Replace($content,
                'ArgumentNullException\.ThrowIfNull\((\w+),\s*(nameof\(\w+\)|"[^"]*")\);',
                { param($m) $script:totalCounts.ThrowIfNull2++; "if ($($m.Groups[1].Value) == null) throw new ArgumentNullException($($m.Groups[2].Value));" })
            $content = [regex]::Replace($content,
                'ArgumentNullException\.ThrowIfNull\((\w+)\);',
                { param($m) $script:totalCounts.ThrowIfNull1++; "if ($($m.Groups[1].Value) == null) throw new ArgumentNullException(nameof($($m.Groups[1].Value)));" })

            # string.Join('x', -> string.Join("x",  (keeps escape sequences like \n, \t)
            $content = [regex]::Replace($content,
                "string\.Join\('(\\.|[^'\\])'",
                { param($m) $script:totalCounts.JoinChar++; $ch = $m.Groups[1].Value; if ($ch -eq "\'") { $ch = "'" } elseif ($ch -eq '"') { $ch = '\"' }; "string.Join(`"$ch`"" })

            # Enum.GetValues<T>() -> ((T[])Enum.GetValues(typeof(T)))
            $content = [regex]::Replace($content,
                'Enum\.GetValues<(\w+)>\(\)',
                { param($m) $script:totalCounts.EnumGetValues++; "(($($m.Groups[1].Value)[])Enum.GetValues(typeof($($m.Groups[1].Value))))" })

            # nint.Zero -> 0
            $content = [regex]::Replace($content,
                '\bnint\.Zero\b',
                { param($m) $script:totalCounts.NintZero++; "0" })

            # File.XAsync( -> FileAsync.XAsync(  (qualified form first)
            $fileAsyncMethods = 'ReadAllText|WriteAllText|ReadAllLines|WriteAllLines|ReadAllBytes|WriteAllBytes|AppendAllText|AppendAllLines'
            $content = [regex]::Replace($content,
                "System\.IO\.File\.($fileAsyncMethods)Async\(",
                { param($m) $script:totalCounts.FileAsync++; "FileAsync.$($m.Groups[1].Value)Async(" })
            $content = [regex]::Replace($content,
                "\bFile\.($fileAsyncMethods)Async\(",
                { param($m) $script:totalCounts.FileAsync++; "FileAsync.$($m.Groups[1].Value)Async(" })
            # FileMs is an alias for System.IO.File used in several projects
            $content = [regex]::Replace($content,
                "\bFileMs\.($fileAsyncMethods)Async\(",
                { param($m) $script:totalCounts.FileAsync++; "FileAsync.$($m.Groups[1].Value)Async(" })

            # Path.GetRelativePath does not exist on net48/netstandard2.0
            $content = [regex]::Replace($content,
                '\bPath\.GetRelativePath\(',
                { param($m) $script:totalCounts.FileAsync++; "PathPolyfill.GetRelativePath(" })

            if ($content -ne $original) {
                Save-TextPreservingBom $file.FullName $content $hadBom
            }
        }
    }
    Write-Host "Transforms applied:"
    $totalCounts.GetEnumerator() | ForEach-Object { Write-Host ("  {0,-15} {1}" -f $_.Key, $_.Value) }
}

# ─── Phase 2: Net48Polyfills.cs into each project root ───────────────────────
$polyfillContent = @'
// Compatibility helpers so the project compiles for net48/netstandard2.0 in addition to net8+.
// FileAsync is active for all target frameworks (forwards to File.*Async on modern ones).
// The extension polyfills below only compile for net48/netstandard2.0.
// Type polyfills (Index/Range, init, required, nullable attributes, ...) come from PolySharp.

internal static class FileAsync
{
#if NET5_0_OR_GREATER
    internal static System.Threading.Tasks.Task<string> ReadAllTextAsync(string path, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.ReadAllTextAsync(path, cancellationToken);

    internal static System.Threading.Tasks.Task<string> ReadAllTextAsync(string path, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.ReadAllTextAsync(path, encoding, cancellationToken);

    internal static System.Threading.Tasks.Task WriteAllTextAsync(string path, string? contents, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.WriteAllTextAsync(path, contents, cancellationToken);

    internal static System.Threading.Tasks.Task WriteAllTextAsync(string path, string? contents, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.WriteAllTextAsync(path, contents, encoding, cancellationToken);

    internal static System.Threading.Tasks.Task<string[]> ReadAllLinesAsync(string path, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.ReadAllLinesAsync(path, cancellationToken);

    internal static System.Threading.Tasks.Task<string[]> ReadAllLinesAsync(string path, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.ReadAllLinesAsync(path, encoding, cancellationToken);

    internal static System.Threading.Tasks.Task WriteAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.WriteAllLinesAsync(path, lines, cancellationToken);

    internal static System.Threading.Tasks.Task WriteAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.WriteAllLinesAsync(path, lines, encoding, cancellationToken);

    internal static System.Threading.Tasks.Task<byte[]> ReadAllBytesAsync(string path, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.ReadAllBytesAsync(path, cancellationToken);

    internal static System.Threading.Tasks.Task WriteAllBytesAsync(string path, byte[] bytes, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.WriteAllBytesAsync(path, bytes, cancellationToken);

    internal static System.Threading.Tasks.Task AppendAllTextAsync(string path, string? contents, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.AppendAllTextAsync(path, contents, cancellationToken);

    internal static System.Threading.Tasks.Task AppendAllTextAsync(string path, string? contents, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.AppendAllTextAsync(path, contents, encoding, cancellationToken);

    internal static System.Threading.Tasks.Task AppendAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Threading.CancellationToken cancellationToken = default)
        => System.IO.File.AppendAllLinesAsync(path, lines, cancellationToken);
#else
    internal static async System.Threading.Tasks.Task<string> ReadAllTextAsync(string path, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var reader = new System.IO.StreamReader(path);
        return await reader.ReadToEndAsync().ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task<string> ReadAllTextAsync(string path, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var reader = new System.IO.StreamReader(path, encoding);
        return await reader.ReadToEndAsync().ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task WriteAllTextAsync(string path, string? contents, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, false);
        await writer.WriteAsync(contents ?? string.Empty).ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task WriteAllTextAsync(string path, string? contents, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, false, encoding);
        await writer.WriteAsync(contents ?? string.Empty).ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task<string[]> ReadAllLinesAsync(string path, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var lines = new System.Collections.Generic.List<string>();
        using var reader = new System.IO.StreamReader(path);
        string? line;
        while ((line = await reader.ReadLineAsync().ConfigureAwait(false)) != null)
        {
            lines.Add(line);
        }
        return lines.ToArray();
    }

    internal static async System.Threading.Tasks.Task<string[]> ReadAllLinesAsync(string path, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var lines = new System.Collections.Generic.List<string>();
        using var reader = new System.IO.StreamReader(path, encoding);
        string? line;
        while ((line = await reader.ReadLineAsync().ConfigureAwait(false)) != null)
        {
            lines.Add(line);
        }
        return lines.ToArray();
    }

    internal static async System.Threading.Tasks.Task WriteAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, false);
        foreach (var line in lines)
        {
            await writer.WriteLineAsync(line).ConfigureAwait(false);
        }
    }

    internal static async System.Threading.Tasks.Task WriteAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, false, encoding);
        foreach (var line in lines)
        {
            await writer.WriteLineAsync(line).ConfigureAwait(false);
        }
    }

    internal static async System.Threading.Tasks.Task<byte[]> ReadAllBytesAsync(string path, System.Threading.CancellationToken cancellationToken = default)
    {
        using var stream = new System.IO.FileStream(path, System.IO.FileMode.Open, System.IO.FileAccess.Read, System.IO.FileShare.Read, 4096, useAsync: true);
        var bytes = new byte[stream.Length];
        int totalRead = 0;
        while (totalRead < bytes.Length)
        {
            int bytesRead = await stream.ReadAsync(bytes, totalRead, bytes.Length - totalRead, cancellationToken).ConfigureAwait(false);
            if (bytesRead == 0)
            {
                throw new System.IO.EndOfStreamException();
            }
            totalRead += bytesRead;
        }
        return bytes;
    }

    internal static async System.Threading.Tasks.Task WriteAllBytesAsync(string path, byte[] bytes, System.Threading.CancellationToken cancellationToken = default)
    {
        using var stream = new System.IO.FileStream(path, System.IO.FileMode.Create, System.IO.FileAccess.Write, System.IO.FileShare.None, 4096, useAsync: true);
        await stream.WriteAsync(bytes, 0, bytes.Length, cancellationToken).ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task AppendAllTextAsync(string path, string? contents, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, true);
        await writer.WriteAsync(contents ?? string.Empty).ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task AppendAllTextAsync(string path, string? contents, System.Text.Encoding encoding, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, true, encoding);
        await writer.WriteAsync(contents ?? string.Empty).ConfigureAwait(false);
    }

    internal static async System.Threading.Tasks.Task AppendAllLinesAsync(string path, System.Collections.Generic.IEnumerable<string> lines, System.Threading.CancellationToken cancellationToken = default)
    {
        cancellationToken.ThrowIfCancellationRequested();
        using var writer = new System.IO.StreamWriter(path, true);
        foreach (var line in lines)
        {
            await writer.WriteLineAsync(line).ConfigureAwait(false);
        }
    }
#endif
}

internal static class PathPolyfill
{
#if NET5_0_OR_GREATER
    internal static string GetRelativePath(string relativeTo, string path)
        => System.IO.Path.GetRelativePath(relativeTo, path);
#else
    internal static string GetRelativePath(string relativeTo, string path)
    {
        if (!relativeTo.EndsWith(System.IO.Path.DirectorySeparatorChar.ToString()) &&
            !relativeTo.EndsWith(System.IO.Path.AltDirectorySeparatorChar.ToString()))
        {
            relativeTo += System.IO.Path.DirectorySeparatorChar;
        }
        var fromUri = new System.Uri(relativeTo);
        var toUri = new System.Uri(path);
        if (fromUri.Scheme != toUri.Scheme)
        {
            return path;
        }
        var relativeUri = fromUri.MakeRelativeUri(toUri);
        var relativePath = System.Uri.UnescapeDataString(relativeUri.ToString());
        return relativePath.Replace('/', System.IO.Path.DirectorySeparatorChar);
    }
#endif
}

internal static class FileCompat
{
#if NET5_0_OR_GREATER
    internal static void Move(string sourceFileName, string destFileName, bool overwrite)
        => System.IO.File.Move(sourceFileName, destFileName, overwrite);
#else
    internal static void Move(string sourceFileName, string destFileName, bool overwrite)
    {
        if (overwrite && System.IO.File.Exists(destFileName))
        {
            System.IO.File.Delete(destFileName);
        }
        System.IO.File.Move(sourceFileName, destFileName);
    }
#endif
}

#if !NET5_0_OR_GREATER

internal static class Net48ProcessPolyfillExtensions
{
    internal static System.Threading.Tasks.Task WaitForExitAsync(this System.Diagnostics.Process process, System.Threading.CancellationToken cancellationToken = default)
    {
        var completionSource = new System.Threading.Tasks.TaskCompletionSource<object?>(System.Threading.Tasks.TaskCreationOptions.RunContinuationsAsynchronously);
        process.EnableRaisingEvents = true;
        process.Exited += (sender, eventArgs) => completionSource.TrySetResult(null);
        if (process.HasExited)
        {
            completionSource.TrySetResult(null);
        }
        if (cancellationToken.CanBeCanceled)
        {
            cancellationToken.Register(() => completionSource.TrySetCanceled(cancellationToken));
        }
        return completionSource.Task;
    }
}

internal static class Net48StreamPolyfillExtensions
{
    internal static void ReadExactly(this System.IO.Stream stream, byte[] buffer, int offset, int count)
    {
        int totalRead = 0;
        while (totalRead < count)
        {
            int bytesRead = stream.Read(buffer, offset + totalRead, count - totalRead);
            if (bytesRead == 0)
            {
                throw new System.IO.EndOfStreamException();
            }
            totalRead += bytesRead;
        }
    }

    internal static void ReadExactly(this System.IO.Stream stream, byte[] buffer)
    {
        stream.ReadExactly(buffer, 0, buffer.Length);
    }
}

internal static class Net48DbConnectionPolyfillExtensions
{
    internal static System.Threading.Tasks.Task CloseAsync(this System.Data.Common.DbConnection connection)
    {
        connection.Close();
        return System.Threading.Tasks.Task.CompletedTask;
    }
}

namespace System.Collections.Generic
{
    internal static class Net48CollectionPolyfillExtensions
    {
        internal static bool TryAdd<TKey, TValue>(this Dictionary<TKey, TValue> dictionary, TKey key, TValue value)
        {
            if (dictionary.ContainsKey(key))
            {
                return false;
            }
            dictionary.Add(key, value);
            return true;
        }
    }
}

namespace System
{
    internal static class Net48StringPolyfillExtensions
    {
        internal static string[] Split(this string text, string separator, StringSplitOptions options = StringSplitOptions.None)
        {
            return text.Split(new[] { separator }, options);
        }

        internal static string[] Split(this string text, char separator, StringSplitOptions options)
        {
            return text.Split(new[] { separator }, options);
        }

        internal static string Replace(this string text, string oldValue, string? newValue, StringComparison comparisonType)
        {
            if (oldValue == null)
            {
                throw new ArgumentNullException(nameof(oldValue));
            }
            if (oldValue.Length == 0)
            {
                throw new ArgumentException("String cannot be of zero length.", nameof(oldValue));
            }
            newValue ??= string.Empty;

            var result = new Text.StringBuilder(text.Length);
            int previousIndex = 0;
            int foundIndex = text.IndexOf(oldValue, comparisonType);
            while (foundIndex >= 0)
            {
                result.Append(text, previousIndex, foundIndex - previousIndex);
                result.Append(newValue);
                previousIndex = foundIndex + oldValue.Length;
                foundIndex = text.IndexOf(oldValue, previousIndex, comparisonType);
            }
            result.Append(text, previousIndex, text.Length - previousIndex);
            return result.ToString();
        }

        internal static bool StartsWith(this string text, char value)
        {
            return text.Length != 0 && text[0] == value;
        }

        internal static bool EndsWith(this string text, char value)
        {
            return text.Length != 0 && text[text.Length - 1] == value;
        }

        internal static bool Contains(this string text, char value)
        {
            return text.IndexOf(value) >= 0;
        }

        internal static bool Contains(this string text, string value, StringComparison comparisonType)
        {
            return text.IndexOf(value, comparisonType) >= 0;
        }

        internal static string ReplaceLineEndings(this string text)
        {
            return text.ReplaceLineEndings(Environment.NewLine);
        }

        internal static string ReplaceLineEndings(this string text, string replacementText)
        {
            string normalized = text.Replace("\r\n", "\n").Replace("\r", "\n");
            return replacementText == "\n" ? normalized : normalized.Replace("\n", replacementText);
        }
    }
}

namespace System.Runtime.Versioning
{
    // net48/netstandard2.0 do not have these attributes; PolySharp does not generate them
    [AttributeUsage(
        AttributeTargets.Assembly | AttributeTargets.Class | AttributeTargets.Constructor |
        AttributeTargets.Enum | AttributeTargets.Event | AttributeTargets.Field |
        AttributeTargets.Interface | AttributeTargets.Method | AttributeTargets.Module |
        AttributeTargets.Property | AttributeTargets.Struct,
        AllowMultiple = true, Inherited = false)]
    internal sealed class SupportedOSPlatformAttribute : Attribute
    {
        public SupportedOSPlatformAttribute(string platformName) { PlatformName = platformName; }
        public string PlatformName { get; }
    }

    [AttributeUsage(
        AttributeTargets.Assembly | AttributeTargets.Class | AttributeTargets.Constructor |
        AttributeTargets.Enum | AttributeTargets.Event | AttributeTargets.Field |
        AttributeTargets.Interface | AttributeTargets.Method | AttributeTargets.Module |
        AttributeTargets.Property | AttributeTargets.Struct,
        AllowMultiple = true, Inherited = false)]
    internal sealed class UnsupportedOSPlatformAttribute : Attribute
    {
        public UnsupportedOSPlatformAttribute(string platformName) { PlatformName = platformName; }
        public string PlatformName { get; }
    }
}

#endif
'@

if (-not $SkipPolyfills) {
    $writtenCount = 0
    foreach ($name in $projectNames) {
        $sourceDir = Join-Path $base "$name\$name"
        if (-not (Test-Path $sourceDir)) { continue }
        Set-Content (Join-Path $sourceDir "Net48Polyfills.cs") $polyfillContent -Encoding UTF8
        $writtenCount++
    }
    Write-Host "Net48Polyfills.cs written into $writtenCount projects"
}

# ─── Phase 3: original csproj edits ──────────────────────────────────────────
if (-not $SkipCsproj) {
    $editedCount = 0
    foreach ($name in $projectNames) {
        $csprojPath = Join-Path $base "$name\$name\$name.csproj"
        if (-not (Test-Path $csprojPath)) { Write-Warning "missing csproj: $csprojPath"; continue }
        $content = [System.IO.File]::ReadAllText($csprojPath)
        $originalContent = $content

        # TargetFrameworks + netstandard2.0
        if ($content -match '<TargetFrameworks>([^<]+)</TargetFrameworks>') {
            $frameworks = $Matches[1]
            if ($frameworks -notmatch 'netstandard2\.0') {
                $content = $content.Replace("<TargetFrameworks>$frameworks</TargetFrameworks>", "<TargetFrameworks>$frameworks;netstandard2.0</TargetFrameworks>")
            }
        } elseif ($content -match '<TargetFramework>([^<]+)</TargetFramework>') {
            $framework = $Matches[1]
            if ($framework -ne 'netstandard2.0') {
                $content = $content.Replace("<TargetFramework>$framework</TargetFramework>", "<TargetFrameworks>$framework;netstandard2.0</TargetFrameworks>")
            }
        }

        # LangVersion latest (netstandard2.0 would default to C# 7.3)
        if ($content -notmatch '<LangVersion>') {
            $content = $content -replace '(<TargetFrameworks?>[^<]+</TargetFrameworks?>)', "`$1`n    <LangVersion>latest</LangVersion>"
        }

        # PolySharp for type polyfills on netstandard2.0
        if ($content -notmatch 'PolySharp') {
            $polySharpItemGroup = @"
  <ItemGroup>
    <PackageReference Include="PolySharp" Version="1.15.0" PrivateAssets="all" />
  </ItemGroup>
"@
            $content = $content -replace '</Project>', "$polySharpItemGroup</Project>"
        }

        # netstandard2.0-only packages
        $sourceDir = Join-Path $base "$name\$name"
        $needsCSharp = $false
        $needsImmutable = $false
        foreach ($file in Get-SourceFiles $sourceDir) {
            $fileText = [System.IO.File]::ReadAllText($file.FullName)
            if ($fileText -match '\bdynamic\b') { $needsCSharp = $true }
            if ($fileText -match 'System\.Collections\.Immutable') { $needsImmutable = $true }
            if ($needsCSharp -and $needsImmutable) { break }
        }
        $conditionalPackages = @()
        if ($needsCSharp -and $content -notmatch '"Microsoft\.CSharp"') {
            $conditionalPackages += '    <PackageReference Include="Microsoft.CSharp" Version="4.7.0" />'
        }
        if ($needsImmutable -and $content -notmatch '"System\.Collections\.Immutable"') {
            $conditionalPackages += '    <PackageReference Include="System.Collections.Immutable" Version="8.0.0" />'
        }
        if ($conditionalPackages.Count -gt 0 -and $content -notmatch "ItemGroup Condition=`"'\`$\(TargetFramework\)' == 'netstandard2\.0'`"") {
            $conditionalItemGroup = "  <ItemGroup Condition=`"'`$(TargetFramework)' == 'netstandard2.0'`">`n" + ($conditionalPackages -join "`n") + "`n  </ItemGroup>`n"
            $content = $content -replace '</Project>', "$conditionalItemGroup</Project>"
        }

        # whitelist projects (EnableDefaultCompileItems=false) must include the polyfill file explicitly
        if ($content -match '<EnableDefaultCompileItems>false</EnableDefaultCompileItems>' -and $content -notmatch 'Net48Polyfills\.cs') {
            $firstCompileRegex = [regex]'(<Compile Include="[^"]+" />)'
            $content = $firstCompileRegex.Replace($content, "<Compile Include=`"Net48Polyfills.cs`" />`n    `$1", 1)
        }

        if ($content -ne $originalContent) {
            [System.IO.File]::WriteAllText($csprojPath, $content, [System.Text.UTF8Encoding]::new($false))
            $editedCount++
        }
    }
    Write-Host "Original csproj edited: $editedCount"
}

Write-Host "Done."
