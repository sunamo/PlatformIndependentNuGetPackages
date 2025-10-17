const fs = require('fs');
const path = require('path');

// Get all Sunamo directories
const rootDir = process.cwd();
const dirs = fs.readdirSync(rootDir)
    .filter(name => name.startsWith('Sunamo') && fs.statSync(path.join(rootDir, name)).isDirectory())
    .sort();

console.log(`Found ${dirs.length} Sunamo packages to process`);

// Function to analyze a package and determine its purpose
function analyzePackage(packageName, packagePath) {
    const analysis = {
        name: packageName,
        purpose: '',
        description: '',
        features: []
    };

    // Read .csproj file if exists
    const csprojFiles = fs.readdirSync(packagePath).filter(f => f.endsWith('.csproj'));
    if (csprojFiles.length > 0) {
        const csprojPath = path.join(packagePath, csprojFiles[0]);
        const csprojContent = fs.readFileSync(csprojPath, 'utf8');

        // Extract description from csproj if present
        const descMatch = csprojContent.match(/<Description>(.*?)<\/Description>/s);
        if (descMatch) {
            analysis.description = descMatch[1].trim();
        }
    }

    // Analyze based on package name patterns
    const namePart = packageName.replace('Sunamo', '');

    // Define package purposes based on naming patterns
    const packageDefinitions = {
        'AI': { purpose: 'Artificial Intelligence utilities', description: 'Provides utilities and helpers for AI-related operations and integrations.' },
        'Args': { purpose: 'Command-line argument parsing', description: 'Utilities for parsing and handling command-line arguments in .NET applications.' },
        'Async': { purpose: 'Asynchronous programming utilities', description: 'Helpers and extensions for asynchronous programming patterns in .NET.' },
        'Attributes': { purpose: 'Custom attributes and reflection', description: 'Custom .NET attributes and utilities for working with reflection and metadata.' },
        'AzureDevOpsApi': { purpose: 'Azure DevOps API integration', description: 'Client library for interacting with Azure DevOps REST API.' },
        'BazosCrawler': { purpose: 'Bazos.cz web scraping', description: 'Web scraper for extracting data from Bazos.cz marketplace.' },
        'Bts': { purpose: 'Bug tracking system utilities', description: 'Utilities for working with bug tracking and issue management systems.' },
        'Char': { purpose: 'Character manipulation utilities', description: 'Helper methods for character operations and manipulations.' },
        'Cl': { purpose: 'Command-line interface utilities', description: 'Utilities for building command-line applications and interfaces.' },
        'ClearScript': { purpose: 'ClearScript integration', description: 'Utilities and wrappers for Microsoft ClearScript JavaScript engine.' },
        'Clipboard': { purpose: 'Clipboard operations', description: 'Cross-platform clipboard access and manipulation utilities.' },
        'CollectionOnDrive': { purpose: 'Drive-based collections', description: 'Collection utilities that work with file system and drive storage.' },
        'Collections': { purpose: 'Collection utilities', description: 'General-purpose collection manipulation and extension methods.' },
        'CollectionsChangeContent': { purpose: 'Collection content modification', description: 'Utilities for modifying and transforming collection contents.' },
        'CollectionsGeneric': { purpose: 'Generic collection helpers', description: 'Generic collection utilities and extension methods.' },
        'CollectionsIndexesWithNull': { purpose: 'Nullable index collections', description: 'Collection utilities that handle nullable indexes and optional elements.' },
        'CollectionsNonGeneric': { purpose: 'Non-generic collection utilities', description: 'Utilities for working with non-generic collection types.' },
        'CollectionsTo': { purpose: 'Collection conversion utilities', description: 'Methods for converting between different collection types.' },
        'CollectionsValuesTableGrid': { purpose: 'Table and grid collections', description: 'Utilities for working with tabular data and grid-based collections.' },
        'CollectionWithoutDuplicates': { purpose: 'Duplicate-free collections', description: 'Collection implementations that automatically prevent duplicates.' },
        'Colors': { purpose: 'Color manipulation', description: 'Utilities for working with colors, color conversion, and color operations.' },
        'Compare': { purpose: 'Comparison utilities', description: 'Comparison helpers and custom comparers for various types.' },
        'Converters': { purpose: 'Type conversion utilities', description: 'Type converters and conversion helpers for .NET types.' },
        'Crypt': { purpose: 'Cryptography utilities', description: 'Cryptographic operations, hashing, and encryption utilities.' },
        'Csproj': { purpose: 'C# project file utilities', description: 'Utilities for reading, parsing, and manipulating .csproj files.' },
        'CssGenerator': { purpose: 'CSS generation', description: 'Programmatic CSS generation and manipulation utilities.' },
        'Csv': { purpose: 'CSV file handling', description: 'CSV file reading, writing, and parsing utilities.' },
        'Data': { purpose: 'Data access utilities', description: 'General-purpose data access and manipulation utilities.' },
        'DateTime': { purpose: 'Date and time utilities', description: 'Extension methods and helpers for DateTime operations.' },
        'DebugCollection': { purpose: 'Debugging collection utilities', description: 'Collection utilities specifically designed for debugging scenarios.' },
        'Debugging': { purpose: 'Debugging utilities', description: 'General debugging helpers and diagnostic utilities.' },
        'Delegates': { purpose: 'Delegate utilities', description: 'Utilities for working with delegates and event handlers.' },
        'DevCode': { purpose: 'Development code utilities', description: 'Code generation and development-time utilities.' },
        'Dictionary': { purpose: 'Dictionary utilities', description: 'Extension methods and helpers for dictionary operations.' },
        'DotnetCmdBuilder': { purpose: '.NET command builder', description: 'Fluent API for building .NET CLI commands programmatically.' },
        'EditorConfig': { purpose: 'EditorConfig handling', description: 'Utilities for working with .editorconfig files.' },
        'EmbeddedResources': { purpose: 'Embedded resource utilities', description: 'Helpers for working with embedded resources in assemblies.' },
        'Enums': { purpose: 'Enumeration utilities', description: 'Utilities for working with enumerations and enum values.' },
        'EnumsHelper': { purpose: 'Enum helper methods', description: 'Additional helper methods and extensions for enumerations.' },
        'Exceptions': { purpose: 'Exception handling utilities', description: 'Custom exceptions and exception handling helpers.' },
        'FileExtensions': { purpose: 'File extension utilities', description: 'Utilities for working with file extensions and file types.' },
        'FileIO': { purpose: 'File I/O operations', description: 'File input/output operations and file system utilities.' },
        'FluentFtp': { purpose: 'FluentFTP integration', description: 'Wrapper and utilities for FluentFTP library.' },
        'Ftp': { purpose: 'FTP operations', description: 'FTP client utilities and file transfer operations.' },
        'GetFiles': { purpose: 'File retrieval utilities', description: 'Utilities for searching and retrieving files from file system.' },
        'GetFolders': { purpose: 'Folder retrieval utilities', description: 'Utilities for searching and retrieving folders from file system.' },
        'GitConfig': { purpose: 'Git configuration utilities', description: 'Utilities for reading and manipulating Git configuration files.' },
        'GoogleMyMaps': { purpose: 'Google My Maps integration', description: 'API client for working with Google My Maps.' },
        'GoogleSheets': { purpose: 'Google Sheets integration', description: 'API client for reading and writing Google Sheets.' },
        'Html': { purpose: 'HTML manipulation', description: 'HTML parsing, generation, and manipulation utilities.' },
        'Http': { purpose: 'HTTP client utilities', description: 'HTTP client helpers and web request utilities.' },
        'Ini': { purpose: 'INI file handling', description: 'INI file reading, writing, and parsing utilities.' },
        'Interfaces': { purpose: 'Common interfaces', description: 'Shared interfaces used across Sunamo packages.' },
        'Json': { purpose: 'JSON utilities', description: 'JSON serialization, deserialization, and manipulation utilities.' },
        'LaTeX': { purpose: 'LaTeX utilities', description: 'LaTeX document generation and manipulation utilities.' },
        'Lang': { purpose: 'Language utilities', description: 'Multi-language and localization utilities.' },
        'Logging': { purpose: 'Logging utilities', description: 'Logging helpers and abstractions for various logging frameworks.' },
        'Mail': { purpose: 'Email utilities', description: 'Email sending, receiving, and manipulation utilities.' },
        'Markdown': { purpose: 'Markdown utilities', description: 'Markdown parsing, generation, and conversion utilities.' },
        'Mathpix': { purpose: 'Mathpix integration', description: 'Integration with Mathpix OCR API for mathematical formulas.' },
        'Mime': { purpose: 'MIME type utilities', description: 'MIME type detection and handling utilities.' },
        'MsgReader': { purpose: 'MSG file reader', description: 'Utilities for reading Outlook MSG email files.' },
        'NuGetProtocol': { purpose: 'NuGet protocol utilities', description: 'Utilities for working with NuGet package protocol.' },
        'Numbers': { purpose: 'Number utilities', description: 'Numeric operations and number formatting utilities.' },
        'PInvoke': { purpose: 'P/Invoke utilities', description: 'Platform Invoke helpers for calling native APIs.' },
        'PS': { purpose: 'PowerShell utilities', description: 'PowerShell script execution and integration utilities.' },
        'PackageJson': { purpose: 'package.json utilities', description: 'Utilities for reading and manipulating Node.js package.json files.' },
        'Parsing': { purpose: 'Parsing utilities', description: 'General-purpose parsing utilities for various formats.' },
        'PercentCalculator': { purpose: 'Percentage calculations', description: 'Utilities for percentage calculations and conversions.' },
        'PlatformUwpInterop': { purpose: 'UWP interoperability', description: 'Interoperability utilities for Universal Windows Platform.' },
        'Random': { purpose: 'Random generation utilities', description: 'Random number and data generation utilities.' },
        'Reflection': { purpose: 'Reflection utilities', description: 'Reflection helpers and metadata inspection utilities.' },
        'Regex': { purpose: 'Regular expression utilities', description: 'Regular expression helpers and common regex patterns.' },
        'RobotsTxt': { purpose: 'robots.txt handling', description: 'Utilities for parsing and working with robots.txt files.' },
        'Roslyn': { purpose: 'Roslyn compiler utilities', description: 'Utilities for working with Roslyn compiler API.' },
        'Rss': { purpose: 'RSS feed utilities', description: 'RSS feed parsing, generation, and manipulation utilities.' },
        'Ruleset': { purpose: 'Ruleset utilities', description: 'Utilities for working with Visual Studio ruleset files.' },
        'Selenium': { purpose: 'Selenium WebDriver utilities', description: 'Wrapper and helper utilities for Selenium WebDriver.' },
        'Serializer': { purpose: 'Serialization utilities', description: 'General-purpose serialization and deserialization utilities.' },
        'Shared': { purpose: 'Shared utilities', description: 'Common shared utilities used across multiple Sunamo packages.' },
        'Stopwatch': { purpose: 'Stopwatch utilities', description: 'Performance measurement and timing utilities.' },
        'String': { purpose: 'String manipulation', description: 'Core string manipulation and extension methods.' },
        'StringFormat': { purpose: 'String formatting', description: 'String formatting utilities and helpers.' },
        'StringGetString': { purpose: 'String extraction', description: 'Utilities for extracting substrings and string parts.' },
        'StringJoin': { purpose: 'String joining', description: 'Utilities for joining strings and collections into strings.' },
        'StringJoinPairs': { purpose: 'String pair joining', description: 'Utilities for joining key-value pairs into strings.' },
        'StringParts': { purpose: 'String parts utilities', description: 'Utilities for working with parts of strings.' },
        'StringReplace': { purpose: 'String replacement', description: 'Advanced string replacement utilities and patterns.' },
        'StringSplit': { purpose: 'String splitting', description: 'Enhanced string splitting utilities.' },
        'StringSubstring': { purpose: 'Substring utilities', description: 'Advanced substring extraction utilities.' },
        'StringTrim': { purpose: 'String trimming', description: 'String trimming and whitespace removal utilities.' },
        'Text': { purpose: 'Text processing', description: 'General text processing and manipulation utilities.' },
        'TextOutputGenerator': { purpose: 'Text output generation', description: 'Utilities for generating formatted text output.' },
        'ThisApp': { purpose: 'Application utilities', description: 'Utilities for getting information about the current application.' },
        'Thread': { purpose: 'Threading utilities', description: 'Multi-threading and synchronization utilities.' },
        'Tidy': { purpose: 'HTML Tidy utilities', description: 'Utilities for cleaning and tidying HTML content.' },
        'ToUnixLineEnding': { purpose: 'Line ending conversion', description: 'Utilities for converting line endings to Unix format.' },
        'TwoWayDictionary': { purpose: 'Bidirectional dictionary', description: 'Dictionary implementation that allows lookup in both directions.' },
        'Underscore': { purpose: 'Underscore utilities', description: 'Utilities inspired by Underscore.js library.' },
        'Uri': { purpose: 'URI utilities', description: 'URI parsing, manipulation, and validation utilities.' },
        'UriWebServices': { purpose: 'Web service URI utilities', description: 'URI utilities specifically for web services.' },
        'Values': { purpose: 'Value utilities', description: 'Utilities for working with various value types.' },
        'Vcf': { purpose: 'VCF file handling', description: 'vCard (VCF) file parsing and generation utilities.' },
        'Wikipedia': { purpose: 'Wikipedia API integration', description: 'Client library for accessing Wikipedia API.' },
        'WinStd': { purpose: 'Windows standard utilities', description: 'Standard Windows platform-specific utilities.' },
        'XlfKeys': { purpose: 'XLF key utilities', description: 'Utilities for working with XLIFF localization keys.' },
        'XliffParser': { purpose: 'XLIFF parser', description: 'Parser for XLIFF (XML Localization Interchange File Format) files.' },
        'Xml': { purpose: 'XML utilities', description: 'XML parsing, generation, and manipulation utilities.' },
        'Yaml': { purpose: 'YAML utilities', description: 'YAML parsing and generation utilities.' },
        'YouTube': { purpose: 'YouTube API integration', description: 'Client library for working with YouTube Data API.' }
    };

    // Apply predefined definition if available
    if (packageDefinitions[namePart]) {
        analysis.purpose = packageDefinitions[namePart].purpose;
        if (!analysis.description) {
            analysis.description = packageDefinitions[namePart].description;
        }
    }

    return analysis;
}

