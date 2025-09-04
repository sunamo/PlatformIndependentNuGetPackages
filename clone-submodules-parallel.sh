#!/bin/bash

# Parallel submodule cloning script for PlatformIndependentNuGetPackages
# This script clones all submodules in parallel for faster initialization

echo "Starting parallel submodule cloning..."
echo "Found $(git submodule status | wc -l) submodules"

# Number of parallel jobs (adjust based on your system capacity)
MAX_JOBS=8

# Initialize submodules config
git submodule init

# Function to clone a single submodule
clone_submodule() {
    local path=$1
    local url=$2
    
    if [ ! -d "$path/.git" ]; then
        echo "Cloning: $path"
        git submodule update --init --recursive "$path" 2>&1 | sed "s/^/[$path] /"
    else
        echo "Already exists: $path"
    fi
}

export -f clone_submodule

# Get all submodule paths and URLs
git config --file .gitmodules --get-regexp "path|url" | \
    awk 'NR%2{path=$2} !(NR%2){gsub(/.*\.url/, "", $1); print path, $2}' | \
    while read -r path url; do
        # Run in background with job control
        while [ $(jobs -r | wc -l) -ge $MAX_JOBS ]; do
            sleep 0.1
        done
        clone_submodule "$path" "$url" &
    done

# Wait for all background jobs to complete
wait

echo "All submodules cloned successfully!"
echo "Updating submodules to latest commits..."

# Update all submodules to their recorded commits
git submodule update --recursive

echo "Done! All submodules are ready."