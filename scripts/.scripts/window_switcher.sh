#!/usr/bin/env bash

# Collect windows and format: "<id>\t<AppOrClass - Title>"
mapfile -t windows < <(
  swaymsg -t get_tree | jq -r '
    recurse(.nodes[]?, .floating_nodes[]?)
    | select(.type == "con" and .name != null)
    | (
        .id | tostring
      )
      + "\t"
      + (
          .app_id // .window_properties.class // "unknown"
        )
      + " - "
      + .name
  '
)

[ ${#windows[@]} -eq 0 ] && exit 0

# 1. Pass the FULL list to fzf
# 2. -d $'\t' tells fzf to split by tabs
# 3. --with-nth 2.. tells fzf to only display the 2nd field onwards (hiding the ID)
choice=$(printf "%s\n" "${windows[@]}" | \
    fzf --reverse --prompt="Window> " -d $'\t' --with-nth 2..)

# If user cancels, exit
[ -z "$choice" ] && exit 0

# Extract the ID directly from the chosen line (field 1)
id=$(echo "$choice" | cut -f1)

[ -n "$id" ] && swaymsg "[con_id=$id]" focus
