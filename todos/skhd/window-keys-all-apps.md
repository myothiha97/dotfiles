# Ghostty window keys in every app

Status: done (2026-11-16, skhd + yabai/toggle-fill.sh; overrides app keys by choice)

Idea: make the Ghostty window keys work in all apps, not only Ghostty:
Cmd+Shift+U (toggle fill screen / compact), Cmd+Shift+C (center),
Cmd+Option+Arrows (nudge 20 pt).

Today: Cmd+Shift+U is Ghostty's own `toggle_maximize` (`ghostty/config`).
The others are Ghostty-only skhd rules (`skhd/skhdrc`), other apps get `~`.

Notes for when this is triaged:

- Cmd+Shift+U for other apps needs skhd + yabai (or the macOS Window > Zoom
  menu item). yabai `zoom-fullscreen` only works on managed windows, so a
  floating window needs its own "remember frame, fill, restore" step.
- Conflicts if made global: Cmd+Option+Left/Right switch tabs in Chrome,
  Safari, VS Code; Cmd+Shift+C is Inspect in Chrome and "Computer" in Finder;
  Cmd+Shift+U is Utilities in Finder. Each needs an app exclusion or a
  different key.
- Every press would fork a shell/yabai call; fine for keys pressed by hand,
  not a hot path.
