namespace SunamoGitConfig._sunamo;
internal class ThrowEx
{
    internal static void NotImplementedCase(object _case)
    {
        throw new Exception("Not implemented case: " + _case);
    }
    internal static void Custom(string v)
    {
        throw new Exception(v);
    }
}
