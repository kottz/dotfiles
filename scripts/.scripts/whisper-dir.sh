#!/bin/bash

# Loop through all mp3 files in current directory
for mp3_file in *.mp3; do
    # Skip if no mp3 files found
    [[ -f "$mp3_file" ]] || continue
    
    echo "Processing: $mp3_file"
    
    # Create temporary wav filename
    wav_file="${mp3_file%.*}.wav"
    
    # Convert to wav format
    echo "Converting to WAV..."
    ffmpeg -i "$mp3_file" -ar 16000 -ac 1 -c:a pcm_s16le "$wav_file"
    
    # Run whisper transcription
    echo "Running transcription..."
    $HOME/utils/whisper/whisper-cli -m $HOME/utils/whisper/ggml-large-v3-turbo.bin -f "$wav_file" -l sv --output-srt --output-json-full --output-txt
    
    # Remove temporary wav file
    echo "Cleaning up..."
    rm "$wav_file"
    
    echo "Completed: $mp3_file"
    echo "----------------------------------------"
done

echo "All files processed!"
