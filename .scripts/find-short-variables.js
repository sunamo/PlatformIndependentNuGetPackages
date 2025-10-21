// EN: Script to find files with short variable names
// CZ: Skript pro nalezení souborů s krátkými názvy proměnných
const fs = require('fs');
const path = require('path');

const rootDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';

// Common short variable names to check (excluding loop counters i, j, k)
const shortVarPatterns = [
    /\b(sb|l|d|se|ca|dict|ls|t|v|n|m|p|r|c|a|b|x|y|z|s|e)\s+(=)/g,
    /\bvar\s+(sb|l|d|se|ca|dict|ls|t|v|n|m|p|r|c|a|b|x|y|z|s|e)\s*=/g,
    /\bList<.*?>\s+(sb|l|d|se|ca|dict|ls|t|v|n|m|p|r|c|a|b|x|y|z|s|e)\s*=/g,
    /\bstring\s+(sb|l|d|se|ca|dict|ls|t|v|n|m|p|r|c|a|b|x|y|z|s|e)\s*=/g,
    /\bint\s+(sb|l|d|se|ca|dict|ls|t|v|n|m|p|r|c|a|b|x|y|z|s|e)\s*=/g
];

function hasShortVariables(content) {
    for (const pattern of shortVarPatterns) {
        if (pattern.test(content)) {
            return true;
        }
    }
    return false;
}

function findFilesWithShortVars(dir, results = []) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);

        if (entry.isDirectory()) {
            if (entry.name !== 'obj' && entry.name !== 'bin' && entry.name !== 'node_modules') {
                findFilesWithShortVars(fullPath, results);
            }
        } else if (entry.name.endsWith('.cs') && !entry.name.endsWith('.g.cs')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            if (hasShortVariables(content)) {
                const relativePath = path.relative(rootDir, fullPath);
                results.push(relativePath);
            }
        }
    }

    return results;
}

console.log('Searching for files with short variable names...\n');
const filesWithShortVars = findFilesWithShortVars(rootDir);

console.log(`Found ${filesWithShortVars.length} files with potential short variable names:\n`);
filesWithShortVars.slice(0, 100).forEach(file => console.log(file));

if (filesWithShortVars.length > 100) {
    console.log(`\n... and ${filesWithShortVars.length - 100} more files`);
}

// Save to file
const outputPath = path.join(rootDir, 'files-with-short-variables.txt');
fs.writeFileSync(outputPath, filesWithShortVars.join('\n'));
console.log(`\n📄 Full list saved to: ${outputPath}`);
