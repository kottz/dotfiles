#!/bin/bash

# Function to process a single file
process_file() {
    input_file="$1"
    # Skip if file is already an AV1 encode
    [[ "$input_file" == *"_av1.mkv" ]] && return
    
    output_file="${input_file%.*}_av1.mkv"
    
    # Skip if output file already exists
    if [[ -f "$output_file" ]]; then
        echo "Skipping: $input_file (AV1 version already exists)"
        return
    fi
    
    echo "Processing: $input_file -> $output_file"
    
    ffmpeg -i "$input_file" \
        -map 0 \
        -c:v libsvtav1 -preset 4 -crf 40 -g 240 \
        -svtav1-params tune=2:enable-qm=1:qm-min=2:chroma-qm-max=15:sharpness=1:qp-scale-compress-strength=2:enable-variance-boost=1:variance-boost-strength=1:variance-octile=4 \
        -c:a libopus -b:a 96k \
        -c:s copy \
        "$output_file"
        
    echo "Completed: $input_file"
    echo "----------------------------------------"
}

export -f process_file

# Find all mkv files and process them in parallel, 4 at a time
find . -maxdepth 1 -name "*.mkv" -print0 | parallel -0 -j 4 process_file

echo "All files processed!"
