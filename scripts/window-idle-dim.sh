#!/bin/bash
# hypridle-dim: dim active window after idle (respects current mode)

DIM_VALUE="${WINDOW_IDLE_OPACITY:-0.3}"
DIM_PCT="${WINDOW_IDLE_OPACITY_PCT:-30}"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypridle-dim"
STATE_FILE="$STATE_DIR/mode"
MODE=$(cat "$STATE_FILE" 2>/dev/null || echo "off")

TERMINAL_CLASSES="kitty|foot|alacritty|wezterm|urxvt|xterm|st|terminator|gnome-terminal"

# Parse active window class
ACTIVE_JSON=$(hyprctl activewindow -j 2>/dev/null)
if command -v jq &> /dev/null; then
    ACTIVE_CLASS=$(echo "$ACTIVE_JSON" | jq -r '.class' 2>/dev/null)
else
    ACTIVE_CLASS=$(echo "$ACTIVE_JSON" | sed -n 's/.*"class"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)
fi

should_dim=0
case "$MODE" in
    off) ;;
    terminal)
        if [ -n "$ACTIVE_CLASS" ] && echo "$ACTIVE_CLASS" | grep -qiE "^($TERMINAL_CLASSES)$"; then
            should_dim=1
            LABEL="Terminal idle"
            ICON="utilities-terminal-symbolic"
        fi
        ;;
    global)
        should_dim=1
        LABEL="Window idle"
        ICON="preferences-desktop-screensaver-symbolic"
        ;;
esac

if [ "$should_dim" -eq 1 ]; then
    hyprctl eval "local w=hl.get_active_window() if w then hl.dispatch(hl.dsp.window.set_prop({prop=\"opacity\", value=$DIM_VALUE, window=w})) end" 2>/dev/null

    # Text-only notification
    if command -v notify-send &> /dev/null; then
        notify-send -t 1000 "$LABEL" -h string:x-dunst-stack-tag:hypridle-dim 2>/dev/null
    fi
fi
