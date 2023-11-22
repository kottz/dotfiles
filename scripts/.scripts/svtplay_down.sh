#!/bin/bash

# Check if at least one link is provided
if [ "$#" -eq 0 ]; then
    echo "No links provided. Usage: ./svtplay_down.sh link1 link2 link3 ..."
    exit 1
fi

# Read the token from the file 'tv4play_token'
if [ -f tv4play_token ]; then
    TOKEN=$(cat tv4play_token)
else
    echo "Token file 'tv4play_token' not found."
    exit 1
fi

# Loop through all provided links
for link in "$@"; do
    # Run svtplay-dl command in the background for each link
    svtplay-dl --token "$TOKEN" "$link" &
done

# Wait for all background jobs to complete
wait

