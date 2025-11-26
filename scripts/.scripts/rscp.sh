#!/bin/bash

# --- Utility Functions ---

check_wl_copy() {
    if ! command -v wl-copy &> /dev/null; then
        echo "Error: wl-copy command not found. Please install wl-clipboard." >&2
        exit 1
    fi
}

format_file() {
    local file=$1
    local relative_path=${file#./}
    echo "// $relative_path"
    echo
    cat "$file"
    echo
    echo
}

# --- Rust Project Functions ---

is_rust_project() {
    local target_dir=${1:-.}
    if [ ! -f "$target_dir/Cargo.toml" ]; then
        return 1
    fi
    if [ ! -f "$target_dir/src/main.rs" ] && [ ! -f "$target_dir/src/lib.rs" ] && \
       [ ! -f "$target_dir/main.rs" ] && [ ! -f "$target_dir/lib.rs" ]; then
        return 1
    fi
    return 0
}

process_rust_project() {
    local temp_file=$1
    local target_dir=${2:-.}
    echo "Info: Detected Rust project." >&2
    format_file "$target_dir/Cargo.toml" >> "$temp_file"
    find "$target_dir" -name "*.rs" -not -path "$target_dir/target/*" | sort | while read -r file; do
        format_file "$file" >> "$temp_file"
    done
}

# --- Svelte Project Functions ---

is_svelte_project() {
    local source_dir=${1:-src}
    if [ "$source_dir" = "." ]; then
        if find "$source_dir" -maxdepth 1 \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -print -quit | grep -q .; then
            return 0
        fi
        return 1
    fi
    if [ ! -f "package.json" ]; then
        return 1
    fi
    if [ -f "svelte.config.js" ] || [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
        return 0
    fi
    if [ -d "$source_dir" ]; then
        if find "$source_dir" \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -print -quit | grep -q .; then
            return 0
        fi
    fi
    return 1
}

process_svelte_project() {
    local temp_file=$1
    local source_dir=${2:-src}
    echo "Info: Detected Svelte project." >&2
    if [ "$source_dir" != "." ]; then
        [ -f "package.json" ] && format_file "package.json" >> "$temp_file"
        [ -f "svelte.config.js" ] && format_file "svelte.config.js" >> "$temp_file"
        [ -f "vite.config.js" ] && format_file "vite.config.js" >> "$temp_file"
        [ -f "vite.config.ts" ] && format_file "vite.config.ts" >> "$temp_file"
    fi
    if [ -d "$source_dir" ]; then
        find "$source_dir" \( -name "*.svelte" -o -name "*.ts" -o -name "*.js" \) -type f | sort | while read -r file; do
            format_file "$file" >> "$temp_file"
        done
    else
        echo "Warning: $source_dir/ directory not found for Svelte project. No source files will be copied." >&2
    fi
}

# --- C Project Functions ---

is_c_project() {
    local target_dir=${1:-.}
    # Check for common C project indicators
    if find "$target_dir" \( -name "*.c" -o -name "*.h" \) -print -quit | grep -q .; then
        return 0
    fi
    if [ -f "$target_dir/Makefile" ] || [ -f "$target_dir/CMakeLists.txt" ] || [ -f "$target_dir/meson.build" ]; then
        return 0
    fi
    return 1
}

process_c_project() {
    local temp_file=$1
    local target_dir=${2:-.}
    echo "Info: Detected C project." >&2

    # Include common project configuration files if they exist
    [ -f "$target_dir/Makefile" ] && format_file "$target_dir/Makefile" >> "$temp_file"
    [ -f "$target_dir/CMakeLists.txt" ] && format_file "$target_dir/CMakeLists.txt" >> "$temp_file"
    [ -f "$target_dir/meson.build" ] && format_file "$target_dir/meson.build" >> "$temp_file"

    # Include all .c and .h files
    find "$target_dir/src" \( -name "*.c" -o -name "*.h" \) -not -path "$target_dir/build/*" | sort | while read -r file; do
        format_file "$file" >> "$temp_file"
    done
}

# --- Main Script ---

main() {
    local source_dir="src"
    local output_nvim=false

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --output-nvim)
                output_nvim=true
                ;;
            *)
                source_dir="$arg"
                ;;
        esac
    done

    if [ "$output_nvim" = false ]; then
        check_wl_copy
    fi

    temp_file=$(mktemp)
    trap 'rm -f "$temp_file"' EXIT
    local project_type_processed=""

    if is_rust_project "."; then
        process_rust_project "$temp_file" "."
        project_type_processed="Rust"
    elif is_svelte_project "$source_dir"; then
        process_svelte_project "$temp_file" "$source_dir"
        project_type_processed="Svelte"
    elif is_c_project "."; then
        process_c_project "$temp_file" "."
        project_type_processed="C"
    else
        echo "Error: Could not determine project type (Rust, Svelte, or C)." >&2
        exit 1
    fi

    if [ ! -s "$temp_file" ]; then
        echo "Warning: No files were collected for the $project_type_processed project. Clipboard will be empty." >&2
    fi

    if [ "$output_nvim" = true ]; then
        nvim "$temp_file"
    else
        wl-copy < "$temp_file"
        echo "$project_type_processed project contents copied to clipboard successfully!" >&2
    fi
}

main "$@"
