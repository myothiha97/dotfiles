# delta as git's pager in the shell

Logged 2026-10-16. Deferred: diffs are read in lazygit (already on delta) and
nvim, so plain `git diff` in the shell is rarely used. Revisit only if reading
`git diff` / `git log -p` in the shell becomes a weekly habit.

Minimal config, matching lazygit:

```ini
[core]
    pager = delta
[interactive]
    diffFilter = delta --color-only
[delta]
    dark = true
    syntax-theme = TwoDark
```

Before doing it:

- `~/.gitconfig` is not in dotfiles. Track it first, or the change lives on
  this Mac only.
- `core.pager` also changes `git log`, `git show`, `git blame` and
  `git add -p`. Check each one, `add -p` especially.
- Safe either way: lazygit passes `--no-gitconfig`, and scripts, Claude Code
  and nvim plugins run git without a terminal, so they never use the pager.
