// EN: Remove false comment headers from files that still have short variables
// CZ: Odstraň falešné komentáře ze souborů které stále mají krátké proměnné
const fs = require('fs');
const path = require('path');

const rootDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';
const resultsPath = path.join(rootDir, 'verification-results.json');
const results = JSON.parse(fs.readFileSync(resultsPath, 'utf8'));

const commentPattern = /^\/\/ EN: Variable names have been checked and replaced with self-descriptive names\r?\n\/\/ CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy\r?\n/;

let removedCount = 0;

for (const relativePath of results.hasCommentButStillHasShortVars) {
    const fullPath = path.join(rootDir, relativePath);
    let content = fs.readFileSync(fullPath, 'utf8');

    if (commentPattern.test(content)) {
        content = content.replace(commentPattern, '');
        fs.writeFileSync(fullPath, content, 'utf8');
        removedCount++;
        console.log(`✓ Removed false comment from: ${relativePath}`);
    }
}

console.log(`\n${'='.repeat(80)}`);
console.log(`Total false comments removed: ${removedCount}`);
console.log(`These ${removedCount} files now need actual refactoring.`);
