#!/bin/bash

PYTHON_CLEAN_SCRIPT="$HOME/.scripts/py/srt_clean.py"
TRANSCRIPT_SEPARATOR="\n\n---\n\n" # Two newlines, a separator line, then two more newlines

# --- Helper Functions ---
cleanup_and_exit() {
    local exit_code="$1"
    local message="$2"
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        echo "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
    if [ -n "$message" ]; then
        echo "$message" >&2
    fi
    exit "${exit_code:-1}"
}

# Function to process a single URL
# It will create its own subdirectory within the main TEMP_DIR
# Args: 1=URL, 2=Index (for ordering), 3=Main Temp Dir, 4=Python Script Path
process_single_url_for_parallel() {
    local url="$1"
    local index="$2"
    local main_temp_dir="$3"
    local py_script="$4"
    
    local sub_dir="$main_temp_dir/$index"
    mkdir -p "$sub_dir"

    ( # Enter subshell to isolate cd and simplify error handling
        cd "$sub_dir" || { echo "Error: Could not cd into $sub_dir for URL $url" >&2; return 1; }

        echo "Downloading subtitles for URL ($index): $url"
        # Output template to make filenames somewhat predictable if needed, though we find them anyway
        if ! yt-dlp --write-auto-subs --convert-subs srt --sub-format txt --skip-download -o "%(title)s.%(ext)s" "$url"; then
            echo "Error: yt-dlp failed for URL ($index): $url" >&2
            return 1 # yt-dlp failed
        fi

        # Find the downloaded SRT file (should be only one per video in its subdir)
        SRT_FILE=$(find . -maxdepth 1 -iname "*.srt" -print -quit) # -iname for case-insensitivity
        if [ -z "$SRT_FILE" ]; then
            echo "Warning: No subtitle SRT file was downloaded for URL ($index): $url (Video might not have subs, or yt-dlp issue)." >&2
            return 2 # No SRT found
        fi

        echo "Processing SRT $SRT_FILE for URL ($index)"
        if ! python3 "$py_script" "$SRT_FILE"; then
            echo "Error: Python script '$py_script' failed for $SRT_FILE (URL $index: $url)" >&2
            return 3 # Python script failed
        fi

        CONVERTED_FILE=$(find . -maxdepth 1 -iname "*_converted.txt" -print -quit)
        if [ -z "$CONVERTED_FILE" ]; then
            echo "Error: Converted text file not found after processing $SRT_FILE (URL $index: $url)" >&2
            return 4 # Converted file not found
        fi
        
        # Output the full path to the converted file for collection by the main script
        realpath "$CONVERTED_FILE"
        return 0
    ) # Exit subshell
    # The return code of the subshell will be the return code of this function call
}
export -f process_single_url_for_parallel # Make function available to GNU Parallel

# --- Main Script ---

