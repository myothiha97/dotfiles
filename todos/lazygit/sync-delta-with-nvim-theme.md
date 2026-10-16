# Make lazygit diff colours match the nvim theme

Requested 2026-10-16, for later. Lazygit diffs use delta's built-in `TwoDark`
(see `delta-nvim-theme.md`), not nvim's solarized-osaka build.

Idea: generate a `.tmTheme` from nvim's live palette (`custom-latest` in
`~/.config/nvim/lua/colorschemes/solarized-osaka/variants.lua`) and point
delta's `--syntax-theme` at it.

Known before starting:

- Needs `bat` installed and `bat cache --build`. The bat version must match
  the bat library inside delta, or delta silently falls back to its default.
  Check that the theme really loads, not just that nothing errors.
- Only an approximate match is possible: delta uses TextMate scopes, nvim uses
  treesitter groups. Language-scoped rules (Go fields, teal `#73daca` via
  `override_go` in `init.lua`) cannot carry over.
- Generate it from the palette, not by copying hexes, or it drifts the next
  time the nvim palette changes.
