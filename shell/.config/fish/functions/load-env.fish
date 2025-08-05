function load-env --description "Loads environment variables from a specified .env file"
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

    # --- Line-by-Line Processing ---
    while read -l line # -l is crucial for `read` to process lines correctly
        set -l original_line "$line" # Keep for more informative error messages

        # 1. Trim leading/trailing whitespace from the raw line
        set -l current_line (string trim -- "$line")

        # 2. Attempt to remove UTF-8 BOM (ï»¿) if present at the beginning of the trimmed line.
        #    BOM should ideally only be at the very start of a file, but this handles it robustly
        #    if it somehow appears at the start of a processed line segment.
        #    \xEF\xBB\xBF is the byte sequence for UTF-8 BOM.
        set current_line (string replace -r "^\xEF\xBB\xBF" "" -- "$current_line")

        # 3. Skip if the line (after trimming and BOM removal) is effectively empty or a comment.
        #    -qr: quiet, regex. '^#': starts with '#'. '^$': empty line.
        if string match -qr '^#|^$' -- "$current_line"
            continue
        end

        # --- Key-Value Parsing ---
        # At this point, the line is considered to have content and is not a full comment.
        set -l parts (string split -m 1 '=' -- "$current_line")

        # Extract and validate the key
        set -l key (string trim -- "$parts[1]") # parts[1] will exist due to prior checks

        # Basic variable name validation (also catches empty keys from lines like "=value")
        if not string match -q -r '^[a-zA-Z_][a-zA-Z0-9_]*$' -- "$key"
            echo "Warning: Invalid variable name '$key' (from line: '$original_line') in '$env_file'. Skipping." >&2
            continue
        end

        # Extract and process the value
        set -l raw_value_part "" # This is the string segment after the first '='
        if test (count $parts) -gt 1
            # Only assign if there was an '=' resulting in a second part
            set raw_value_part "$parts[2]" # Do not trim yet; preserve leading/trailing for quote check
        end

        set -l final_value
        set -l was_quoted false

        # Trim the raw_value_part for quote checking and for unquoted value processing
        set -l trimmed_raw_value_part (string trim -- "$raw_value_part")

        # Check for and strip surrounding quotes (handles "value" and 'value')
        if string match -q -r '^(\"|\').*(\1)$' -- "$trimmed_raw_value_part"
            # Value was quoted, extract content between quotes
            set final_value (string sub -s 2 -e (math (string length "$trimmed_raw_value_part") - 1) -- "$trimmed_raw_value_part")
            set was_quoted true
        else
            # Value was not quoted
            set final_value "$trimmed_raw_value_part"
        end

        # If the value was NOT originally quoted, then strip inline comments.
        # An inline comment is a '#' not at the beginning of the line value.
        if not $was_quoted
            # Check if '#' exists in the final_value (compatible with older Fish versions)
            # string match -q -- '*#*' "$final_value" checks if '#' is present anywhere.
            if string match -q -- '*#*' "$final_value"
                # Get the part before the first '#'. string split will create a list.
                set -l value_parts_before_hash (string split -m 1 '#' -- "$final_value")
                # The first element is the part before the delimiter. Trim any trailing space.
                set final_value (string trim -- "$value_parts_before_hash[1]")
            end
        end
        
        # Set the environment variable globally and export it
        set -gx "$key" "$final_value"
        set lines_loaded (math $lines_loaded + 1)
    end < "$env_file" # Read directly from the specified file

    # --- Final Status Message ---
    if test $lines_loaded -gt 0
        echo "Successfully loaded $lines_loaded variable(s) from '$env_file'."
    else
        echo "No variables loaded from '$env_file' (it might be empty, only contain comments, or all lines were malformed/skipped)."
    end
    return 0
end

# To make this function available in new shell sessions, save it to a file
# in your Fish configuration directory, for example:
# ~/.config/fish/functions/load-env.fish
#
# Then, you can add autocompletion (optional but nice):
# complete -c load-env -f -r -a "(__fish_complete_path)" -d "Path to .env file"
