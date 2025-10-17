// Automated README generator for all Sunamo packages
// Reads actual source code and generates meaningful documentation

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const rootPath = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';
const processedPackages = [];
const errorPackages = [];

// Get all Sunamo directories
const packages = fs.readdirSync(rootPath)
    .filter(name => name.startsWith('Sunamo') && fs.statSync(path.join(rootPath, name)).isDirectory())
    .sort();

console.log(`Found ${packages.length} Sunamo packages to process\n`);

let currentIndex = 0;

for (const packageName of packages) {
    currentIndex++;
    console.log(`[${currentIndex}/${packages.length}] Processing: ${packageName}`);

    const packagePath = path.join(rootPath, packageName);

    try {
        // Find the inner package directory (e.g., SunamoAI/SunamoAI/)
        const innerPackagePath = path.join(packagePath, packageName);

        // Check if inner package directory exists
        if (!fs.existsSync(innerPackagePath)) {
            console.log(`  [SKIP] No inner package directory found at ${innerPackagePath}`);
            errorPackages.push({ package: packageName, reason: 'No inner package directory' });
            continue;
        }

        // Find .csproj file
        const csprojFiles = fs.readdirSync(innerPackagePath).filter(f => f.endsWith('.csproj'));
        if (csprojFiles.length === 0) {
            console.log(`  [SKIP] No .csproj file found`);
            errorPackages.push({ package: packageName, reason: 'No .csproj file' });
            continue;
        }

        const csprojPath = path.join(innerPackagePath, csprojFiles[0]);

        // Read .csproj to extract metadata
        const csprojContent = fs.readFileSync(csprojPath, 'utf8');

        // Parse basic info from csproj
        const descriptionMatch = csprojContent.match(/<Description>(.*?)<\/Description>/s);
        const versionMatch = csprojContent.match(/<Version>(.*?)<\/Version>/);
        const targetFrameworkMatch = csprojContent.match(/<TargetFramework>(.*?)<\/TargetFramework>/);

        const description = descriptionMatch ? descriptionMatch[1].trim() : '';
        const version = versionMatch ? versionMatch[1].trim() : '';
        const targetFramework = targetFrameworkMatch ? targetFrameworkMatch[1].trim() : 'net9.0';

        // Extract package references
        const packageReferences = [];
        const packageRefRegex = /<PackageReference Include="(.*?)" Version="(.*?)"/g;
        let match;
        while ((match = packageRefRegex.exec(csprojContent)) !== null) {
            packageReferences.push({ name: match[1], version: match[2] });
        }

        // Find C# source files (excluding obj, bin, AssemblyInfo)
        const csFiles = [];
        function findCsFiles(dir, depth = 0) {
            if (depth > 5) return; // Limit recursion depth

            try {
                const entries = fs.readdirSync(dir, { withFileTypes: true });
                for (const entry of entries) {
                    const fullPath = path.join(dir, entry.name);
                    if (entry.isDirectory()) {
                        if (!['obj', 'bin', '.vs', 'Properties'].includes(entry.name)) {
                            findCsFiles(fullPath, depth + 1);
                        }
                    } else if (entry.name.endsWith('.cs') &&
                               !entry.name.includes('AssemblyInfo') &&
                               !entry.name.includes('GlobalUsings')) {
                        csFiles.push(fullPath);
                    }
                }
            } catch (e) {
                // Skip directories we can't read
            }
        }

        findCsFiles(innerPackagePath);

        if (csFiles.length === 0) {
            console.log(`  [SKIP] No .cs source files found`);
            errorPackages.push({ package: packageName, reason: 'No .cs files' });
            continue;
        }

        console.log(`  Found ${csFiles.length} source files`);
        console.log(`  Target: ${targetFramework}`);
        console.log(`  Dependencies: ${packageReferences.length}`);

        // Analyze the source files to extract classes and methods
        const classes = [];
        const publicMethods = [];

        for (const csFile of csFiles.slice(0, 10)) { // Limit to first 10 files
            try {
                const content = fs.readFileSync(csFile, 'utf8');

                // Extract public class names
                const classMatches = content.matchAll(/public\s+(?:static\s+)?(?:sealed\s+)?class\s+(\w+)/g);
                for (const match of classMatches) {
                    if (!classes.includes(match[1])) {
                        classes.push(match[1]);
                    }
                }

                // Extract public method signatures (simplified)
                const methodMatches = content.matchAll(/public\s+(?:static\s+)?(?:async\s+)?(?:\w+(?:<.*?>)?)\s+(\w+)\s*\(/g);
                let methodCount = 0;
                for (const match of methodMatches) {
                    if (methodCount < 5 && !publicMethods.includes(match[1])) {
                        publicMethods.push(match[1]);
                        methodCount++;
                    }
                }
            } catch (e) {
                // Skip files we can't read
            }
        }

        // Store package info
        processedPackages.push({
            name: packageName,
            description,
            version,
            targetFramework,
            dependencies: packageReferences,
            classes: classes.slice(0, 10),
            methods: publicMethods.slice(0, 10),
            fileCount: csFiles.length
        });

        console.log(`  Classes: ${classes.length}, Methods: ${publicMethods.length}`);
        console.log(`  ✓ Package analyzed successfully\n`);

    } catch (error) {
        console.log(`  [ERROR] ${error.message}`);
        errorPackages.push({ package: packageName, reason: error.message });
    }
}

// Save the analysis results
const outputPath = path.join(rootPath, 'package-analysis.json');
fs.writeFileSync(outputPath, JSON.stringify({
    processed: processedPackages,
    errors: errorPackages,
    totalCount: packages.length,
    processedCount: processedPackages.length,
    errorCount: errorPackages.length
}, null, 2));

console.log('\n========================================');
console.log('ANALYSIS COMPLETE');
console.log('========================================');
console.log(`Total packages: ${packages.length}`);
console.log(`Successfully analyzed: ${processedPackages.length}`);
console.log(`Errors: ${errorPackages.length}`);
console.log(`\nAnalysis saved to: ${outputPath}`);

if (errorPackages.length > 0) {
    console.log('\nPackages with errors:');
    errorPackages.forEach(({ package: pkg, reason }) => {
        console.log(`  - ${pkg}: ${reason}`);
    });
}
