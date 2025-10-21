// EN: Script to process all Sunamo projects and add variable check comments
// CZ: Skript pro zpracování všech Sunamo projektů a přidání komentářů o kontrole proměnných
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const rootDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';
const scriptPath = path.join(rootDir, 'scripts', 'add-variable-check-comment.js');

// Get all Sunamo* directories
const allDirs = fs.readdirSync(rootDir, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory() && dirent.name.startsWith('Sunamo'))
    .map(dirent => dirent.name)
    .sort();

console.log(`Found ${allDirs.length} Sunamo projects\n`);

const results = {
    completed: [],
    failed: [],
    skipped: []
};

for (const projectDir of allDirs) {
    const projectPath = path.join(rootDir, projectDir, projectDir);

    // Check if project subdirectory exists
    if (!fs.existsSync(projectPath)) {
        console.log(`⏭️  Skipping ${projectDir} - subdirectory not found`);
        results.skipped.push(projectDir);
        continue;
    }

    try {
        console.log(`\n📦 Processing ${projectDir}...`);
        const output = execSync(`node "${scriptPath}" "${projectPath}"`, {
            encoding: 'utf8',
            stdio: 'pipe'
        });

        // Extract file count from output
        const match = output.match(/Total files processed: (\d+)/);
        const fileCount = match ? match[1] : '?';

        console.log(`✅ ${projectDir}: ${fileCount} files`);
        results.completed.push({ name: projectDir, files: fileCount });
    } catch (error) {
        console.error(`❌ Failed to process ${projectDir}: ${error.message}`);
        results.failed.push(projectDir);
    }
}

console.log('\n' + '='.repeat(80));
console.log('SUMMARY');
console.log('='.repeat(80));
console.log(`✅ Completed: ${results.completed.length} projects`);
console.log(`❌ Failed: ${results.failed.length} projects`);
console.log(`⏭️  Skipped: ${results.skipped.length} projects`);
console.log(`📊 Total: ${allDirs.length} projects`);

// Write results to file
const resultsFile = path.join(rootDir, 'processing-results.json');
fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
console.log(`\n📄 Detailed results saved to: ${resultsFile}`);
