function load-env --description "Loads environment variables from a specified .env file (supports .gpg). Use -c to copy content."
    # Parse arguments looking for -c or --copy
    argparse 'c/copy' -- $argv
    or return 1

    if test -z "$argv[1]"
        echo "Usage: load-env [-c|--copy] <path/to/env_file>" >&2
        return 1
    end

    set -l env_file "$argv[1]"

    if not test -f "$env_file"
        echo "Error: Environment file '$env_file' not found." >&2
        return 1
    end

    # --- Copy Mode (-c) ---
    if set -q _flag_copy
        if string match -q '*.gpg' -- "$env_file"
            # Decrypt and copy to clipboard
            if gpg --decrypt --batch --quiet --yes -- "$env_file" | wl-copy
                echo "Decrypted content of '$env_file' copied to clipboard."
                return 0
            else
                echo "Error: GPG decryption failed for '$env_file'." >&2
                return 1
            end
        else
            # Plain text copy
            wl-copy < "$env_file"
            echo "Content of '$env_file' copied to clipboard."
            return 0
        end
    end

    # --- Load Mode (Default) ---
    echo "Loading environment variables from '$env_file'..."
    set -g lines_loaded 0
    set -l lineno 0

    # Denylist of risky variable names (case-insensitive).
    set -l deny_regex '(?i)^(PATH|LD_.*|DYLD_.*|PYTHONPATH|PERL5LIB|RUBYLIB|GEM_HOME|GEM_PATH|NODE_PATH|FISH_FUNCTION_PATH|fish_user_paths|GPG_.*|SSH_AUTH_SOCK|XDG_RUNTIME_DIR)$'

    function __load_env_parse_line --no-scope-shadowing
        set -l line "$argv[1]"
        set -l env_file "$argv[2]"
        set -l lineno "$argv[3]"

        set -l original_line "$line"
        set -l current_line (string trim -- "$line")
        set current_line (string replace -r "^\xEF\xBB\xBF" "" -- "$current_line")
        if string match -qr '^#|^$' -- "$current_line"
            return 0
        end

        set -l parts (string split -m 1 '=' -- "$current_line")
        set -l key (string trim -- "$parts[1]")

        if not string match -q -r '^[a-zA-Z_][a-zA-Z0-9_]*$' -- "$key"
            echo "Warning: invalid variable name on line $lineno in '$env_file' (skipping)." >&2
            return 0
        end

        # denylist check
        if string match -qr "$deny_regex" -- "$key"
            echo "Warning: refusing to set potentially dangerous variable '$key' on line $lineno (skipping)." >&2
            return 0
        end

        set -l raw_value_part ""
        if test (count $parts) -gt 1
            set raw_value_part "$parts[2]"
        end

        set -l trimmed (string trim -- "$raw_value_part")
        set -l was_quoted false
        set -l final_value

        if string match -q -r '^(\"|\').*(\1)$' -- "$trimmed"
            set final_value (string sub -s 2 -e (math (string length "$trimmed") - 1) -- "$trimmed")
            set was_quoted true
        else
            set final_value "$trimmed"
        end

        if not $was_quoted
            if string match -q -- '*#*' "$final_value"
                set -l value_parts_before_hash (string split -m 1 '#' -- "$final_value")
                set final_value (string trim -- "$value_parts_before_hash[1]")
            end
        end

        set -gx -- "$key" "$final_value"
        set -g lines_loaded (math $lines_loaded + 1)
    end

    # --- Plain vs. gpg-decrypted loading ---
    if string match -q '*.gpg' -- "$env_file"
        gpg --decrypt --batch --quiet --yes -- "$env_file" | while read -l line
            set lineno (math $lineno + 1)
            __load_env_parse_line "$line" "$env_file" "$lineno"
        end
        set -l ps $pipestatus
        if test $ps[1] -ne 0
            echo "Error: GPG decryption failed for '$env_file'." >&2
            functions -e __load_env_parse_line
            set -e lines_loaded
            return 1
        end
    else
        while read -l line
            set lineno (math $lineno + 1)
            __load_env_parse_line "$line" "$env_file" "$lineno"
        end < "$env_file"
    end

    functions -e __load_env_parse_line

    set -l __count $lines_loaded
    set -e lines_loaded
    if test $__count -gt 0
        echo "Successfully loaded $__count variable(s) from '$env_file'."
    else
        echo "No variables loaded from '$env_file'."
    end
    return 0
end
