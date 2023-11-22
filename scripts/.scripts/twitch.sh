#!/bin/bash

# Argument check
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 USERNAME"
    exit 1
fi

USERNAME=$1

# Resize mpv to take up 80% of screen width
swaymsg resize set width 80 ppt

# Open Chatterino for the channel
exec nohup flatpak run com.chatterino.chatterino -c $USERNAME &

# Open Twitch stream in mpv
exec nohup mpv --hwdec=auto --force-window=immediate "https://twitch.tv/$USERNAME" &

sleep 1
# Resize Chatterino to take up 20% of screen width
#swaymsg resize set width 20 ppt

#swaymsg '[title=mpv$]' resize set width 250px
swaymsg '[title=^Chatterino]' resize set width 350px
# Move Chatterino to the right of mpv
#swaymsg focus left, focus right, move right
swaymsg '[title=mpv$]' move left

exit
