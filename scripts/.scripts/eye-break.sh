#!/bin/bash
# Simple eye-break overlay using swaybg

COLOR="#ff0080"  # semi-transparent red (RGBA)
DURATION=20        # seconds

# Start overlay
swaybg -c "$COLOR" &
PID=$!

# Keep it visible for the duration
sleep "$DURATION"

# Remove overlay
kill "$PID"
