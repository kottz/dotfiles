#!/bin/bash

connected_device=$(bluetoothctl devices Connected)

# If a device is connected, disconnect it and exit
if [ -n "$connected_device" ]; then
    echo "Device connected. Disconnecting..."
    bluetoothctl disconnect
    exit 0
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
device_list=$(bluetoothctl devices)

# Create an associative array to map device names to their MAC addresses
declare -A device_map

# Populate the map
while read -r line; do
    mac=$(echo "$line" | awk '{print $2}')
    name=$(echo "$line" | sed 's/Device [0-9A-Fa-f:]*\s//')
    device_map["$name"]="$mac"
done <<< "$device_list"

# Generate a menu using tofi and get the selected device name
selected_device=$(printf "%s\n" "${!device_map[@]}" | tofi --prompt-text "Connect to:" --font /usr/share/fonts/adobe-source-code-pro/SourceCodePro-Regular.otf --hint-font false)


# Check if a device was selected
if [ -n "$selected_device" ]; then
    # Get the MAC address of the selected device
    selected_mac=${device_map[$selected_device]}

    # Connect to the selected device
    if [ -n "$selected_mac" ]; then
        bluetoothctl connect "$selected_mac"
        #echo "$selected_mac"
    else
        echo "Error: Device not found."
    fi
else
    echo "No device selected."
fi

