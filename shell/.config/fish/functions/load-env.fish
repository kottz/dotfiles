function load-env --description "Loads environment variables from a specified .env file. Supports .gpg (auto-decrypt), -c to copy to clipboard, and -e to edit securely."
    # 1. Parse Arguments
    argparse 'c/copy' 'e/edit' -- $argv
    or return 1

    if test -z "$argv[1]"
        echo "Usage: load-env [-c|--copy] [-e|--edit] <path/to/env_file>" >&2
        return 1
    end

    set -l env_file "$argv[1]"

    if not test -f "$env_file"
        echo "Error: Environment file '$env_file' not found." >&2
        return 1
    end

    #
    # --- EDIT MODE (-e) ---
    #
    if set -q _flag_edit
        if not string match -q '*.gpg' -- "$env_file"
            echo "Error: Edit mode only supports .gpg files." >&2
            return 1
        end

        # SECURITY: Use XDG_RUNTIME_DIR (RAM disk) if available, else /tmp
        set -l tmp_dir "$XDG_RUNTIME_DIR"
        if test -z "$tmp_dir"
            set tmp_dir "/tmp"
        end

        # Create secure temp files (plain text, backup for comparison, encrypted output)
        set -l tmp_plain (mktemp -p "$tmp_dir")
        set -l tmp_backup (mktemp -p "$tmp_dir")
        set -l tmp_enc (mktemp -p "$tmp_dir")
        
        # TRAP: Ensure secure cleanup on Exit, Interrupt (Ctrl+C), or Terminate
        # We capture the temp paths into the closure
        function __load_env_cleanup --inherit-variable tmp_plain --inherit-variable tmp_enc --inherit-variable tmp_backup
            if command -v shred >/dev/null
                # Overwrite data before deleting
                shred -u "$tmp_plain" "$tmp_backup" "$tmp_enc" 2>/dev/null
            else
                rm -f "$tmp_plain" "$tmp_backup" "$tmp_enc"
            end
        end
        trap __load_env_cleanup EXIT INT TERM

        # Decrypt
        if not gpg --decrypt --batch --quiet --yes --output "$tmp_plain" -- "$env_file"
            echo "Error: GPG decryption failed." >&2
            return 1
        end

        # Create a snapshot to compare against later
        cp "$tmp_plain" "$tmp_backup"

        # Detect Recipient: Try to find 'issuer fpr' (signed), fallback to 'keyid' (encrypted)
        set -l recipient (gpg --list-packets "$env_file" | string match -r 'issuer fpr v4 ([0-9A-F]+)' | string split " " -f 4 | head -n1)
        if test -z "$recipient"
             set recipient (gpg --list-packets "$env_file" | string match -r 'keyid ([0-9A-F]+)' | string split " " -f 2 | head -n1)
        end

        if test -z "$recipient"
            echo "Error: Could not detect a GPG key/fingerprint to re-encrypt to." >&2
            return 1
        end

        # SELECT EDITOR & HARDEN FLAGS
        # We try to disable swap files, backup files, and undo files to keep secrets off the physical disk.
        set -l editor_cmd
        if test -n "$EDITOR"
            set editor_cmd $EDITOR
        else
            if command -v vim >/dev/null; set editor_cmd vim
            else if command -v nano >/dev/null; set editor_cmd nano
            else; set editor_cmd vi
            end
        end

        set -l final_cmd $editor_cmd
        switch $editor_cmd
            case '*vim' '*vi' '*nvim'
                # -n: No swap file. -c: Vimscript commands to disable persistent undo/backups
                set final_cmd $editor_cmd -n -c 'set nobackup nowritebackup noswapfile noundofile'
            case '*nano'
                set final_cmd $editor_cmd --nobackup
        end

        # Run the editor
        $final_cmd "$tmp_plain"
        if test $status -ne 0
            echo "Editor exited with error. Changes discarded." >&2
            return 1
        end

        # COMPARE: Did the content actually change?
        if cmp -s "$tmp_plain" "$tmp_backup"
            echo "No changes detected. File not updated."
            return 0
        end

        echo "Content changed. Re-encrypting for recipient: $recipient ..."
        
        # Re-encrypt and Sign
        if gpg --encrypt --sign --recipient "$recipient" --output "$tmp_enc" --yes "$tmp_plain"
            mv -f "$tmp_enc" "$env_file"
            echo "Successfully updated '$env_file'."
        else
            echo "Error: Re-encryption failed. Changes discarded." >&2
            return 1
        end
        return 0
    end

    #
    # --- COPY MODE (-c) ---
    #
    if set -q _flag_copy
        if string match -q '*.gpg' -- "$env_file"
            if gpg --decrypt --batch --quiet --yes -- "$env_file" | wl-copy
                echo "Decrypted content of '$env_file' copied to clipboard."
                return 0
            else
                echo "Error: GPG decryption failed." >&2
                return 1
            end
        else
            wl-copy < "$env_file"
            echo "Content of '$env_file' copied to clipboard."
            return 0
        end
    end

    #
    # --- LOAD MODE (Default) ---
    #
    echo "Loading environment variables from '$env_file'..."
    set -g lines_loaded 0
    set -l lineno 0
    
    # Security: refuse to overwrite system critical paths
    set -l deny_regex '(?i)^(PATH|LD_.*|DYLD_.*|PYTHONPATH|PERL5LIB|RUBYLIB|GEM_HOME|GEM_PATH|NODE_PATH|FISH_FUNCTION_PATH|fish_user_paths|GPG_.*|SSH_AUTH_SOCK|XDG_RUNTIME_DIR)$'

    # Helper function to parse a single line
    function __load_env_parse_line --no-scope-shadowing
        set -l line "$argv[1]"
        set -l env_file "$argv[2]"
        set -l lineno "$argv[3]"

        set -l current_line (string trim -- "$line")
        # Remove UTF-8 BOM if present
        set current_line (string replace -r "^\xEF\xBB\xBF" "" -- "$current_line")

        # Skip comments and empty lines
        if string match -qr '^#|^$' -- "$current_line"
            return 0
        end

        set -l parts (string split -m 1 '=' -- "$current_line")
        set -l key (string trim -- "$parts[1]")

        # Validate Key Name
        if not string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- "$key"
            echo "Warning: invalid variable name on line $lineno in '$env_file' (skipping)." >&2
            return 0
        end

        # Validate against Denylist
        if string match -qr "$deny_regex" -- "$key"
            echo "Warning: refusing to set dangerous variable '$key' on line $lineno (skipping)." >&2
            return 0
        end

        # Parse Value
        set -l raw_val ""
        test (count $parts) -gt 1; and set raw_val "$parts[2]"
        set -l trimmed (string trim -- "$raw_val")
        set -l final_value "$trimmed"
        set -l was_quoted false

        # Handle quotes ("value" or 'value')
        if string match -qr '^(\"|\').*(\1)$' -- "$trimmed"
            set final_value (string sub -s 2 -e (math (string length "$trimmed") - 1) -- "$trimmed")
            set was_quoted true
        end

        # Remove inline comments (#) only if value was not quoted
        if not $was_quoted
            if string match -q -- '*#*' "$final_value"
                set -l split_val (string split -m 1 '#' -- "$final_value")
                set final_value (string trim -- "$split_val[1]")
            end
        end

        # Export the variable
        set -gx -- "$key" "$final_value"
        set -g lines_loaded (math $lines_loaded + 1)
    end

    # Ensure parser is removed on exit
    function __load_env_teardown --on-event fish_exit
        functions -e __load_env_parse_line
    end

    # Process file (GPG or Plain)
    if string match -q '*.gpg' -- "$env_file"
        gpg --decrypt --batch --quiet --yes -- "$env_file" | while read -l line
            set lineno (math $lineno + 1)
            __load_env_parse_line "$line" "$env_file" "$lineno"
        end
        if test $pipestatus[1] -ne 0
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

    # Cleanup and Report
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
