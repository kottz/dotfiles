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

# Show only the second column (human-readable)
choice=$(printf "%s\n" "${windows[@]#*$'\t'}" | \
    fzf --prompt="Window> ")

# Find the matching ID
id=$(printf "%s\n" "${windows[@]}" | \
    grep -F "$choice" | \
    cut -f1)

[ -n "$id" ] && swaymsg "[con_id=$id]" focus
