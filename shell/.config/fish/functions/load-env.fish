function load-env --description "Loads environment variables from a specified .env file (supports .gpg encrypted files)"
    # --- Argument and File Validation ---
    if test -z "$argv[1]"
        echo "Usage: load-env <path/to/env_file>" >&2
        echo "Error: No environment file specified." >&2
        return 1
    end

    set -l env_file "$argv[1]"

    if not test -f "$env_file"
        echo "Error: Environment file '$env_file' not found." >&2
        return 1
    end

    echo "Loading environment variables from '$env_file'..."
    set -l lines_loaded 0

    # --- Choose input stream (plain vs. gpg-decrypted) ---
    set -l input_cmd
    if string match -q '*.gpg' -- "$env_file"
        # gpg will output plaintext to stdout
        set input_cmd "gpg -dq -- '$env_file'"
    else
        set input_cmd "cat -- '$env_file'"
    end

    # --- Line-by-Line Processing ---
    eval $input_cmd | while read -l line
        set -l original_line "$line" 

        set -l current_line (string trim -- "$line")
        set current_line (string replace -r "^\xEF\xBB\xBF" "" -- "$current_line")

        if string match -qr '^#|^$' -- "$current_line"
            continue
        end

        set -l parts (string split -m 1 '=' -- "$current_line")
        set -l key (string trim -- "$parts[1]")

        if not string match -q -r '^[a-zA-Z_][a-zA-Z0-9_]*$' -- "$key"
            echo "Warning: Invalid variable name '$key' (from line: '$original_line') in '$env_file'. Skipping." >&2
            continue
        end

        set -l raw_value_part ""
        if test (count $parts) -gt 1
            set raw_value_part "$parts[2]"
        end

        set -l final_value
        set -l was_quoted false
        set -l trimmed_raw_value_part (string trim -- "$raw_value_part")

        if string match -q -r '^(\"|\').*(\1)$' -- "$trimmed_raw_value_part"
            set final_value (string sub -s 2 -e (math (string length "$trimmed_raw_value_part") - 1) -- "$trimmed_raw_value_part")
            set was_quoted true
        else
            set final_value "$trimmed_raw_value_part"
        end

        if not $was_quoted
            if string match -q -- '*#*' "$final_value"
                set -l value_parts_before_hash (string split -m 1 '#' -- "$final_value")
                set final_value (string trim -- "$value_parts_before_hash[1]")
            end
        end

        set -gx "$key" "$final_value"
        set lines_loaded (math $lines_loaded + 1)
    end

    if test $lines_loaded -gt 0
        echo "Successfully loaded $lines_loaded variable(s) from '$env_file'."
    else
        echo "No variables loaded from '$env_file'."
    end
    return 0
end
