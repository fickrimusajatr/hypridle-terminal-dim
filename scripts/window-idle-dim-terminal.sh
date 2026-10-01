#!/bin/bash
# hypridle-terminal-dim
# Dim terminal windows after user idle timeout in Hyprland.
# Requirements: hypridle, hyprctl, swayosd-client (optional)

DIM_VALUE="${WINDOW_IDLE_OPACITY:-0.3}"
DIM_PCT="${WINDOW_IDLE_OPACITY_PCT:-30}"

# Terminal window class names to match
TERMINAL_CLASSES="kitty|foot|alacritty|wezterm|urxvt|xterm|st|terminator|gnome-terminal"

# Get active window class from Hyprland JSON
ACTIVE_JSON=$(hyprctl activewindow -j 2>/dev/null)

if command -v jq &> /dev/null; then
    ACTIVE_CLASS=$(echo "$ACTIVE_JSON" | jq -r '.class' 2>/dev/null)
else
    # Fallback sed parser for systems without jq
    ACTIVE_CLASS=$(echo "$ACTIVE_JSON" | sed -n 's/.*"class"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

# Only dim if active window is a terminal
if [ -n "$ACTIVE_CLASS" ] && echo "$ACTIVE_CLASS" | grep -qiE "^($TERMINAL_CLASSES)$"; then
    hyprctl eval "local w=hl.get_active_window() if w then hl.dispatch(hl.dsp.window.set_prop({prop=\"opacity\", value=$DIM_VALUE, window=w})) end" 2>/dev/null

    # SwayOSD on-screen display
    if command -v swayosd-client &> /dev/null; then
        swayosd-client \
            --custom-message "Terminal idle" \
            --custom-icon "utilities-terminal-symbolic" \
            --custom-progress "$(echo "scale=2; $DIM_PCT / 100" | bc)" 2>/dev/null
    fi
fi
