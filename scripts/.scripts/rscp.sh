#!/bin/bash

# Function to check if wl-copy is available (moved to top for early check)
check_wl_copy() {
    if ! command -v wl-copy &> /dev/null; then
        echo "Error: wl-copy command not found. Please install wl-clipboard." >&2
        exit 1
    fi
}

# Function to format file contents with header
format_file() {
    local file=$1
    local relative_path=${file#./} # Strip leading ./ if present
    echo "// $relative_path"
    echo
    cat "$file"
    echo
    echo
}

# --- Rust Project Functions ---

# Function to check if it's a valid Rust project (returns 0 if true, 1 if false)
is_rust_project() {
    local target_dir=${1:-.}  # Default to current directory if no argument
    
    if [ ! -f "$target_dir/Cargo.toml" ]; then
        return 1
    fi

    if [ ! -f "$target_dir/src/main.rs" ] && [ ! -f "$target_dir/src/lib.rs" ] && \
       [ ! -f "$target_dir/main.rs" ] && [ ! -f "$target_dir/lib.rs" ]; then
        return 1
    fi
    return 0
}

# Function to process Rust project files
process_rust_project() {
    local temp_file=$1
    local target_dir=${2:-.}  # Default to current directory if no argument
    echo "Info: Detected Rust project." >&2

    format_file "$target_dir/Cargo.toml" >> "$temp_file"

    # Find and format all .rs files, excluding the target directory
    find "$target_dir" -name "*.rs" -not -path "$target_dir/target/*" | sort | while read -r file; do
        format_file "$file" >> "$temp_file"
    done
}

# --- Svelte Project Functions ---

# Function to check if it's a valid Svelte project (returns 0 if true, 1 if false)
is_svelte_project() {
    local source_dir=${1:-src}  # Default to src if no argument provided
    
    # If source_dir is "." (current directory), be more permissive
    if [ "$source_dir" = "." ]; then
        # Just check if current directory contains .svelte, .ts, or .js files
        if find "$source_dir" -maxdepth 1 \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -print -quit | grep -q .; then
            return 0
        fi
        return 1
    fi
    
    # For standard project detection, require package.json
    if [ ! -f "package.json" ]; then
        return 1
    fi

    # Check for common Svelte config files or a source directory with Svelte/TS/JS files
    if [ -f "svelte.config.js" ] || [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
        return 0
    fi

    if [ -d "$source_dir" ]; then
        # Check if source directory contains any .svelte, .ts, or .js files
        if find "$source_dir" \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -print -quit | grep -q .; then
            return 0
        fi
    fi
    return 1
}

# Function to process Svelte project files
process_svelte_project() {
    local temp_file=$1
    local source_dir=${2:-src}  # Default to src if no argument provided
    echo "Info: Detected Svelte project." >&2

    # Only process project files if we're not just processing a source directory
    if [ "$source_dir" != "." ]; then
        if [ -f "package.json" ]; then
            format_file "package.json" >> "$temp_file"
        fi
        if [ -f "svelte.config.js" ]; then
            format_file "svelte.config.js" >> "$temp_file"
        fi
        if [ -f "vite.config.js" ]; then # Common with SvelteKit
            format_file "vite.config.js" >> "$temp_file"
        fi
        if [ -f "vite.config.ts" ]; then # Common with SvelteKit
            format_file "vite.config.ts" >> "$temp_file"
        fi
    fi

    # Find and format all .svelte, .ts, .js files in the specified directory
    if [ -d "$source_dir" ]; then
        find "$source_dir" \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -type f | sort | while read -r file; do
            format_file "$file" >> "$temp_file"
        done
    else
        echo "Warning: $source_dir/ directory not found for Svelte project. No source files will be copied from there." >&2
    fi
}

# --- Main Script ---
main() {
    local source_dir=${1:-src}  # Use first argument as source directory, default to "src"
    
    # Check if wl-copy is available (early exit if not)
    check_wl_copy

    # Create a temporary file to store the output
    # Using process substitution for mktemp to avoid issues with subshells for some mktemp versions
    temp_file=$(mktemp)
    # Ensure temp_file is removed on exit, even if script errors out
    trap 'rm -f "$temp_file"' EXIT

    local project_type_processed=""

    if is_rust_project "."; then
        process_rust_project "$temp_file" "."
        project_type_processed="Rust"
    elif is_svelte_project "$source_dir"; then
        process_svelte_project "$temp_file" "$source_dir"
        project_type_processed="Svelte"
    else
        echo "Error: Could not determine project type. Not a recognized Rust or Svelte project." >&2
        echo "Rust check: Cargo.toml and (src/main.rs or src/lib.rs or main.rs or lib.rs)" >&2
        if [ "$source_dir" = "." ]; then
            echo "Svelte check (current dir): .svelte/.ts/.js files in current directory" >&2
        else
            echo "Svelte check: package.json and (svelte.config.js or vite.config.js/ts or $source_dir/ with .svelte/.ts/.js files)" >&2
        fi
        exit 1 # temp_file will be removed by trap
    fi

    if [ ! -s "$temp_file" ] && [ -n "$project_type_processed" ]; then
        echo "Warning: No files were collected for the $project_type_processed project. Clipboard will be empty." >&2
    elif [ ! -s "$temp_file" ]; then
        echo "Warning: No files were collected. Clipboard will be empty." >&2
        # No need to exit, wl-copy will just copy nothing
    fi


    # Copy the contents to clipboard
    wl-copy < "$temp_file"

    # Clean up is handled by trap
    # rm "$temp_file" # No longer needed here due to trap

    if [ -n "$project_type_processed" ]; then
        echo "$project_type_processed project contents copied to clipboard successfully!" >&2
    else
        # This case should ideally not be reached due to prior exit, but as a fallback:
        echo "Contents copied to clipboard (though project type was not definitively processed)." >&2
    fi
}

# Run the main function with all arguments
main "$@"
