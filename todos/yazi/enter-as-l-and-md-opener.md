# Enter acts like l, and a macOS app for markdown

Done 2026-10-16, on request (needed for work). Yazi's Enter ran "open", which
sent folders and files to Neovide.

What changed:

- `yazi/keymap.toml`: `<Enter>` runs `enter`, the same as `l` and `ctrl-l`.
  Files open with `o`.
- `yazi/yazi.toml`: a `markdown` opener (`open -a Typora`) is prepended for
  `*.md`, with `edit` as the second choice under `O`.
- Typora is the macOS default for markdown via `duti` (already was).

Typora was chosen for reading: themes, Mermaid diagrams, tables, images and
highlighted code. Obsidian only opens files inside a vault.

Undo: revert both TOML edits and restart yazi.