// Function to generate README content
function generateReadme(analysis) {
    return `# ${analysis.name}

${analysis.description || 'Utility library for .NET applications.'}

## Purpose

${analysis.purpose || 'Provides utility methods and extensions for common .NET development tasks.'}

## Installation

\`\`\`bash
dotnet add package ${analysis.name}
\`\`\`

## Package Information

- **Package Name**: ${analysis.name}
- **Category**: Platform-Independent NuGet Package
- **Target Framework**: .NET Standard / .NET

## Related Packages

This package is part of the Sunamo package ecosystem, designed to provide modular, platform-independent utilities for .NET development.

## License

See the repository root for license information.
`;
}

// Process all packages
let processedCount = 0;
let skippedCount = 0;

for (const dir of dirs) {
    const packagePath = path.join(rootDir, dir);
    const readmePath = path.join(packagePath, 'README.md');

    console.log(`\nProcessing ${dir}...`);

    // Check if README already exists
    if (fs.existsSync(readmePath)) {
        console.log(`  ⚠ README.md already exists, skipping`);
        skippedCount++;
        continue;
    }

    // Analyze package
    const analysis = analyzePackage(dir, packagePath);

    // Generate README
    const readmeContent = generateReadme(analysis);

    // Write README
    fs.writeFileSync(readmePath, readmeContent, 'utf8');
    console.log(`  ✓ Created README.md for ${dir}`);
    processedCount++;
}

console.log(`\n${'='.repeat(60)}`);
console.log(`Summary:`);
console.log(`  Total packages: ${dirs.length}`);
console.log(`  READMEs created: ${processedCount}`);
console.log(`  Skipped (already exists): ${skippedCount}`);
console.log(`${'='.repeat(60)}`);
