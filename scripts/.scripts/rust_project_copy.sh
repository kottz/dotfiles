#!/bin/bash

# Function to check if it's a valid Rust project
check_rust_project() {
    if [ ! -f "Cargo.toml" ]; then
        echo "Error: Cargo.toml not found. This doesn't appear to be a valid Rust project." >&2
        exit 1
    fi

    if [ ! -f "src/main.rs" ] && [ ! -f "src/lib.rs" ]; then
        echo "Error: Neither src/main.rs nor src/lib.rs found. This doesn't appear to be a valid Rust project." >&2
        exit 1
    fi
}

# Function to format file contents with header
format_file() {
    local file=$1
    local relative_path=${file#./}
    echo "// $relative_path"
    echo
    cat "$file"
    echo
    echo
}

# Main script
main() {
    # Check if wl-copy is available
    if ! command -v wl-copy &> /dev/null; then
        echo "Error: wl-copy command not found. Please install wl-clipboard." >&2
        exit 1
    fi

    # Check if we're in a Rust project
    check_rust_project

    # Create a temporary file to store the output
    temp_file=$(mktemp)

    # Format Cargo.toml
    format_file "Cargo.toml" >> "$temp_file"

    # Find and format all .rs files, excluding the target directory
    find . -name "*.rs" -not -path "./target/*" | sort | while read -r file; do
        format_file "$file" >> "$temp_file"
    done

    # Copy the contents to clipboard
    wl-copy < "$temp_file"

    # Clean up
    rm "$temp_file"

    echo "Project contents copied to clipboard successfully!" >&2
}

# Run the main function
main
