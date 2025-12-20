#!/bin/bash

BT_HISTORY_FILE="$HOME/.local/state/bt_list"

# Ensure history file exists
mkdir -p "$(dirname "$BT_HISTORY_FILE")"
touch "$BT_HISTORY_FILE"

# --- DISCONNECT LOGIC ---

# Find the first "connected" device from bluetoothctl^
connected_device_line=$(bluetoothctl devices Connected | sed 's/\x1b\[[0-9;]*m//g' | grep "^Device " | head -n 1)

if [ -n "$connected_device_line" ]; then
    connected_mac=$(echo "$connected_device_line" | awk '{print $2}')
    device_name=$(echo "$connected_device_line" | sed 's/Device [0-9A-Fa-f:]*\s//')

    if [[ -n "$connected_mac" && "$connected_mac" == *":"* && -n "$device_name" ]]; then
        # Confirm actual connection state (avoid ghost devices)
        if bluetoothctl info "$connected_mac" | grep -q "Connected: yes"; then
            echo "Device '$device_name' ($connected_mac) connected. Disconnecting..."
            bluetoothctl disconnect "$connected_mac" >/dev/null
            echo "Disconnected '$device_name'."
            exit 0
        fi
    fi
fi

# --- CONNECT LOGIC ---

# Ensure Bluetooth is powered on
power_state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
if [ "$power_state" != "yes" ]; then
    echo "Bluetooth is off. Turning it on..."
    bluetoothctl power on
    sleep 1
fi

# Get list of known devices
device_list=$(bluetoothctl devices | sed 's/\x1b\[[0-9;]*m//g' | grep "^Device ")

declare -A device_map
while IFS= read -r line; do
    [ -z "$line" ] && continue
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | sed 's/Device [0-9A-Fa-f:]*\s//')
    if [[ -n "$name" && -n "$mac" && "$mac" == *":"* ]]; then
        device_map["$name"]="$mac"
    fi
done <<< "$device_list"

# Read history
mapfile -t history < "$BT_HISTORY_FILE" 2>/dev/null || history=()

# Sort devices: history first, then the rest
sorted_devices=()
seen_in_history=()

for device_name_hist in "${history[@]}"; do
    device_name_hist_trimmed=$(echo "$device_name_hist" | xargs)
    if [[ -n "$device_name_hist_trimmed" && -n "${device_map[$device_name_hist_trimmed]}" ]]; then
        sorted_devices+=("$device_name_hist_trimmed")
        seen_in_history+=("$device_name_hist_trimmed")
    fi
done

for device_name_map in "${!device_map[@]}"; do
    skip=0
    for seen_device in "${seen_in_history[@]}"; do
        if [[ "$device_name_map" == "$seen_device" ]]; then
            skip=1
            break
        fi
    done
    [[ $skip -eq 0 ]] && sorted_devices+=("$device_name_map")
done

if [ ${#sorted_devices[@]} -eq 0 ]; then
    echo "No Bluetooth devices found."
    exit 1
fi

# --- MENU & CONNECTION ---

selected_device_name=$(printf "%s\n" "${sorted_devices[@]}" | \
    tofi --prompt-text "Connect to:" \
         --font /usr/share/fonts/adobe-source-code-pro/SourceCodePro-Regular.otf \
         --hint-font false)

if [ -n "$selected_device_name" ]; then
    selected_mac=${device_map[$selected_device_name]}
    if [ -n "$selected_mac" ]; then
        echo "Attempting to connect to '$selected_device_name' ($selected_mac)..."
        bluetoothctl connect "$selected_mac" >/dev/null && echo "Connected to '$selected_device_name'."

        # Update history: move this device to the top
        tmp_history_file=$(mktemp)
        grep -Fxv "$selected_device_name" "$BT_HISTORY_FILE" 2>/dev/null > "$tmp_history_file"
        {
            echo "$selected_device_name"
            cat "$tmp_history_file"
        } > "$BT_HISTORY_FILE.new"
        mv "$BT_HISTORY_FILE.new" "$BT_HISTORY_FILE"
        rm "$tmp_history_file"
    else
        echo "Error: MAC not found for '$selected_device_name'."
    fi
else
    echo "No device selected."
fi
