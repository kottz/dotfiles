#!/bin/bash

# Check if a URL is provided
if [ $# -eq 0 ]; then
    echo "Please provide a YouTube URL as an argument."
    exit 1
fi

# Set up temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download subtitles
yt-dlp --write-auto-subs --convert-subs srt --sub-format txt --skip-download "$1"

# Check if subtitle file was downloaded
SRT_FILE=$(find . -name "*.srt")
if [ -z "$SRT_FILE" ]; then
    echo "No subtitle file was downloaded. The video might not have subtitles."
    exit 1
fi

# Run Python script to process the subtitles
python3 $HOME/.scripts/py/srt_clean.py "$SRT_FILE"

# Find the converted text file
CONVERTED_FILE=$(find . -name "*_converted.txt")

# Copy content to clipboard
if [ -f "$CONVERTED_FILE" ]; then
    wl-copy < "$CONVERTED_FILE"
    echo "Subtitles processed and copied to clipboard."
else
    echo "Converted file not found."
    exit 1
fi

# Clean up
cd ..
rm -rf "$TEMP_DIR"

echo "Temporary files cleaned up."
