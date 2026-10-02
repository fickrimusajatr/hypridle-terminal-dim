# hypridle-dim

Auto‑dim windows after an idle timeout in Hyprland, with three modes: **Off**, **Terminal‑only**, **Global**.

When you stop using your computer for N seconds, the active window dims (opacity drop + SwayOSD popup). Touching the keyboard/mouse restores it.

## Requirements

- [Hyprland](https://hyprland.org/)
- [hypridle](https://wiki.hypr.land/Hypr-Ecosystem/hypridle/) (idle daemon)
- `swayosd-client` (optional, for the on‑screen popup)
- `jq` (optional, for JSON parsing — falls back to `sed`)

## Install

```bash
# 1. Copy scripts
mkdir -p ~/.local/bin
cp scripts/window-idle-dim.sh ~/.local/bin/
cp scripts/window-idle-restore.sh ~/.local/bin/
cp scripts/window-idle-switch-mode.sh ~/.local/bin/
chmod +x ~/.local/bin/window-idle-*.sh

# 2. Add the listener to your hypridle config
cat config/hypridle.conf.example >> ~/.config/hypr/hypridle.conf

# 3. Restart hypridle
killall hypridle; hypridle &
```

## Keybind

Add this to your Hyprland config (`~/hakucfg/wm/hyprland‑custom.lua` or equivalent):

```lua
hl.bind("SUPER + F3", hl.dsp.exec_cmd("~/.local/bin/window-idle-switch-mode.sh"))
```

Press `SUPER + F3` to cycle through the three modes; a SwayOSD popup shows the new mode.

## Modes

| Mode | Behaviour |
|---|---|
| **Off** | No dimming occurs. |
| **Terminal‑only** | Only terminal windows (kitty, foot, alacritty, wezterm, urxvt, xterm, st, terminator, gnome‑terminal) dim after idle. |
| **Global** | Any active window dims after idle. |

The current mode is stored in `~/.local/state/hypridle‑dim/mode` and persists across restarts.

## Configuration

| Env var | Default | Meaning |
| --- | --- | --- |
| `WINDOW_IDLE_OPACITY` | `0.3` | Opacity while idle (0.0–1.0) |
| `WINDOW_IDLE_OPACITY_PCT` | `30` | Percentage shown in SwayOSD |

Change the idle timeout by editing `timeout = 5` (seconds) in the listener.

Change which terminals are dimmed by editing `TERMINAL_CLASSES` in `window‑idle‑dim.sh`. Default: `kitty|foot|alacritty|wezterm|urxvt|xterm|st|terminator|gnome‑terminal`.

## How it works

1. `hypridle` fires `on‑timeout` after N seconds without input.
2. `window‑idle‑dim.sh` reads the current mode from `~/.local/state/hypridle‑dim/mode`.
3. If the mode is **Off**, nothing happens.
4. If the mode is **Terminal‑only**, the script checks the active window’s class; only terminals are dimmed.
5. If the mode is **Global**, the active window (any class) is dimmed.
6. Opacity is set per‑window via `hyprctl eval` + `hl.dsp.window.set_prop`.
7. `swayosd‑client` shows a text‑only popup (“Terminal idle”, “Window idle”, etc.).
8. `on‑resume` fires on the next input and calls `window‑idle‑restore.sh` (always restores opacity to 1.0).

Zero background overhead: nothing runs until hypridle triggers it.

## References

These projects and documentation informed the design of `hypridle‑dim`:

- **[hyprwm/hypridle](https://github.com/hyprwm/hypridle)** — official idle daemon for Hyprland; provides `on‑timeout` and `on‑resume` events that this project hooks into.
- **[Hyprland Wiki](https://wiki.hypr.land/)** — documentation on Lua IPC (`hyprctl eval`) and per‑window opacity via `hl.dsp.window.set_prop`.
- **[donovanglover/hyprdim](https://github.com/donovanglover/hyprdim)** — existing dim tool that inspired the “windows can be dimmed” concept, though this project dims based on idle *time* rather than focus *switches*.
- **[ErikReider/SwayOSD](https://github.com/ErikReider/swayosd)** — on‑screen display client used for the “Terminal idle” and “Window idle” popups.

## License

MIT
