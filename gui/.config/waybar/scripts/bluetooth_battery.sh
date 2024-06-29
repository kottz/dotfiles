#!/bin/bash

# Function to output JSON-formatted messages
output_json() {
    local text="$1"
    local class="$2"
    echo "{\"text\": \"$text\", \"class\": \"$class\"}"
}

# Find the first Bluetooth device
bluetooth_device=$(upower -e | grep -m 1 -E 'bluez_device|headset')

if [ -z "$bluetooth_device" ]; then
    output_json "No BT" "disconnected"
    exit 0
fi

# Get the device info and extract the battery percentage
device_info=$(upower -i "$bluetooth_device")
percentage=$(echo "$device_info" | grep percentage | awk '{print $2}')

if [ -z "$percentage" ]; then
    output_json "N/A" "no-battery"
else
    output_json "$percentage" "has-battery"
fi
