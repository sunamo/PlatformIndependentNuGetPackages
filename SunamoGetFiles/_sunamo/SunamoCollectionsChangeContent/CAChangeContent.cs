namespace SunamoGetFiles._sunamo.SunamoCollectionsChangeContent;


internal class CAChangeContent
{
    private static void RemoveNullOrEmpty(ChangeContentArgsGetFiles a, List<string> files_in)
    {
        if (a != null)
        {
            if (a.removeNull)
            {
                files_in.Remove(null);
            }
            if (a.removeEmpty)
            {
                for (int i = files_in.Count - 1; i >= 0; i--)
                {
                    if (files_in[i].Trim() == string.Empty)
                    {
                        files_in.RemoveAt(i);
                    }
                }
            }
        }
    }
    /// <summary>
    /// Direct edit
    /// If not every element fullfil pattern, is good to remove null (or values returned if cant be changed) from result
    ///
    /// Poslední číslo je počet parametrů jež se předávají do delegátu
    /// </summary>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    internal static List<string> ChangeContent0(ChangeContentArgsGetFiles a, List<string> files_in, Func<string, string> func)
    {
        for (int i = 0; i < files_in.Count; i++)
        {
            files_in[i] = func.Invoke(files_in[i]);
        }
        RemoveNullOrEmpty(a, files_in);
        return files_in;
    }
    /// <summary>
    /// Direct edit
    ///
    /// Poslední číslo je počet parametrů jež se předávají do delegátu
    /// </summary>
    /// <param name="a"></param>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    /// <param name="a1"></param>
    /// <returns></returns>
    internal static List<string> ChangeContent1(ChangeContentArgsGetFiles a, List<string> files_in, Func<string, string, string> func, string a1)
    {
        var result = ChangeContent<string>(a, files_in, func, a1);
        return result;
    }
    /// <summary>
    /// Poslední číslo je počet parametrů jež se předávají do delegátu
    /// </summary>
    /// <param name="a"></param>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    /// <param name="a1"></param>
    /// <param name="a2"></param>
    /// <returns></returns>
    internal static List<string> ChangeContent2(ChangeContentArgsGetFiles a, List<string> files_in, Func<string, string, string, string> func, string a1, string a2)
    {
        for (int i = 0; i < files_in.Count; i++)
        {
            files_in[i] = func.Invoke(files_in[i], a1, a2);
        }
        RemoveNullOrEmpty(a, files_in);
        return files_in;
    }
    /// <summary>
    /// Direct edit
    /// Earlier name was ChangeContent , but has Predicate => ChangeContentWithCondition
    /// </summary>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    internal static bool ChangeContentWithCondition(ChangeContentArgsGetFiles a, List<string> files_in, Predicate<string> predicate, Func<string, string> func)
    {
        bool changed = false;
        for (int i = 0; i < files_in.Count; i++)
        {
            if (predicate.Invoke(files_in[i]))
            {
                files_in[i] = func.Invoke(files_in[i]);
                changed = true;
            }
        }
        RemoveNullOrEmpty(a, files_in);
        return changed;
    }
    #region Vem obojí
    internal static List<string> ChangeContentSwitch12<Arg1>(List<string> files_in, Func<Arg1, string, string> func, Arg1 arg)
    {
        for (int i = 0; i < files_in.Count; i++)
        {
            files_in[i] = func.Invoke(arg, files_in[i]);
        }
        return files_in;
    }
    /// <summary>
    /// Direct edit input collection
    ///
    /// Dříve to bylo List<string> files_in, Func<string,
    /// </summary>
    /// <typeparam name="Arg1"></typeparam>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    /// <param name="arg"></param>
    internal static List<string> ChangeContent<Arg1>(ChangeContentArgsGetFiles a, List<string> files_in, Func<string, Arg1, string> func, Arg1 arg, Func<Arg1, string, string> funcSwitch12 = null)
    {
        if (a == null)
        {
            a = null;
        }
        if (a.switchFirstAndSecondArg)
        {
            files_in = ChangeContentSwitch12<Arg1>(files_in, funcSwitch12, arg);
        }
        else
        {
            for (int i = 0; i < files_in.Count; i++)
            {
                files_in[i] = func.Invoke(files_in[i], arg);
            }
        }
        RemoveNullOrEmpty(a, files_in);
        return files_in;
    }
    #endregion
    #region ChangeContent for easy copy
    /// <summary>
    /// Direct edit
    /// </summary>
    /// <typeparam name="T1"></typeparam>
    /// <typeparam name="TResult"></typeparam>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    private static List<TResult> ChangeContent<T1, TResult>(List<T1> files_in, Func<T1, TResult> func)
    {
        List<TResult> result = new List<TResult>(files_in.Count);
        for (int i = 0; i < files_in.Count; i++)
        {
            result.Add(func.Invoke(files_in[i]));
        }
        return result;
    }
    /// <summary>
    /// TResult is the same type as T1 (output collection is the same generic as input)
    /// </summary>
    /// <typeparam name="T1"></typeparam>
    /// <typeparam name="T2"></typeparam>
    /// <typeparam name="TResult"></typeparam>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    private static List<TResult> ChangeContent<T1, T2, TResult>(ChangeContentArgsGetFiles a, Func<T1, T2, TResult> func, List<T1> files_in, T2 t2)
    {
        List<TResult> result = new List<TResult>(files_in.Count);
        for (int i = 0; i < files_in.Count; i++)
        {
            // Fully generic - no strict string can't return the same collection
            result.Add(func.Invoke(files_in[i], t2));
        }
        //CA.RemoveDefaultT<TResult>(result);
        return result;
    }
    /// <summary>
    /// Direct edit
    /// </summary>
    /// <typeparam name="Arg1"></typeparam>
    /// <typeparam name="Arg2"></typeparam>
    /// <param name="files_in"></param>
    /// <param name="func"></param>
    /// <param name="arg1"></param>
    /// <param name="arg2"></param>
    internal static List<string> ChangeContent<Arg1, Arg2>(ChangeContentArgsGetFiles a, List<string> files_in, Func<string, Arg1, Arg2, string> func, Arg1 arg1, Arg2 arg2)
    {
        for (int i = 0; i < files_in.Count; i++)
        {
            files_in[i] = func.Invoke(files_in[i], arg1, arg2);
        }
        RemoveNullOrEmpty(a, files_in);
        return files_in;
    }
    #endregion
}