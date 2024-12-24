namespace SunamoRoslyn._sunamo;
using SunamoRoslyn._public;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

internal class SH
{
    internal static string WrapWith(string value, string h)
    {
        return h + value + h;
    }

    internal static string WrapWithChar(string value, char v, bool _trimWrapping = false,
        bool alsoIfIsWhitespaceOrEmpty = true)
    {
        if (string.IsNullOrWhiteSpace(value) && !alsoIfIsWhitespaceOrEmpty) return string.Empty;
        // TODO: Make with StringBuilder, because of WordAfter and so
        return WrapWith(_trimWrapping ? value.Trim() : value, v.ToString());
    }

    internal static string WordAfter(string input, string word)
    {
        input = WrapWithChar(input, ' ');
        var dex = input.IndexOf(word);
        var dex2 = input.IndexOf(' ', dex + 1);
        var sb = new StringBuilder();
        if (dex2 != -1)
        {
            dex2++;
            for (var i = dex2; i < input.Length; i++)
            {
                var ch = input[i];
                if (ch != ' ')
                    sb.Append(ch);
                else
                    break;
            }
        }

        return sb.ToString();
    }

    #region SH.FirstCharUpper
    internal static void FirstCharUpper(ref string nazevPP)
    {
        nazevPP = FirstCharUpper(nazevPP);
    }


    internal static string FirstCharUpper(string nazevPP)
    {
        if (nazevPP.Length == 1)
        {
            return nazevPP.ToUpper();
        }

        string sb = nazevPP.Substring(1);
        return nazevPP[0].ToString().ToUpper() + sb;
    }
    #endregion

    internal static void GetPartsByLocation(out string pred, out string za, string text, int pozice)
    {
        if (pozice == -1)
        {
            pred = text;
            za = "";
        }
        else
        {
            pred = text.Substring(0, pozice);
            if (text.Length > pozice + 1)
                za = text.Substring(pozice + 1);
            else
                za = string.Empty;
        }
    }
    internal static List<string> SplitCharMore(string s, params char[] dot)
    {
        return s.Split(dot, StringSplitOptions.RemoveEmptyEntries).ToList();
    }

    internal static bool Contains(string input, StringOrStringList termO, SearchStrategyRoslyn searchStrategy = SearchStrategyRoslyn.FixedSpace, bool caseSensitive = false, bool isEnoughPartialContainsOfSplitted = true)
    {
        string term = null;

        if (!caseSensitive)
        {
            input = input.ToLower();
            term = termO.GetString().ToLower();
        }

        // musel bych dotáhnout min 2 metody a další enumy
        if (searchStrategy == SearchStrategyRoslyn.ExactlyName)
        {
            return input == term;
        }

        if (searchStrategy == SearchStrategyRoslyn.AnySpaces)
        {
            var pInput = input.Split(input.Where(ch => !char.IsLetterOrDigit(ch)).ToArray(), StringSplitOptions.RemoveEmptyEntries);
            var pTerm = termO.GetList();

            if (pInput.Length == 1)
            {
                foreach (var item in pTerm)
                {
                    if (!input.Contains(item))
                    {
                        return false;
                    }
                }
            }

            if (isEnoughPartialContainsOfSplitted)
            {
                foreach (var item in pTerm)
                {
                    if (!input.Contains(item))
                    {
                        return false;
                    }
                }
                return true;
            }

            bool containsAll = true;
            foreach (var item in pTerm)
            {
                if (!pInput.Contains(item))
                {
                    containsAll = false;
                    break;
                }
            }

            return containsAll;
        }

        return input.Contains(term);
    }

    internal static string RemoveLastLetters(string v1, int v2)
    {
        if (v1.Length > v2) return v1.Substring(0, v1.Length - v2);
        return v1;
    }

    internal static void IndentAsPreviousLine(List<string> lines)
    {
        var indentPrevious = string.Empty;
        string line = null;
        var sb = new StringBuilder();
        for (var i = 0; i < lines.Count - 1; i++)
        {
            line = lines[i];
            if (line.Length > 0)
            {
                if (!char.IsWhiteSpace(line[0]))
                {
                    lines[i] = indentPrevious + lines[i];
                }
                else
                {
                    sb.Clear();
                    foreach (var item in line)
                        if (char.IsWhiteSpace(item))
                            sb.Append(item);
                        else
                            break;
                    indentPrevious = sb.ToString();
                }
            }
        }
    }
}