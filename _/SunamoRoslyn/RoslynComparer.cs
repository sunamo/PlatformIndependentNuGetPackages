namespace SunamoRoslyn;

public class RoslynComparer
{
    static Type type = typeof(RoslynComparer);

    public static bool Modifiers(SyntaxTokenList modifiers1, SyntaxTokenList modifiers2)
    {
        if (modifiers1.Count != modifiers2.Count)
        {
            return false;
        }
        //ThrowEx.DifferentCountInLists(Exc.GetStackTrace(),type, "Modifiers", "modifiers1", modifiers1, "modifiers2", modifiers2);

        for (int i = 0; i < modifiers2.Count; i++)
        {
            if (modifiers2[i].Value != modifiers1[i].Value)
            {
                return false;
            }
        }

        return true;
    }
}
