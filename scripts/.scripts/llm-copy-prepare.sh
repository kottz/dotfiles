#!/bin/bash

# Function to format file contents with XML-style tags
format_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: '$file' is not a valid file" >&2
        return
    fi
    
    echo "<file_name>"
    echo "$file"
    echo "</file_name>"
    echo
    echo "<contents>"
    cat "$file"
    echo
    echo "</contents>"
    echo
}

# Main script
main() {
    # Check if wl-copy is available
    if ! command -v wl-copy &> /dev/null; then
        echo "Error: wl-copy command not found. Please install wl-clipboard." >&2
        exit 1
    fi

    # Create a temporary file to store the output
    temp_file=$(mktemp)

    # Process all input files
    for file in "$@"; do
        format_file "$file" >> "$temp_file"
    done

    # Copy the contents to clipboard
    wl-copy < "$temp_file"

    # Clean up
    rm "$temp_file"

    echo "File contents copied to clipboard in LLM format!" >&2
}

# Run the main function with all arguments
main "$@"
