if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_greeting
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

# pnpm
set -gx PNPM_HOME $HOME/.local/share/pnpm
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# application env
set -gx EDITOR nvim

function cloc_git
    if test (count $argv) -eq 0
        echo "Usage: count_lines_in_repo <repository-url>"
        return 1
    end

    set repo_url $argv[1]
    set temp_dir /tmp/temp-linecount-repo

    git clone --depth 1 $repo_url $temp_dir
    cloc $temp_dir
    rm -rf $temp_dir
end

# Fuzzy find a folder, if there is a tmux session in folder, attach to it,
# otherwise create a new session with the folder as the working directory
function fzf_cd_tmux
    set selected_dir (fd --max-depth 2 --type directory --full-path . $HOME | fzf)

    if test -n "$selected_dir"
        set session_name (basename "$selected_dir")

        if tmux has-session -t $session_name 2>/dev/null
            tmux attach -t $session_name
        else
            tmux new-session -s $session_name -c "$selected_dir"
        end
    end
end

# Custom Shortcuts
bind \co fzf_cd_tmux 

function subs
    if set -q argv[1]
        yt-dlp --write-auto-subs --convert-subs srt --sub-format txt --skip-download $argv
    else
        echo "Error: No argument provided. Please specify a URL."
    end
end

# Aliases
alias ipi="curl ipinfo.io"
alias b="acpi -b"
alias screenshot="~/.scripts/screenshot.sh"
alias screenshot_region="~/.scripts/screenshot_region.sh"
alias ltu="cd ~/Documents/ltu"
alias vs='source .venv/bin/activate.fish'
alias clearpac='pacman -Rns $(pacman -Qtdq)'
alias cz='cd && cd "$(dirname "$(fzf)")"'
alias t='cd $(cat ~/.config/cur_dir)'
alias ts='pwd > ~/.config/cur_dir'
alias l='ls -lah'
alias tl='tmux list-sessions'

#this should be at the end of the file
zoxide init fish | source
