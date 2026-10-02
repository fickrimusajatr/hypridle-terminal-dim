#!/bin/bash
# hypridle-restore: restore active window opacity to 1.0
# Called by hypridle on-resume

# Restore regardless of mode (user activity always restores visibility)
hyprctl eval 'local w=hl.get_active_window() if w then hl.dispatch(hl.dsp.window.set_prop({prop="opacity", value=1.0, window=w})) end' 2>/dev/null

# SwayOSD popup (text only)
if command -v swayosd-client &> /dev/null; then
    swayosd-client \
        --custom-message "Window active" \
        --custom-icon "view-restore-symbolic" \
        --custom-progress 1.0 2>/dev/null
fi