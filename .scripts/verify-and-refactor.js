const fs = require('fs');
const path = require('path');

const rootDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';
const commentPattern = /^\/\/ EN: Variable names have been checked and replaced with self-descriptive names/;

// Patterns for short variables (excluding i, j, k which are OK for loops)
const shortVarPatterns = [
    /\bvar\s+(sb|l|ls|t|d|v|n|m|p|r|c|s|e|a|b|x|y|z)\s*=/,
    /\bStringBuilder\s+(sb)\s*=/,
    /\bList<[^>]+>\s+(l|ls)\s*=/,
];

function hasShortVariables(content) {
    // Skip comment lines
    const lines = content.split('\n').filter(line => !line.trim().startsWith('//'));
    const codeContent = lines.join('\n');

    return shortVarPatterns.some(pattern => pattern.test(codeContent));
}

function hasCommentHeader(content) {
    return commentPattern.test(content);
}

const results = {
    hasCommentButStillHasShortVars: [],
    hasCommentAndNoShortVars: [],
    noCommentButHasShortVars: [],
    noCommentNoShortVars: []
};

function scanDirectory(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });

    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);

        if (entry.isDirectory()) {
            if (entry.name !== 'obj' && entry.name !== 'bin' && entry.name !== 'node_modules') {
                scanDirectory(fullPath);
            }
        } else if (entry.name.endsWith('.cs') && !entry.name.endsWith('.g.cs')) {
            const content = fs.readFileSync(fullPath, 'utf8');
            const hasComment = hasCommentHeader(content);
            const hasShort = hasShortVariables(content);
            const relativePath = path.relative(rootDir, fullPath);

            if (hasComment && hasShort) {
                results.hasCommentButStillHasShortVars.push(relativePath);
            } else if (hasComment && !hasShort) {
                results.hasCommentAndNoShortVars.push(relativePath);
            } else if (!hasComment && hasShort) {
                results.noCommentButHasShortVars.push(relativePath);
            } else {
                results.noCommentNoShortVars.push(relativePath);
            }
        }
    }
}
scanDirectory(rootDir);
if (results.hasCommentButStillHasShortVars.length > 50) {
}

// Save results
fs.writeFileSync(path.join(rootDir, 'verification-results.json'), JSON.stringify(results, null, 2));
