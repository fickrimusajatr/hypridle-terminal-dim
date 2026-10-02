#!/bin/bash
# hypridle-restore: restore active window opacity to 1.0
# Called by hypridle on-resume

# Restore regardless of mode (user activity always restores visibility)
hyprctl eval 'local w=hl.get_active_window() if w then hl.dispatch(hl.dsp.window.set_prop({prop="opacity", value=1.0, window=w})) end' 2>/dev/null

# Text-only notification
if command -v notify-send &> /dev/null; then
    notify-send -t 1000 "Window active" -h string:x-dunst-stack-tag:hypridle-dim 2>/dev/null
fi