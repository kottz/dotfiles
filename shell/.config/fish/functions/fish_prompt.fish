function fish_prompt --description 'Write out the prompt'
    set -l last_pipestatus $pipestatus
    set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
    set -l normal (set_color normal)

    # Color the prompt differently when we're root
    set -l color_cwd $fish_color_cwd
    set -l suffix '>'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
        end
        set suffix '#'
    end

    # Write pipestatus
    set -l bold_flag --bold
    set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
    if test $__fish_prompt_status_generation = $status_generation
        set bold_flag
    end
    set __fish_prompt_status_generation $status_generation
    set -l status_color (set_color $fish_color_status)
    set -l statusb_color (set_color $bold_flag $fish_color_status)
    set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

    # Append worktree count to vcs prompt when extra worktrees exist.
    # git worktree list always includes the main checkout, so subtract 1.
    set -l vcs (fish_vcs_prompt)
    if test -n "$vcs"
        set -l wt_count (git worktree list 2>/dev/null | count)
        if test $wt_count -gt 1
            set -l wt_extra (math $wt_count - 1)
            # Strip trailing ) and append count before closing paren
            set vcs (string replace -r '\)$' " $wt_extra)" $vcs)
        end
    end

    echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal $vcs $normal " "$prompt_status $suffix " "
end
