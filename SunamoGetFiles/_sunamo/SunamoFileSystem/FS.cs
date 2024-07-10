namespace SunamoGetFiles._sunamo.SunamoFileSystem;
internal class FS
{
    internal static string ReplaceInvalidFileNameChars(string filename, params char[] ch)
    {
        return string.Concat(filename.Split(Path.GetInvalidFileNameChars()));
    }
    internal static string AllIncludeIfOnlyLetters(string item)
    {
        item = item.ToLower().TrimStart('*').TrimStart('.');
        //if ( SH.ContainsOnlyCase(item.ToLower(), false, false))
        //{
        item = "*." + item;
        //}


        return item;
    }

    internal static string GetNormalizedExtension(string filename)
    {
        return NormalizeExtension(filename);
    }

    internal static string GetSizeInAutoString(double size)
    {


        ComputerSizeUnits unit = ComputerSizeUnits.B;
        if (size > NumConsts.kB)
        {
            unit = ComputerSizeUnits.KB;
            size /= NumConsts.kB;
        }
        if (size > NumConsts.kB)
        {
            unit = ComputerSizeUnits.MB;
            size /= NumConsts.kB;
        }
        if (size > NumConsts.kB)
        {
            unit = ComputerSizeUnits.GB;
            size /= NumConsts.kB;
        }
        if (size > NumConsts.kB)
        {
            unit = ComputerSizeUnits.TB;
            size /= NumConsts.kB;
        }

        return size + " " + unit.ToString();
    }

    internal static DateTime LastModified(string rel)
    {
        if (File.Exists(rel))
        {
            return File.GetLastWriteTime(rel);

            // FileInfo mi dr�el soubor a vznikali chyby The process cannot access the file
            //var f = new FileInfo(rel);
            //var r = f.LastWriteTime;
            //return r;
        }
        return DateTime.MinValue;

    }

    internal static string MascFromExtension(string ext2 = AllStrings.asterisk)
    {
        if (char.IsLetterOrDigit(ext2[0]))
        {
            // For wildcard, dot (simply non letters) include .
            ext2 = "." + ext2;
        }
        if (!ext2.StartsWith("*"))
        {
            ext2 = "*" + ext2;
        }
        if (!ext2.StartsWith("*.") && ext2.StartsWith(AllStrings.dot))
        {
            ext2 = "*." + ext2;
        }

        return ext2;

        //if (ext2 == ".*")
        //{
        //    return "*.*";
        //}


        //var ext = Path.GetExtension(ext2);
        //var fn = Path.GetFileNameWithoutExtension(ext2);
        //// isContained must be true, in BundleTsFile if false masc will be .ts, not *.ts and won't found any file
        //var isContained = AllExtensionsHelper.IsContained(ext);
        //ComplexInfoString cis = new ComplexInfoString(fn);

        ////Already tried
        ////(cis.QuantityLowerChars > 0 || cis.QuantityUpperChars > 0);
        //// (cis.QuantityLowerChars > 0 || cis.QuantityUpperChars > 0); - in MoveClassElementIntoSharedFileUC
        //// !(!ext.Contains("*") && !ext.Contains("?") && !(cis.QuantityLowerChars > 0 || cis.QuantityUpperChars > 0)) - change due to MoveClassElementIntoSharedFileUC

        //// not working for *.aspx.cs
        ////var isNoMascEntered = !(!ext2.Contains("*") && !ext2.Contains("?") && !(cis.QuantityLowerChars > 0 || cis.QuantityUpperChars > 0));
        //// Is succifient one of inner condition false and whole is true

        //var isNoMascEntered = !((ext2.Contains("*") || ext2.Contains("?")));// && !(cis.QuantityLowerChars > 0 || cis.QuantityUpperChars > 0));
        //// From base of logic - isNoMascEntered must be without !. When something another wont working, edit only evaluate of condition above
        //if (!ext.StartsWith("*.") && isNoMascEntered && isContained && ext == Path.GetExtension( ext2))
        //{
        //    // Dont understand why, when I insert .aspx.cs, then return just .aspx without *
        //    //if (cis.QuantityUpperChars > 0 || cis.QuantityLowerChars > 0)
        //    //{
        //    //    return ext2;
        //    //}

        //    var vr = AllStrings.asterisk + AllStrings.dot + ext2.TrimStart(AllChars.dot);
        //    return vr;
        //}

        //return ext2;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    internal static string NormalizeExtension(string item)
    {
        return AllStrings.dot + item.TrimStart(AllChars.dot);
    }

    internal static void NormalizeExtensions(List<string> extension)
    {
        for (int i = 0; i < extension.Count; i++)
        {
            extension[i] = NormalizeExtension(extension[i]);
        }
    }
}
