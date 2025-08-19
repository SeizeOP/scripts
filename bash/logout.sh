#!/bin/bash
    if pgrep -x "Hyprland" > /dev/null; then
	sleep 1; hyprctl dispatch exit
    elif pgrep -x "niri" > /dev/null; then
	sleep 1; niri msg action quit
    fi
