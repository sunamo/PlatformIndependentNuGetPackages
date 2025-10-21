const fs = require('fs');
const path = require('path');

const baseDir = 'E:\\vs\\Projects\\PlatformIndependentNuGetPackages';

// EN: List of 38 files that need fixing
// CZ: Seznam 38 souborů které je třeba opravit
const filesToFix = [
    'SunamoChar\\SunamoChar\\CharHelper.cs',
    'SunamoCl\\SunamoCl\\SunamoCmd\\Tables\\TableParser.cs',
    'SunamoClipboard\\SunamoClipboard\\ClipboardHelper.cs',
    'SunamoCollections\\SunamoCollections\\CA.cs',
    'SunamoCollectionsGeneric\\SunamoCollectionsGeneric\\Collections\\CyclingCollection.cs',
    'SunamoColors\\SunamoColors\\UtilsHex.cs',
    'SunamoConverters\\SunamoConverters\\Converts\\ConvertCamelConventionWithNumbers.cs',
    'SunamoConverters\\SunamoConverters\\Converts\\ConvertDayShortcutString.cs',
    'SunamoConverters\\SunamoConverters\\Converts\\ConvertSnakeConvention.cs',
    'SunamoCsproj\\SunamoCsproj\\CsprojHelper.cs',
    'SunamoCsproj\\SunamoCsproj\\CsprojNsHelper.cs',
    'SunamoCsproj\\SunamoCsproj\\Data\\ItemGroupElement.cs',
    'SunamoData\\SunamoData\\Data\\ABC.cs',
    'SunamoDateTime\\SunamoDateTime\\NormalizeDate.cs',
    'SunamoDevCode\\SunamoDevCode\\Aps\\ApsHelper.cs',
    'SunamoDevCode\\SunamoDevCode\\GenerateJson.cs',
    'SunamoDevCode\\SunamoDevCode\\PpkOnDriveDevCodeBase.cs',
    'SunamoDevCode\\SunamoDevCode\\RepoGetFileMascGeneratorData.cs',
    'SunamoDevCode\\SunamoDevCode\\SunamoSolutionsIndexer\\FoldersWithSolutions.cs',
    'SunamoDevCode\\SunamoDevCode\\ToNetCore\\research\\InWeb.cs',
    'SunamoDevCode\\SunamoDevCode\\_sunamo\\SunamoConverters\\Converts\\ConvertSnakeConvention.cs',
    'SunamoDevCode\\SunamoDevCode\\_sunamo\\SunamoFileSystem\\FS.cs',
    'SunamoEnumsHelper\\SunamoEnumsHelper\\EnumHelper.cs',
    'SunamoFileIO\\SunamoFileIO\\EncodingHelper.cs',
    'SunamoFileSystem\\SunamoFileSystem\\FS.cs',
    'SunamoFileSystem\\SunamoFileSystem\\_sunamo\\SunamoStringSplit\\SHSplit.cs',
    'SunamoPS\\SunamoPS\\PowershellParser.cs',
    'SunamoPS\\SunamoPS\\PowershellRunner.cs',
    'SunamoRandom\\SunamoRandom\\RandomHelper.cs',
    'SunamoRoslyn\\SunamoRoslyn\\_public\\ABCRoslyn.cs',
    'SunamoRoslyn\\SunamoRoslyn\\_sunamo\\SH.cs',
    'SunamoSerializer\\SunamoSerializer\\SF.cs',
    'SunamoShared\\SunamoShared\\_sunamo\\SunamoString\\SH.cs',
    'SunamoStopwatch\\SunamoStopwatch\\StopwatchStatic.cs',
    'SunamoStringSplit\\SunamoStringSplit\\SHSplit.cs',
    'SunamoUri\\SunamoUri\\UH.cs',
    'SunamoUriWebServices\\SunamoUriWebServices\\UriWebServicesClassesWeb.cs',
    'SunamoXml\\SunamoXml\\XHelper.cs'
];

