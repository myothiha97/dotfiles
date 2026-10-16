# Disable the zsh autocompletion listing

Done 2026-10-13, by choice on request (not blocking work). The reason was
typing performance: zsh-autocomplete ran the completion system on every
keystroke.

What changed:

- `brew uninstall zsh-autocomplete`
- `zshrc`: its zstyle block and `source` line are gone, replaced by one
  `compinit -i -C` call, so Tab completion for git, brew and others stays.
- `zsh-autosuggestions` (ghost text) is untouched.

Undo: `brew install zsh-autocomplete`, restore the old block from git, and
remove the `compinit` line. Startup time unchanged (~0.05s).
