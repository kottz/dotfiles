#!/bin/bash

BT_HISTORY_FILE="$HOME/.local/state/bt_list"

# Create history file if it doesn't exist
touch "$BT_HISTORY_FILE"

# Check for connected devices first
# bluetoothctl devices Connected output is like: "Device XX:XX:XX:XX:XX:XX Device Name"
# We need to ensure we only catch actual device lines that start with "Device " followed by a MAC.
# Filter for lines starting with "Device " to avoid misinterpreting other bluetoothctl output.
connected_device_line=$(bluetoothctl devices Connected | grep "^Device " | head -n 1)

# If a device line was found, attempt to disconnect it
if [ -n "$connected_device_line" ]; then
    connected_mac=$(echo "$connected_device_line" | awk '{print $2}')
    device_name=$(echo "$connected_device_line" | sed 's/Device [0-9A-Fa-f:]*\s//')

    # Additional validation: ensure connected_mac looks like a MAC address (contains colons)
    # and device_name is not empty (which could happen if sed fails unexpectedly)
    if [[ -n "$connected_mac" && "$connected_mac" == *":"* && -n "$device_name" ]]; then
        echo "Device '$device_name' ($connected_mac) connected. Disconnecting..."
        bluetoothctl disconnect "$connected_mac"
        if [ $? -eq 0 ]; then
            echo "Successfully disconnected '$device_name'."
        else
            # The extra output you see ([NEW] Media...) comes from bluetoothctl itself on failure.
            echo "Failed to disconnect '$device_name' ($connected_mac)."
        fi
        exit 0
    else
        # This implies grep "^Device " found a line, but parsing failed to get a valid MAC/Name.
        # This should be a rare edge case if bluetoothctl output is consistent.
        # Log it and proceed as if no device was properly identified for disconnection.
        echo "Warning: A line from 'bluetoothctl devices Connected' matched '^Device ' but could not be parsed correctly: '$connected_device_line'"
        echo "Proceeding to connection menu..."
        # Do not exit; let the script continue to the connection part.
    fi
fi

# Check if Bluetooth is powered on
power_state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}')
# Power on Bluetooth if it's off
if [ "$power_state" != "yes" ]; then
    echo "Bluetooth is off. Turning it on..."
    bluetoothctl power on
    sleep 1  # Wait a bit for the power on command to take effect
fi

# Get list of devices with 'bluetoothctl devices'
# Filter out lines that don't start with "Device " to avoid issues with map population
device_list=$(bluetoothctl devices | grep "^Device ")

# Create an associative array to map device names to their MAC addresses
declare -A device_map
# Populate the map
while IFS= read -r line; do
    if [[ -z "$line" ]]; then # Should be filtered by grep, but good practice
        continue
    fi
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | sed 's/Device [0-9A-Fa-f:]*\s//')
    # Ensure name and mac are not empty and mac looks like a MAC before adding
    if [[ -n "$name" && -n "$mac" && "$mac" == *":"* ]]; then
        device_map["$name"]="$mac"
    else
        echo "Warning: Skipped malformed device line for map: $line"
    fi
done <<< "$device_list"

# Read the history file into an array
if [ -f "$BT_HISTORY_FILE" ]; then
    mapfile -t history < "$BT_HISTORY_FILE"
else
    history=()
fi


# Create a sorted list with history items first
# Start with history items that exist in device_map
sorted_devices=()
seen_in_history=() # To avoid duplicates when adding non-history items

for device_name_hist in "${history[@]}"; do
    # Trim whitespace from history device name just in case
    device_name_hist_trimmed=$(echo "$device_name_hist" | xargs)
    if [[ -n "$device_name_hist_trimmed" && -n "${device_map[$device_name_hist_trimmed]}" ]]; then
        sorted_devices+=("$device_name_hist_trimmed")
        seen_in_history+=("$device_name_hist_trimmed")
    fi
done

# Add remaining devices that aren't in history
for device_name_map in "${!device_map[@]}"; do
    is_seen=0
    for seen_device in "${seen_in_history[@]}"; do
        if [[ "$device_name_map" == "$seen_device" ]]; then
            is_seen=1
            break
        fi
    done
    if [[ $is_seen -eq 0 ]]; then
        sorted_devices+=("$device_name_map")
    fi
done


# Check if sorted_devices is empty
if [ ${#sorted_devices[@]} -eq 0 ]; then
    echo "No Bluetooth devices found or paired to list in menu."
    # Optionally, you might want to trigger a scan here or provide instructions
    # Example: bluetoothctl scan on
    exit 1
fi


# Generate a menu using tofi and get the selected device name
selected_device_name=$(printf "%s\n" "${sorted_devices[@]}" | tofi --prompt-text "Connect to:" --font /usr/share/fonts/adobe-source-code-pro/SourceCodePro-Regular.otf --hint-font false)

# Check if a device was selected
if [ -n "$selected_device_name" ]; then
    # Get the MAC address of the selected device
    selected_mac=${device_map[$selected_device_name]}

    # Connect to the selected device
    if [ -n "$selected_mac" ]; then
        echo "Attempting to connect to '$selected_device_name' ($selected_mac)..."
        bluetoothctl connect "$selected_mac"

        if [ $? -eq 0 ]; then
            echo "Successfully connected to '$selected_device_name'."
            # Update history file
            tmp_history_file=$(mktemp)
            # Create a new history file excluding the currently selected device
            # if BT_HISTORY_FILE exists and is readable, otherwise tmp_history_file will be empty.
            if [ -r "$BT_HISTORY_FILE" ]; then
                grep -Fxv "$selected_device_name" "$BT_HISTORY_FILE" > "$tmp_history_file"
            else
                : > "$tmp_history_file" # Ensure tmp_history_file is empty if original doesn't exist/isn't readable
            fi
            
            # Add the selected device at the beginning of a new temporary file
            echo "$selected_device_name" > "$BT_HISTORY_FILE.new" # Create new or overwrite
            cat "$tmp_history_file" >> "$BT_HISTORY_FILE.new"
            mv "$BT_HISTORY_FILE.new" "$BT_HISTORY_FILE"
            rm "$tmp_history_file"
        else
            echo "Failed to connect to '$selected_device_name' ($selected_mac)."
        fi
    else
        echo "Error: MAC address for '$selected_device_name' not found in device map. This might happen if the device was removed or changed."
    fi
else
    echo "No device selected from menu."
fi
