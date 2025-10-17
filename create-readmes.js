// Creates comprehensive README.md files for all Sunamo packages
// Based on analysis and actual source code reading

const fs = require('fs');
const path = require('path');

const rootPath = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';
const analysisPath = path.join(rootPath, 'package-analysis.json');
const analysis = JSON.parse(fs.readFileSync(analysisPath, 'utf8'));

const readmeTemplates = {
    // Generate README content based on package data
    generate: function(pkg) {
        const hasClasses = pkg.classes && pkg.classes.length > 0;
        const hasMethods = pkg.methods && pkg.methods.length > 0;
        const hasDeps = pkg.dependencies && pkg.dependencies.length > 0;

        let readme = `# ${pkg.name}\n\n`;

        // Add description if available
        if (pkg.description) {
            readme += `${pkg.description}\n\n`;
        } else {
            readme += `Utilities and helpers for ${this.inferPurpose(pkg.name)}.\n\n`;
        }

        // Overview section
        readme += `## Overview\n\n`;
        readme += `${pkg.name} is part of the Sunamo package ecosystem, providing modular, platform-independent utilities for .NET development.\n\n`;

        // Features/Components section
        if (hasClasses || hasMethods) {
            readme += `## Main Components\n\n`;

            if (hasClasses && pkg.classes.length > 0) {
                readme += `### Key Classes\n\n`;
                pkg.classes.forEach(className => {
                    readme += `- **${className}**\n`;
                });
                readme += `\n`;
            }

            if (hasMethods && pkg.methods.length > 0) {
                readme += `### Key Methods\n\n`;
                const uniqueMethods = [...new Set(pkg.methods)];
                uniqueMethods.slice(0, 10).forEach(methodName => {
                    readme += `- \`${methodName}()\`\n`;
                });
                readme += `\n`;
            }
        }

        // Installation
        readme += `## Installation\n\n`;
        readme += `\`\`\`bash\n`;
        readme += `dotnet add package ${pkg.name}\n`;
        readme += `\`\`\`\n\n`;

        // Dependencies
        if (hasDeps) {
            readme += `## Dependencies\n\n`;
            pkg.dependencies.forEach(dep => {
                if (dep.version === '*') {
                    readme += `- **${dep.name}** (latest)\n`;
                } else {
                    readme += `- **${dep.name}** (v${dep.version})\n`;
                }
            });
            readme += `\n`;
        }

        // Package Information
        readme += `## Package Information\n\n`;
        readme += `- **Package Name**: ${pkg.name}\n`;
        if (pkg.version) {
            readme += `- **Version**: ${pkg.version}\n`;
        }
        readme += `- **Target Framework**: ${pkg.targetFramework}\n`;
        readme += `- **Category**: Platform-Independent NuGet Package\n`;
        if (pkg.fileCount) {
            readme += `- **Source Files**: ${pkg.fileCount}\n`;
        }
        readme += `\n`;

        // Related Packages
        readme += `## Related Packages\n\n`;
        readme += `This package is part of the Sunamo package ecosystem. For more information about related packages, visit the main repository.\n\n`;

        // License
        readme += `## License\n\n`;
        readme += `See the repository root for license information.\n`;

        return readme;
    },

    inferPurpose: function(packageName) {
        const name = packageName.replace('Sunamo', '').toLowerCase();

        const purposes = {
            'ai': 'artificial intelligence operations',
            'args': 'method arguments and parameter handling',
            'async': 'asynchronous operations',
            'attributes': 'custom attributes',
            'azuredevopsapi': 'Azure DevOps API integration',
            'bazoscrawler': 'Bazoš.cz web crawling',
            'bts': 'bug tracking systems',
            'char': 'character operations',
            'cl': 'command-line interface',
            'clearscript': 'ClearScript JavaScript engine integration',
            'clipboard': 'clipboard operations',
            'collection': 'collection utilities',
            'colors': 'color manipulation',
            'compare': 'comparison operations',
            'converters': 'type conversion',
            'crypt': 'cryptography and encryption',
            'csproj': 'C# project file manipulation',
            'cssgenerator': 'CSS generation',
            'csv': 'CSV file operations',
            'data': 'data processing',
            'datetime': 'date and time operations',
            'debug': 'debugging',
            'delegates': 'delegate types',
            'dependencyinjection': 'dependency injection',
            'devcode': 'development code utilities',
            'dictionary': 'dictionary operations',
            'dotnetcmdbuilder': '.NET command builder',
            'dotnetzip': 'ZIP archive operations',
            'editorconfig': 'EditorConfig file handling',
            'embeddedresources': 'embedded resource management',
            'emoticons': 'emoticon handling',
            'enums': 'enumeration types',
            'exceptions': 'exception handling',
            'extensions': 'extension methods',
            'fileextensions': 'file extension utilities',
            'fileio': 'file I/O operations',
            'filesystem': 'file system operations',
            'filesindex': 'file indexing',
            'fluentftp': 'FluentFTP integration',
            'ftp': 'FTP operations',
            'getfiles': 'file retrieval',
            'getfolders': 'folder retrieval',
            'gitconfig': 'Git configuration',
            'googlemymaps': 'Google My Maps integration',
            'googlesheets': 'Google Sheets integration',
            'gpx': 'GPX file handling',
            'html': 'HTML manipulation',
            'http': 'HTTP operations',
            'ini': 'INI file operations',
            'interfaces': 'interface definitions',
            'json': 'JSON operations',
            'latex': 'LaTeX document processing',
            'lang': 'language and localization',
            'logging': 'logging operations',
            'mail': 'email operations',
            'markdown': 'Markdown processing',
            'mathpix': 'Mathpix API integration',
            'mime': 'MIME type handling',
            'mssqlserver': 'MS SQL Server operations',
            'msgreader': 'MSG file reading',
            'nugetprotocol': 'NuGet protocol operations',
            'numbers': 'number operations',
            'octokit': 'Octokit GitHub API integration',
            'packagejson': 'package.json file handling',
            'parsing': 'parsing operations',
            'paths': 'path operations',
            'percentcalculator': 'percentage calculations',
            'pinvoke': 'P/Invoke operations',
            'platformuwpinterop': 'UWP platform interop',
            'ps': 'PowerShell operations',
            'random': 'random value generation',
            'reflection': 'reflection operations',
            'regex': 'regular expressions',
            'result': 'result types',
            'robotstxt': 'robots.txt file handling',
            'roslyn': 'Roslyn code analysis',
            'rss': 'RSS feed operations',
            'ruleset': 'ruleset file handling',
            'security': 'security operations',
            'selenium': 'Selenium web automation',
            'serializer': 'serialization',
            'shared': 'shared utilities',
            'stopwatch': 'timing and stopwatch operations',
            'string': 'string operations',
            'test': 'testing utilities',
            'text': 'text processing',
            'textindexing': 'text indexing',
            'textoutputgenerator': 'text output generation',
            'thisapp': 'application information',
            'thread': 'threading operations',
            'threading': 'threading utilities',
            'tidy': 'HTML Tidy integration',
            'tounixlineending': 'Unix line ending conversion',
            'twowaydictionary': 'bidirectional dictionary',
            'types': 'type definitions',
            'underscore': 'underscore utilities',
            'uri': 'URI operations',
            'uriwebservices': 'URI web service utilities',
            'values': 'value types and constants',
            'vcf': 'vCard file handling',
            'wikipedia': 'Wikipedia API integration',
            'winstd': 'Windows standard operations',
            'xlfkeys': 'XLF key handling',
            'xliffparser': 'XLIFF file parsing',
            'xml': 'XML operations',
            'yaml': 'YAML operations',
            'youtube': 'YouTube API integration'
        };

        return purposes[name] || 'various utility operations';
    }
};

// Process all packages
console.log(`Generating READMEs for ${analysis.processed.length} packages...\n`);

let created = 0;
let updated = 0;
let errors = 0;

analysis.processed.forEach((pkg, index) => {
    try {
        const readmePath = path.join(rootPath, pkg.name, 'README.md');
        const readmeContent = readmeTemplates.generate(pkg);

        const existed = fs.existsSync(readmePath);

        fs.writeFileSync(readmePath, readmeContent, 'utf8');

        if (existed) {
            updated++;
            console.log(`[${index + 1}/${analysis.processed.length}] ✓ Updated: ${pkg.name}`);
        } else {
            created++;
            console.log(`[${index + 1}/${analysis.processed.length}] ✓ Created: ${pkg.name}`);
        }
    } catch (error) {
        errors++;
        console.log(`[${index + 1}/${analysis.processed.length}] ✗ Error: ${pkg.name} - ${error.message}`);
    }
});

console.log('\n========================================');
console.log('README GENERATION COMPLETE');
console.log('========================================');
console.log(`Total processed: ${analysis.processed.length}`);
console.log(`Created: ${created}`);
console.log(`Updated: ${updated}`);
console.log(`Errors: ${errors}`);