# Check if a URL is provided
if [ $# -eq 0 ]; then
    echo "Please provide one or more YouTube URLs as arguments."
    exit 1
fi

# Check for GNU Parallel
if ! command -v parallel &> /dev/null; then
    echo "Error: GNU Parallel is not installed. Please install it to use this script with multiple URLs."
    echo "For a single URL, it might proceed if we didn't export the function, but it's required for multi-URL."
    exit 1
fi

# Set up temporary directory
TEMP_DIR=$(mktemp -d youtube_subs_XXXXXX --tmpdir) # Safer mktemp
# Trap EXIT signal to ensure cleanup
trap 'cleanup_and_exit $? "Script interrupted or finished."' EXIT

echo "Temporary directory created: $TEMP_DIR"

declare -a urls_to_process=("$@")
declare -a processed_file_paths_ordered # Will store paths to _converted.txt files in order

# --- Processing Logic ---

if [ "${#urls_to_process[@]}" -eq 1 ]; then
    # --- SINGLE URL SCENARIO (original logic, slightly adapted) ---
    echo "Processing a single URL..."
    cd "$TEMP_DIR" || cleanup_and_exit 1 "Failed to cd to $TEMP_DIR"

    if ! yt-dlp --write-auto-subs --convert-subs srt --sub-format txt --skip-download "${urls_to_process[0]}"; then
        cleanup_and_exit 1 "yt-dlp failed for ${urls_to_process[0]}"
    fi

    SRT_FILE=$(find . -maxdepth 1 -iname "*.srt" -print -quit)
    if [ -z "$SRT_FILE" ]; then
        cleanup_and_exit 1 "No subtitle SRT file was downloaded. The video might not have subtitles."
    fi

    echo "Processing SRT $SRT_FILE"
    if ! python3 "$PYTHON_CLEAN_SCRIPT" "$SRT_FILE"; then
         cleanup_and_exit 1 "Python script '$PYTHON_CLEAN_SCRIPT' failed for $SRT_FILE"
    fi

    CONVERTED_FILE=$(find . -maxdepth 1 -iname "*_converted.txt" -print -quit)
    if [ -z "$CONVERTED_FILE" ]; then
        cleanup_and_exit 1 "Converted file not found after processing $SRT_FILE."
    fi
    processed_file_paths_ordered+=("$(realpath "$CONVERTED_FILE")")
    cd - > /dev/null # Go back to original directory before TEMP_DIR was entered

else
    # --- MULTIPLE URLS SCENARIO (using GNU Parallel) ---
    echo "Processing ${#urls_to_process[@]} URLs in parallel..."
    
    declare -a indices=()
    for i in $(seq 0 $((${#urls_to_process[@]} - 1))); do
        indices+=("$i")
    done

    # Run the processing function in parallel for each URL and its index
    # --halt soon,fail=1: if one job fails, stop spawning new ones and let running ones finish.
    # --no-notice: suppress GNU Parallel's startup/completion messages.
    # We collect the full paths of the successfully converted files.
    mapfile -t collected_paths < <(parallel --no-notice --halt soon,fail=1 -j 0 \
        process_single_url_for_parallel {1} {2} "$TEMP_DIR" "$PYTHON_CLEAN_SCRIPT" \
        ::: "${urls_to_process[@]}" :::+ "${indices[@]}")
    
    parallel_exit_status=$?
    if [ $parallel_exit_status -ne 0 ]; then
        echo "Warning: GNU Parallel exited with status $parallel_exit_status. Some jobs might have failed."
        # Continue if some files were processed, but warn the user.
    fi

    if [ ${#collected_paths[@]} -eq 0 ]; then
        cleanup_and_exit 1 "No subtitle files were successfully processed from any of the URLs."
    fi

    # The collected_paths might be out of order due to parallelism.
    # Sort them based on the subdirectory index (e.g., /tmp/.../0/file.txt, /tmp/.../1/file.txt)
    # This relies on the fact that `realpath` was used and subdirectories are 0, 1, 2...
    echo "Sorting processed file paths..."
    mapfile -t processed_file_paths_ordered < <(printf "%s\n" "${collected_paths[@]}" | sort)
fi


# --- Concatenation and Clipboard ---
if [ ${#processed_file_paths_ordered[@]} -eq 0 ]; then
    cleanup_and_exit 1 "No subtitles were successfully processed to be concatenated."
fi

FINAL_CONCATENATED_FILE="$TEMP_DIR/all_transcripts_combined.txt"
echo "Concatenating ${#processed_file_paths_ordered[@]} transcript(s) into $FINAL_CONCATENATED_FILE"
# Ensure the file is empty before starting
> "$FINAL_CONCATENATED_FILE"

is_first_file=true
for file_path in "${processed_file_paths_ordered[@]}"; do
    if [ -f "$file_path" ] && [ -s "$file_path" ]; then # Check if file exists and is not empty
        if ! $is_first_file; then
            # Add separator only *before* subsequent files
            printf "$TRANSCRIPT_SEPARATOR" >> "$FINAL_CONCATENATED_FILE"
        fi
        cat "$file_path" >> "$FINAL_CONCATENATED_FILE"
        is_first_file=false
    else
        echo "Warning: Processed file '$file_path' not found or is empty during concatenation. Skipping." >&2
    fi
done

if [ -f "$FINAL_CONCATENATED_FILE" ] && [ -s "$FINAL_CONCATENATED_FILE" ]; then
    wl-copy < "$FINAL_CONCATENATED_FILE"
    echo "All subtitles processed. Combined transcript copied to clipboard."
    # echo "Combined transcript is also available at: $FINAL_CONCATENATED_FILE" # Optional
else
    cleanup_and_exit 1 "Failed to create a non-empty concatenated transcript file."
fi

# Cleanup is handled by the trap
echo "Script finished successfully."
exit 0
