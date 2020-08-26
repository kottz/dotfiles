#!/bin/bash

#Prevents volume from being raised above 100%
x=$(pacmd list-sinks | awk '/volume: front-left/{print $5}' | tr -d % | head -1)
if [[ $x -lt 100 ]]
then
pactl set-sink-volume $(pacmd list-sinks |awk '/* index:/{print $3}') +5%
fi
