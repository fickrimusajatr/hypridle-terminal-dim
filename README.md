# hypridle-terminal-dim

Auto-dim terminal windows after an idle timeout in Hyprland.

When you stop using your computer for N seconds, the active terminal window
dims (opacity drop + SwayOSD popup). Touching the keyboard/mouse restores it.
Non-terminal windows are left alone.

## Requirements

- [Hyprland](https://hyprland.org/)
- [hypridle](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/) (idle daemon)
- `swayosd-client` (optional, for the on-screen popup)
- `jq` (optional, for JSON parsing — falls back to `sed`)

## Install

```bash
# 1. Copy scripts
mkdir -p ~/.local/bin
cp scripts/window-idle-dim-terminal.sh ~/.local/bin/
cp scripts/window-idle-restore-terminal.sh ~/.local/bin/
chmod +x ~/.local/bin/window-idle-*-terminal.sh

# 2. Add the listener to your hypridle config
cat config/hypridle.conf.example >> ~/.config/hypr/hypridle.conf

# 3. Restart hypridle
killall hypridle; hypridle &
```

## Configuration

| Env var | Default | Meaning |
|---|---|---|
| `WINDOW_IDLE_OPACITY` | `0.3` | Opacity while idle (0.0–1.0) |
| `WINDOW_IDLE_OPACITY_PCT` | `30` | Percentage shown in SwayOSD |

Change the idle timeout by editing `timeout = 5` (seconds) in the listener.

Change which terminals are dimmed by editing `TERMINAL_CLASSES` in both
scripts. Default: `kitty|foot|alacritty|wezterm|urxvt|xterm|st|terminator|gnome-terminal`.

## How it works

1. `hypridle` fires `on-timeout` after N seconds without input.
2. The script checks the active window class — only terminals match.
3. Opacity is set per-window via `hyprctl eval` + `hl.dsp.window.set_prop`.
4. `swayosd-client` shows a text-only popup.
5. `on-resume` fires on the next input and restores opacity to 1.0.

Zero background overhead: nothing runs until hypridle triggers it.

## License

MIT
