#!/bin/bash

# Check if a directory path is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

# Directory to search
search_dir="$1"

# Temporary file to store md5 hashes
temp_file=$(mktemp)

# Find all files recursively, calculate their md5 hashes, and store in the temporary file
find "$search_dir" -type f -exec md5sum {} + | sort > "$temp_file"

# Process the temporary file to find duplicates
awk '{
    hash=$1
    file=$2
    if (hash in files) {
        if (!(hash in printed)) {
            print "Duplicate files with hash", hash ":"
            print files[hash]
            printed[hash] = 1
        }
        print file
    } else {
        files[hash] = file
    }
}' "$temp_file"

# Remove the temporary file
rm "$temp_file"
