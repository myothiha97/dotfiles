# Neovide and Obsidian focus keys

Status: done (2026-11-20, skhd; made by choice on request)

Idea: Cmd+Ctrl+N focuses Neovide, and Obsidian moves to Cmd+Ctrl+, (comma).

Before: Cmd+Ctrl+N was Obsidian, and Cmd+Ctrl+, was Preview (`0x2B` is the
comma key code). Neovide had no focus key.

Decisions:

- Preview has no focus key now, by choice. Comma went to Obsidian.
- The comma stays `0x2B` (skhd needs the key code), with a comment saying so,
  since the key code hid the Preview conflict.
- yabai reports Neovide's app name as `Neovide`, which `focus-app.sh` matches.
- Each press forks one shell + yabai call, the same as the other focus keys.
  Pressed by hand, not a hot path.
