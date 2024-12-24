namespace SunamoGpx._sunamo;
internal class ThrowEx
{
    internal static void Custom(string message)
    {
#if DEBUG
        Debugger.Break();
#endif
        throw new Exception(message);
    }
}