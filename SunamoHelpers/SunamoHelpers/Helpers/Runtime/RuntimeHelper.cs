namespace SunamoHelpers.Helpers.Runtime;

internal class RuntimeHelper
{
#pragma warning disable
    internal static void EmptyDummyMethod(string text, params Object[] args)
    {
    }
#pragma warning restore

#pragma warning disable CS0649
    internal static Action<TypeOfMessageShared, string, Object[]>? EmptyDummyMethodLogMessage;
#pragma warning restore CS0649
}
