// Polyfills for net48 that PolySharp cannot generate (BCL instance/extension APIs).
// Type polyfills (IsExternalInit, RequiredMember, Index/Range, ...) come from the
// PolySharp package referenced in Directory.Build.props.
#if !NET5_0_OR_GREATER

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

// global namespace so the extensions bind even in files without the matching using
// (on net8+ these are instance methods and call sites do not import the namespace)
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

namespace System.Runtime.Versioning
{
    // net48 has these only as internal types in mscorlib; PolySharp does not generate them
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
