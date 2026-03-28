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

const results = {
    completed: [],
    failed: [],
    skipped: []
};

for (const projectDir of allDirs) {
    const projectPath = path.join(rootDir, projectDir, projectDir);

    // Check if project subdirectory exists
    if (!fs.existsSync(projectPath)) {
        results.skipped.push(projectDir);
        continue;
    }

    try {
        const output = execSync(`node "${scriptPath}" "${projectPath}"`, {
            encoding: 'utf8',
            stdio: 'pipe'
        });

        // Extract file count from output
        const match = output.match(/Total files processed: (\d+)/);
        const fileCount = match ? match[1] : '?';
        results.completed.push({ name: projectDir, files: fileCount });
    } catch (error) {
        console.error(`❌ Failed to process ${projectDir}: ${error.message}`);
        results.failed.push(projectDir);
    }
}

// Write results to file
const resultsFile = path.join(rootDir, 'processing-results.json');
fs.writeFileSync(resultsFile, JSON.stringify(results, null, 2));
