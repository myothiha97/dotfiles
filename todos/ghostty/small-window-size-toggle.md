# Small window size + toggle key

Request (2026-11-24): make the current small Ghostty window size the set size,
and add a key to toggle into that smaller size.

## Facts so far

- Ghostty 1.4.0. Current window is 111 cols x 26 rows (tmux client size).
- Startup size: `window-width = 111` / `window-height = 26` (cells).
- Not verified yet: Ghostty has no "resize to N x M" action. `reset_window_size`
  (macOS) returns to the startup size; the other half of a toggle would be
  `toggle_fullscreen` or a yabai/skhd bind. Check `ghostty +list-actions`.
- Check overlap with the existing skhd window keys
  (`todos/skhd/window-keys-all-apps.md`, Cmd+Shift+U/C, Cmd+Opt+Arrows).

## Status

Done 2026-11-24 by choice on request: default size set to 111x26, centered; Cmd+Shift+U (toggle_maximize) toggles full screen; Cmd+Shift+Y (skhd + yabai/toggle-size.sh) toggles small and medium 160x40.
