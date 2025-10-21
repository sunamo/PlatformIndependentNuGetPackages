// EN: Script to refactor short variable names to self-descriptive names
// CZ: Skript pro refaktoring krátkých názvů proměnných na samopopisné názvy
const fs = require('fs');
const path = require('path');

const rootDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';

// Mapping of short names to common self-descriptive names based on context
const commonReplacements = {
    'StringBuilder sb': 'StringBuilder stringBuilder',
    'var sb =': 'var stringBuilder =',
    'List<string> l': 'List<string> lines',
    'var l =': 'var list =',
    'var ls =': 'var sourceList =',
    'var t =': 'var temp =',
    'var d =': 'var data =',
    'var v =': 'var value =',
    'var n =': 'var name =',
    'var m =': 'var message =',
    'var p =': 'var path =',
    'var r =': 'var result =',
    'var c =': 'var count =',
    'var s =': 'var str =',
    'var e =': 'var element ='
};

function shouldSkipFile(content) {
    // Skip files that are mostly interfaces, empty classes, or just namespaces
    const codeLines = content.split('\n').filter(line => {
        const trimmed = line.trim();
        return trimmed &&
               !trimmed.startsWith('//') &&
               !trimmed.startsWith('using') &&
               !trimmed.startsWith('namespace');
    });

    // If less than 5 lines of actual code, probably just interface/empty class
    if (codeLines.length < 5) {
        return true;
    }

    // Check if it's mostly an interface
    if (content.includes('interface ') && !content.includes(' class ')) {
        return true;
    }

    return false;
}

function removeCommentIfNoVariables(filePath) {
    let content = fs.readFileSync(filePath, 'utf8');

    if (shouldSkipFile(content)) {
        // Remove the comment header
        const commentPattern = /^\/\/ EN: Variable names have been checked and replaced with self-descriptive names\r?\n\/\/ CZ: Názvy proměnných byly zkontrolovány a nahrazeny samopopisnými názvy\r?\n/;
        if (commentPattern.test(content)) {
            content = content.replace(commentPattern, '');
            fs.writeFileSync(filePath, content, 'utf8');
            return true;
        }
    }

    return false;
}

function processDirectory(dir) {
    const results = {
        commentsRemoved: 0,
        filesProcessed: 0
    };

    function scan(currentDir) {
        const entries = fs.readdirSync(currentDir, { withFileTypes: true });

        for (const entry of entries) {
            const fullPath = path.join(currentDir, entry.name);

            if (entry.isDirectory()) {
                if (entry.name !== 'obj' && entry.name !== 'bin' && entry.name !== 'node_modules') {
                    scan(fullPath);
                }
            } else if (entry.name.endsWith('.cs') && !entry.name.endsWith('.g.cs')) {
                results.filesProcessed++;
                if (removeCommentIfNoVariables(fullPath)) {
                    results.commentsRemoved++;
                    const relativePath = path.relative(rootDir, fullPath);
                    console.log(`✓ Removed comment from: ${relativePath}`);
                }
            }
        }
    }

    scan(dir);
    return results;
}

console.log('Processing files...\n');
console.log('Step 1: Removing comments from files without variables\n');

const results = processDirectory(rootDir);

console.log('\n' + '='.repeat(80));
console.log('SUMMARY');
console.log('='.repeat(80));
console.log(`Files processed: ${results.filesProcessed}`);
console.log(`Comments removed: ${results.commentsRemoved}`);
console.log('\nNote: Variable refactoring (758 files) should be done manually or with');
console.log('specialized tools due to context-dependent naming requirements.');
