#!/bin/sh
# This script sets the pywal theme.
# If an argument is provided, it uses that as the wallpaper.
# Otherwise, it uses the wallpaper from ~/.fehbg.

if [ -n "$1" ]; then
    wal -i "$1"
else
    # Extract wallpaper path from .fehbg
    wallpaper=$(grep -o "'.*'" /home/mohammed/.fehbg | sed "s/'//g")
    if [ -n "$wallpaper" ]; then
        wal -i "$wallpaper"
    fi
fi

# Reload i3 to apply changes
i3-msg reload