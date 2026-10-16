# Syntax-highlighted diffs in lazygit

Done 2026-10-16, by choice on request (not blocking work). Lazygit diffs were
plain text.

What changed: the `pagers` block in `lazygit/config.yml` runs delta 0.19.2
with theme `TwoDark` and GitHub dark add/remove backgrounds. All flags are
explained in the comment there.

- Text is line-for-line identical to plain `git diff` (checked by stripping
  colours, on a 35-line and a 4,086-line diff). Tabs are kept (`--tabs=0`),
  so indentation looks as before.
- Cost: ~30 ms per normal diff, ~140 ms for 4k lines. No effect on nvim.
- The 2026-06-29 "unstable" cause is still unknown. `--dark` skips delta's
  terminal colour query, the most likely suspect. If it breaks again, note
  what was on screen here before disabling.
- Not done: a real GitHub Dark theme. It needs `bat`, a third-party
  `.tmTheme`, and a bat cache that matches delta's bundled bat, or delta
  silently falls back.

Undo: delete the `pagers` block.
