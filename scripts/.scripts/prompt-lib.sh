#!/bin/bash

# prompt-lib - A prompt library manager using tofi launcher
# Usage:
#   prompt-lib                    # Launch tofi menu to select and copy prompt
#   prompt-lib -a -t "title" -c "content"  # Add new prompt
#   prompt-lib -l                 # List all prompts
#   prompt-lib -h                 # Show help

set -euo pipefail

# Configuration
PROMPTS_FILE="$HOME/.config/prompt-lib/prompts.json"
HISTORY_FILE="$HOME/.config/prompt-lib/history"

# Ensure config directory exists
mkdir -p "$(dirname "$PROMPTS_FILE")"
mkdir -p "$(dirname "$HISTORY_FILE")"

# Initialize prompts file if it doesn't exist
if [[ ! -f "$PROMPTS_FILE" ]]; then
    echo '[]' > "$PROMPTS_FILE"
fi

# Initialize history file if it doesn't exist
if [[ ! -f "$HISTORY_FILE" ]]; then
    touch "$HISTORY_FILE"
fi

show_help() {
    cat << EOF
prompt-lib - LLM Prompt Library Manager

USAGE:
    prompt-lib [OPTIONS]

OPTIONS:
    -a              Add new prompt (requires -t and -c)
    -t <title>      Prompt title
    -c <content>    Prompt content
    -l              List all prompts
    -h              Show this help

EXAMPLES:
    prompt-lib                                    # Launch tofi menu
    prompt-lib -a -t "Code Review" -c "Review this code for bugs and improvements"
    prompt-lib -l                                 # List all prompts
EOF
}

generate_id() {
    # Generate a simple numeric ID based on current prompts
    local max_id=0
    local current_ids
    current_ids=$(jq -r '.[].id' "$PROMPTS_FILE" 2>/dev/null | grep -E '^[0-9]+$' || true)
    
    if [[ -n "$current_ids" ]]; then
        while read -r id; do
            if [[ $id -gt $max_id ]]; then
                max_id=$id
            fi
        done <<< "$current_ids"
    fi
    
    echo $((max_id + 1))
}

add_prompt() {
    local title="$1"
    local content="$2"
    local id
    
    id=$(generate_id)
    
    # Create new prompt object and add to array
    local new_prompt
    new_prompt=$(jq -n \
        --arg id "$id" \
        --arg title "$title" \
        --arg text "$content" \
        '{id: ($id | tonumber), title: $title, text: $text}')
    
    # Add to prompts file
    jq --argjson prompt "$new_prompt" '. += [$prompt]' "$PROMPTS_FILE" > "${PROMPTS_FILE}.tmp" && mv "${PROMPTS_FILE}.tmp" "$PROMPTS_FILE"
    
    echo "Added prompt: '$title' (ID: $id)"
}

list_prompts() {
    if [[ ! -s "$PROMPTS_FILE" ]] || [[ "$(jq length "$PROMPTS_FILE")" -eq 0 ]]; then
        echo "No prompts found."
        return
    fi
    
    echo "Available prompts:"
    echo "=================="
    jq -r '.[] | "ID: \(.id) | \(.title)"' "$PROMPTS_FILE"
}

update_history() {
    local selected_title="$1"
    
    # Read current history, remove the selected item if it exists, then add it to the front
    local temp_history=()
    if [[ -f "$HISTORY_FILE" ]]; then
        while IFS= read -r line; do
            if [[ "$line" != "$selected_title" ]]; then
                temp_history+=("$line")
            fi
        done < "$HISTORY_FILE"
    fi
    
    # Write history with selected item first, keep only last 10 items
    {
        echo "$selected_title"
        printf "%s\n" "${temp_history[@]:0:9}"
    } > "$HISTORY_FILE"
}

launch_tofi_menu() {
    if [[ ! -s "$PROMPTS_FILE" ]] || [[ "$(jq length "$PROMPTS_FILE")" -eq 0 ]]; then
        echo "No prompts available. Add some prompts first using -a flag."
        exit 1
    fi
    
    # Read history
    local history=()
    if [[ -f "$HISTORY_FILE" ]]; then
        while IFS= read -r line; do
            [[ -n "$line" ]] && history+=("$line")
        done < "$HISTORY_FILE"
    fi
    
    # Create associative array of prompts (title -> content)
    declare -A prompt_map
    while IFS= read -r line; do
        local title content
        title=$(echo "$line" | jq -r '.title')
        content=$(echo "$line" | jq -r '.text')
        prompt_map["$title"]="$content"
    done < <(jq -c '.[]' "$PROMPTS_FILE")
    
    # Create sorted list with history items first
    local sorted_prompts=()
    
    # Add history items that still exist in prompt_map
    for prompt in "${history[@]}"; do
        if [[ -n "${prompt_map[$prompt]:-}" ]]; then
            sorted_prompts+=("$prompt")
        fi
    done
    
    # Add remaining prompts that aren't in history
    for prompt in "${!prompt_map[@]}"; do
        if [[ ! " ${history[*]} " =~ " ${prompt} " ]]; then
            sorted_prompts+=("$prompt")
        fi
    done
    
    if [[ ${#sorted_prompts[@]} -eq 0 ]]; then
        echo "No valid prompts found."
        exit 1
    fi
    
    # Generate menu using tofi and get selected prompt title
    local selected_prompt
    selected_prompt=$(printf "%s\n" "${sorted_prompts[@]}" | tofi --prompt-text "Select prompt:" --font /usr/share/fonts/adobe-source-code-pro/SourceCodePro-Regular.otf --hint-font false)
    
    # Check if user made a selection
    if [[ -n "$selected_prompt" && -n "${prompt_map[$selected_prompt]:-}" ]]; then
        # Copy to clipboard
        echo -n "${prompt_map[$selected_prompt]}" | wl-copy
        
        # Update history
        update_history "$selected_prompt"
        
        echo "Copied to clipboard: $selected_prompt"
    else
        echo "No selection made or prompt not found."
        exit 1
    fi
}

# Parse command line arguments
add_mode=false
title=""
content=""
list_mode=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -a)
            add_mode=true
            shift
            ;;
        -t)
            if [[ -n "${2:-}" ]]; then
                title="$2"
                shift 2
            else
                echo "Error: -t requires a title argument"
                exit 1
            fi
            ;;
        -c)
            if [[ -n "${2:-}" ]]; then
                content="$2"
                shift 2
            else
                echo "Error: -c requires a content argument"
                exit 1
            fi
            ;;
        -l)
            list_mode=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Execute based on mode
if [[ "$add_mode" == true ]]; then
    if [[ -z "$title" || -z "$content" ]]; then
        echo "Error: Adding a prompt requires both -t (title) and -c (content) flags"
        show_help
        exit 1
    fi
    add_prompt "$title" "$content"
elif [[ "$list_mode" == true ]]; then
    list_prompts
else
    # Default behavior: launch tofi menu
    launch_tofi_menu
fi
