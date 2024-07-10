namespace SunamoXliffParser;

public interface IXlfExporter
    {
        void ExportTranslationUnits(string filePath, IEnumerable<XlfTransUnit> units, string targetLanguage,
            XlfDialect dialect);
    }
