// EN: Variable names have been checked and replaced with self-descriptive names
// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Text;

namespace FileSplitter;
partial class Program
{
    static bool SplitFile(string filePath, int maxLines, bool dryRun)
    {
        string code = File.ReadAllText(filePath);
        SyntaxTree tree = CSharpSyntaxTree.ParseText(code);
        var root = (CompilationUnitSyntax)tree.GetRoot();
        // Find class declaration
        var classDecl = root.DescendantNodes().OfType<ClassDeclarationSyntax>().FirstOrDefault();
        if (classDecl == null)
        {
            Console.WriteLine("  Skipping - not a class file");
            return false;
        }

        string className = classDecl.Identifier.Text;
        // Get all members
        var members = classDecl.Members.ToList();
        if (members.Count == 0)
        {
            Console.WriteLine("  Skipping - class has no members");
            return false;
        }

        // Calculate total lines
        int totalLines = code.Split('\n').Length;
        Console.WriteLine($"  Class has {members.Count} members");
        // Group members into chunks by line count
        var chunks = new List<List<MemberDeclarationSyntax>>();
        var currentChunk = new List<MemberDeclarationSyntax>();
        int currentChunkLines = 0;
        int reservedLines = 20; // for headers, namespace, class declaration
        foreach (var member in members)
        {
            // Remove #region/#endregion directives from member to avoid split issues
            var cleanedMember = RemoveRegionDirectives(member);
            int memberLines = cleanedMember.GetText().Lines.Count;
            if (currentChunkLines + memberLines > (maxLines - reservedLines) && currentChunk.Count > 0)
            {
                chunks.Add(currentChunk);
                currentChunk = new List<MemberDeclarationSyntax>();
                currentChunkLines = 0;
            }

            currentChunk.Add(cleanedMember);
            currentChunkLines += memberLines;
        }

        if (currentChunk.Count > 0)
        {
            chunks.Add(currentChunk);
        }

        if (chunks.Count <= 1)
        {
            Console.WriteLine("  No split needed - all members fit in one file");
            // Still make it partial if not already
            if (!classDecl.Modifiers.Any(m => m.IsKind(SyntaxKind.PartialKeyword)))
            {
                if (!dryRun)
                {
                    var newClassDecl = classDecl.AddModifiers(SyntaxFactory.Token(SyntaxKind.PartialKeyword));
                    var newRoot = root.ReplaceNode(classDecl, newClassDecl);
                    File.WriteAllText(filePath, newRoot.ToFullString());
                    Console.WriteLine("  Made class partial");
                }
            }

            return false;
        }

        Console.WriteLine($"  Splitting into {chunks.Count} files");
        // Get file info
        var directory = Path.GetDirectoryName(filePath)!;
        var baseName = Path.GetFileNameWithoutExtension(filePath);
        var extension = Path.GetExtension(filePath);
        // Get usings and namespace
        var usings = root.Usings;
        var namespaceDecl = root.DescendantNodes().OfType<BaseNamespaceDeclarationSyntax>().FirstOrDefault();
        // For file-scoped namespaces, check if there are usings after the namespace declaration
        SyntaxList<UsingDirectiveSyntax> namespaceUsings = default;
        if (namespaceDecl is FileScopedNamespaceDeclarationSyntax fileScopedNs)
        {
            namespaceUsings = fileScopedNs.Usings;
        }

        // Get other namespace-level members (enums, interfaces, etc.) that are not the class we're splitting
        List<MemberDeclarationSyntax> otherNamespaceMembers = new();
        if (namespaceDecl != null)
        {
            otherNamespaceMembers = namespaceDecl.Members.Where(m => m != classDecl).ToList();
        }
        else
        {
            // Top-level (no namespace)
            otherNamespaceMembers = root.Members.Where(m => m != classDecl).ToList();
        }

        for (int i = 0; i < chunks.Count; i++)
        {
            string newFilePath = i == 0 ? filePath : Path.Combine(directory, $"{baseName}{i}{extension}");
            // Build new compilation unit
            var newRoot = SyntaxFactory.CompilationUnit();
            // Add leading trivia (comments)
            var leadingTrivia = root.GetLeadingTrivia();
            if (leadingTrivia.Count == 0)
            {
                // Add standard header
                leadingTrivia = SyntaxFactory.TriviaList(SyntaxFactory.Comment("// EN: Variable names have been checked and replaced with self-descriptive names"), SyntaxFactory.CarriageReturnLineFeed, SyntaxFactory.Comment("// CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy"), SyntaxFactory.CarriageReturnLineFeed);
            }

            // Add usings
            newRoot = newRoot.WithUsings(usings);
            // Create partial class with chunk members
            var partialModifiers = classDecl.Modifiers.Any(m => m.IsKind(SyntaxKind.PartialKeyword)) ? classDecl.Modifiers : classDecl.Modifiers.Add(SyntaxFactory.Token(SyntaxKind.PartialKeyword));
            var newClassDecl = SyntaxFactory.ClassDeclaration(className).WithModifiers(partialModifiers).WithTypeParameterList(classDecl.TypeParameterList) // Preserve generic parameters
            .WithConstraintClauses(classDecl.ConstraintClauses) // Preserve generic constraints
            .WithBaseList(classDecl.BaseList) // Preserve interface implementations
            .WithMembers(SyntaxFactory.List(chunks[i])).WithLeadingTrivia(classDecl.GetLeadingTrivia()).WithTrailingTrivia(classDecl.GetTrailingTrivia());
            // Wrap in namespace if exists
            if (namespaceDecl != null)
            {
                // Add the class and, for the first file, all other namespace-level members (enums, etc.)
                var namespaceMembers = i == 0 ? new[]
                {
                    newClassDecl
                }.Concat(otherNamespaceMembers).ToList() : new List<MemberDeclarationSyntax>
                {
                    newClassDecl
                };
                if (namespaceDecl is FileScopedNamespaceDeclarationSyntax fileScoped)
                {
                    var newNamespace = SyntaxFactory.FileScopedNamespaceDeclaration(fileScoped.Name).WithUsings(namespaceUsings) // Add namespace-level usings
                    .WithMembers(SyntaxFactory.List(namespaceMembers));
                    newRoot = newRoot.WithMembers(SyntaxFactory.SingletonList<MemberDeclarationSyntax>(newNamespace));
                }
                else if (namespaceDecl is NamespaceDeclarationSyntax blockScoped)
                {
                    var newNamespace = SyntaxFactory.NamespaceDeclaration(blockScoped.Name).WithMembers(SyntaxFactory.List(namespaceMembers));
                    newRoot = newRoot.WithMembers(SyntaxFactory.SingletonList<MemberDeclarationSyntax>(newNamespace));
                }
            }
            else
            {
                // Top-level: Add the class and, for the first file, all other members
                var topLevelMembers = i == 0 ? new[]
                {
                    newClassDecl
                }.Concat(otherNamespaceMembers).ToList() : new List<MemberDeclarationSyntax>
                {
                    newClassDecl
                };
                newRoot = newRoot.WithMembers(SyntaxFactory.List(topLevelMembers));
            }

            // Add leading trivia
            newRoot = newRoot.WithLeadingTrivia(leadingTrivia);
            string newCode = newRoot.NormalizeWhitespace().ToFullString();
            int newLines = newCode.Split('\n').Length;
            if (dryRun)
            {
                if (i == 0)
                {
                    Console.WriteLine($"    Would update: {Path.GetFileName(newFilePath)} ({newLines} lines)");
                }
                else
                {
                    Console.WriteLine($"    Would create: {Path.GetFileName(newFilePath)} ({newLines} lines)");
                }
            }
            else
            {
                File.WriteAllText(newFilePath, newCode);
                if (i == 0)
                {
                    Console.WriteLine($"    Updated: {Path.GetFileName(newFilePath)} ({newLines} lines)");
                }
                else
                {
                    Console.WriteLine($"    Created: {Path.GetFileName(newFilePath)} ({newLines} lines)");
                }
            }
        }

        return true;
    }

    static MemberDeclarationSyntax RemoveRegionDirectives(MemberDeclarationSyntax member)
    {
        // Remove all #region and #endregion directives from leading and trailing trivia
        var leadingTrivia = member.GetLeadingTrivia().Where(t => !t.IsKind(SyntaxKind.RegionDirectiveTrivia) && !t.IsKind(SyntaxKind.EndRegionDirectiveTrivia)).ToList();
        var trailingTrivia = member.GetTrailingTrivia().Where(t => !t.IsKind(SyntaxKind.RegionDirectiveTrivia) && !t.IsKind(SyntaxKind.EndRegionDirectiveTrivia)).ToList();
        return member.WithLeadingTrivia(leadingTrivia).WithTrailingTrivia(trailingTrivia);
    }
}