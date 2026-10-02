#!/bin/bash
# hypridle-dim: cycle between Off / Terminal / Global dim modes
# Keybind this script to switch modes (shows status via SwayOSD)

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/hypridle-dim"
STATE_FILE="$STATE_DIR/mode"
mkdir -p "$STATE_DIR"

# Cycle: off → terminal → global → off → ...
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "off")
case "$CURRENT" in
    off)       NEXT="terminal" ;;
    terminal)  NEXT="global" ;;
    global)    NEXT="off" ;;
    *)         NEXT="off" ;;
esac

echo "$NEXT" > "$STATE_FILE"

# Show mode change on SwayOSD
case "$NEXT" in
    off)      LABEL="Idle dim OFF" ;;
    terminal) LABEL="Idle dim: TERMINAL" ;;
    global)   LABEL="Idle dim: GLOBAL" ;;
esac

if command -v swayosd-client &> /dev/null; then
    swayosd-client \
        --custom-message "$LABEL" \
        --custom-icon "preferences-system-screensaver-symbolic" \
        --custom-progress 1.0 2>/dev/null
fi