// EN: Common short variable patterns to replace
// CZ: Běžné vzory krátkých proměnných k nahrazení
const replacementPatterns = [
    // StringBuilder patterns
    { pattern: /\bvar sb = new StringBuilder\(/g, replacement: 'var stringBuilder = new StringBuilder(' },
    { pattern: /\bvar sb = new System\.Text\.StringBuilder\(/g, replacement: 'var stringBuilder = new System.Text.StringBuilder(' },
    { pattern: /\bStringBuilder sb([,;)\s])/g, replacement: 'StringBuilder stringBuilder$1' },
    { pattern: /\bsb\./g, replacement: 'stringBuilder.' },
    { pattern: /\bsb;/g, replacement: 'stringBuilder;' },
    { pattern: /\(sb\)/g, replacement: '(stringBuilder)' },
    { pattern: /\(sb,/g, replacement: '(stringBuilder,' },
    { pattern: / sb,/g, replacement: ' stringBuilder,' },
    { pattern: / sb\)/g, replacement: ' stringBuilder)' },

    // List patterns - var l
    { pattern: /\bvar l = new List</g, replacement: 'var list = new List<' },
    { pattern: /\bvar l = ([a-zA-Z_][a-zA-Z0-9_]*)\(\)/g, replacement: 'var list = $1()' },
    { pattern: /\bl\./g, replacement: 'list.' },
    { pattern: /\bl;/g, replacement: 'list;' },
    { pattern: /\(l\)/g, replacement: '(list)' },
    { pattern: /\(l,/g, replacement: '(list,' },
    { pattern: / l,/g, replacement: ' list,' },
    { pattern: / l\)/g, replacement: ' list)' },

    // Lines patterns - var ls
    { pattern: /\bvar ls = /g, replacement: 'var lines = ' },
    { pattern: /\bls\./g, replacement: 'lines.' },
    { pattern: /\bls;/g, replacement: 'lines;' },
    { pattern: /\(ls\)/g, replacement: '(lines)' },
    { pattern: /\(ls,/g, replacement: '(lines,' },
    { pattern: / ls,/g, replacement: ' lines,' },
    { pattern: / ls\)/g, replacement: ' lines)' },

    // Type patterns - var t
    { pattern: /\bvar t = typeof\(/g, replacement: 'var type = typeof(' },
    { pattern: /\bType t = /g, replacement: 'Type type = ' },

    // Dictionary patterns - var d
    { pattern: /\bvar d = new Dictionary</g, replacement: 'var dictionary = new Dictionary<' },
    { pattern: /\bDictionary<[^>]+> d([,;)\s])/g, replacement: 'Dictionary<$1> dictionary$2' },

    // Value patterns - var v
    { pattern: /\bvar v = /g, replacement: 'var value = ' },

    // Number patterns - var n
    { pattern: /\bvar n = /g, replacement: 'var number = ' },

    // Message patterns - var m
    { pattern: /\bvar m = /g, replacement: 'var message = ' },

    // Path patterns - var p
    { pattern: /\bvar p = /g, replacement: 'var path = ' },

    // Result patterns - var r
    { pattern: /\bvar r = /g, replacement: 'var result = ' },

    // Char patterns - var c
    { pattern: /\bvar c = /g, replacement: 'var character = ' },
    { pattern: /\bchar c([,;)\s])/g, replacement: 'char character$1' },

    // String patterns - var s
    { pattern: /\bvar s = /g, replacement: 'var str = ' },
    { pattern: /\bstring s([,;)\s])/g, replacement: 'string str$1' },

    // Element patterns - var e
    { pattern: /\bvar e = /g, replacement: 'var element = ' },

    // Array patterns - var a
    { pattern: /\bvar a = /g, replacement: 'var array = ' },

    // Boolean patterns - var b
    { pattern: /\bvar b = /g, replacement: 'var boolean = ' },

    // Coordinates - var x, y, z
    { pattern: /\bvar x = /g, replacement: 'var xCoord = ' },
    { pattern: /\bvar y = /g, replacement: 'var yCoord = ' },
    { pattern: /\bvar z = /g, replacement: 'var zCoord = ' }
];

// EN: Process a single file
// CZ: Zpracovat jeden soubor
function processFile(filePath) {
    const fullPath = path.join(baseDir, filePath);

    console.log(`Processing: ${filePath}`);

    try {
        let content = fs.readFileSync(fullPath, 'utf8');
        let modified = false;

        // EN: Apply all replacement patterns
        // CZ: Aplikovat všechny náhradní vzory
        for (const { pattern, replacement } of replacementPatterns) {
            const beforeLength = content.length;
            content = content.replace(pattern, replacement);
            if (content.length !== beforeLength) {
                modified = true;
            }
        }

        if (modified) {
            fs.writeFileSync(fullPath, content, 'utf8');
            console.log(`  ✓ Fixed: ${filePath}`);
            return true;
        } else {
            console.log(`  - No changes: ${filePath}`);
            return false;
        }
    } catch (error) {
        console.error(`  ✗ Error processing ${filePath}: ${error.message}`);
        return false;
    }
}

// EN: Main execution
// CZ: Hlavní spuštění
console.log('Starting to fix remaining short variables in 38 files...\n');

let fixedCount = 0;
for (const file of filesToFix) {
    if (processFile(file)) {
        fixedCount++;
    }
}

console.log(`\n=== Summary ===`);
console.log(`Total files processed: ${filesToFix.length}`);
console.log(`Files modified: ${fixedCount}`);
console.log(`Files unchanged: ${filesToFix.length - fixedCount}`);
