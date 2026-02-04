#!/bin/bash
# Find all projects with build errors

for dir in Sunamo*/; do
    if [ -f "$dir"*.sln ]; then
        project=$(basename "$dir")
        echo "Checking $project..."
        cd "$dir"
        errors=$(dotnet build *.sln 2>&1 | grep -i "error CS" | wc -l)
        if [ "$errors" -gt 0 ]; then
            echo "FAILED: $project ($errors errors)"
        fi
        cd ..
    fi
done
