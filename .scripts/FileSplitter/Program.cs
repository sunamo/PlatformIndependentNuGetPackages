// EN: Variable names have been checked and replaced with self-descriptive names
// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Text;

namespace FileSplitter;
partial class Program
{
    static void Main(string[] args)
    {
        int maxLinesPerFile = 500;
        int limitFiles = 5;
        bool dryRun = false;
        // Parse arguments
        for (int i = 0; i < args.Length; i++)
        {
            if (args[i] == "-MaxLines" && i + 1 < args.Length)
                maxLinesPerFile = int.Parse(args[i + 1]);
            else if (args[i] == "-Limit" && i + 1 < args.Length)
                limitFiles = int.Parse(args[i + 1]);
            else if (args[i] == "-DryRun")
                dryRun = true;
        }

        Console.WriteLine($"Splitting large C# files using Roslyn...");
        Console.WriteLine($"Max lines per file: {maxLinesPerFile}");
        Console.WriteLine($"Limit to first: {limitFiles} files");
        Console.WriteLine($"Dry run: {dryRun}");
        Console.WriteLine();
        // Find large files
        var files = Directory.GetFiles(".", "*.cs", SearchOption.AllDirectories).Where(f => !f.Contains("\\obj\\") && !f.Contains("\\bin\\") && !f.Contains("\\.git\\") && !f.Contains("\\node_modules\\") && !f.Contains("\\.scripts\\")).Select(f => new FileInfo(f)).Select(fi => new { Path = fi.FullName, Lines = File.ReadAllLines(fi.FullName).Length, Name = fi.Name }).Where(f => f.Lines > 300).OrderByDescending(f => f.Lines).Take(limitFiles).ToList();
        Console.WriteLine($"Found {files.Count} files to process\\n");
        int processedCount = 0;
        int skippedCount = 0;
        foreach (var file in files)
        {
            Console.WriteLine($"Processing: {file.Name} ({file.Lines} lines)");
            try
            {
                bool result = SplitFile(file.Path, maxLinesPerFile, dryRun);
                if (result)
                {
                    processedCount++;
                }
                else
                {
                    skippedCount++;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"  Error: {ex.Message}");
                skippedCount++;
            }

            Console.WriteLine();
        }

        Console.WriteLine(new string ('=', 80));
        Console.WriteLine("Summary:");
        Console.WriteLine($"  Processed: {processedCount} files");
        Console.WriteLine($"  Skipped: {skippedCount} files");
        Console.WriteLine();
        if (dryRun)
        {
            Console.WriteLine("DRY RUN - No files were modified");
        }
        else
        {
            Console.WriteLine("Files have been split successfully");
        }
    }
}