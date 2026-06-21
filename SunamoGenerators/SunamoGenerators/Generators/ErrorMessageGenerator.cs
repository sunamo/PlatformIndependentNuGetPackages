namespace SunamoGenerators.Generators;

/// <summary>
/// Generates user-facing error messages from a list of files and their associated exceptions, splitting output into visible and collapsed sections.
/// </summary>
public class ErrorMessageGenerator
{
    private StringBuilder visibleBuilder = new StringBuilder();
    private StringBuilder collapseBuilder = new StringBuilder();

    /// <summary>
    /// Gets the visible portion of the error message.
    /// </summary>
    public string Visible
    {
        get
        {
            return visibleBuilder.ToString();
        }
    }

    /// <summary>
    /// Gets the collapsed portion of the error message.
    /// </summary>
    public string Collapse
    {
        get
        {
            return collapseBuilder.ToString();
        }
    }

    /// <summary>
    /// Generates error messages from a list of erroneous files and their exceptions.
    /// </summary>
    /// <param name="errorFiles">List of file names that had errors.</param>
    /// <param name="exceptions">List of file exceptions corresponding to each file.</param>
    /// <param name="maxVisible">Maximum number of errors to show in the visible section.</param>
    public ErrorMessageGenerator(List<string> errorFiles, List<FileExceptions> exceptions, int maxVisible)
    {
        if (CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "cs")
        {
            visibleBuilder.AppendLine("  t\u011Bchto souborech se vyskytly tyto chyby: ");
        }
        else
        {
            visibleBuilder.AppendLine(Translate.FromKey(XlfKeys.InTheseFilesTheFollowingErrorsOccurred) + ": ");
        }
        if (errorFiles.Count < maxVisible)
        {
            maxVisible = errorFiles.Count;
        }
        int currentIndex = 0;
        for (; currentIndex < maxVisible; currentIndex++)
        {
            string errorMessage = GetErrorMessage(exceptions[currentIndex]);
            visibleBuilder.AppendLine(errorFiles[currentIndex] + "-" + errorMessage);
        }
        string? errorAdvice = null;
        if (CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "cs")
        {
            errorAdvice = "Pokud si mysl\u00EDte \u017Ee to je chyba aplikace, po\u0161lete pros\u00EDm mi email na adresu kter\u00E1 je uvedena v dialogu O aplikaci";
        }
        else
        {
            errorAdvice = Translate.FromKey(XlfKeys.IfYouThinkThatThisIsApplicationErrorPleaseSendMeAnEmailAtTheAddressThatIsListedInTheAboutApp);
        }
        if (currentIndex == errorFiles.Count)
        {
            collapseBuilder.AppendLine(errorAdvice);
        }
        else
        {
            for (; currentIndex < errorFiles.Count; currentIndex++)
            {
                string errorMessage = GetErrorMessage(exceptions[currentIndex]);
                collapseBuilder.AppendLine(errorFiles[maxVisible] + "-" + errorMessage);
            }
            collapseBuilder.AppendLine(errorAdvice);
        }
    }

    private string GetErrorMessage(FileExceptions fileExceptions)
    {
        if (CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "cs")
        {
            switch (fileExceptions)
            {
                case FileExceptions.None:
                    break;
                case FileExceptions.FileNotFound:
                    return Translate.FromKey(XlfKeys.FileNotFound);
                case FileExceptions.UnauthorizedAccess:
                    return "Program z\u0159ejm\u011B nem\u00E1 p\u0159\u00EDstup k souboru";
                case FileExceptions.General:
                    return "Nezn\u00E1m\u00E1 nebo obecn\u00E1 chyba";
                default:
                    throw new Exception("Neimplementovan\u00E1 v\u011Btev");
            }
        }
        else
        {
            switch (fileExceptions)
            {
                case FileExceptions.None:
                    break;
                case FileExceptions.FileNotFound:
                    return Translate.FromKey(XlfKeys.FileNotFound);
                case FileExceptions.UnauthorizedAccess:
                    return Translate.FromKey(XlfKeys.TheProgramDoesNotHaveAccessToTheFile);
                case FileExceptions.General:
                    return Translate.FromKey(XlfKeys.UnknownOrGeneralError);
                default:
                    throw new Exception(Translate.FromKey(XlfKeys.NotImplementedCase));
            }
        }
        return "";
    }
}
