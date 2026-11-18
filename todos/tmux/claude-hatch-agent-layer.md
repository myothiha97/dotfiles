# Claude sessions in their own layer (tmux-claude-hatch)

Requested 2026-11-18. Plugin: https://github.com/craftzdog/tmux-claude-hatch

Idea: run each Claude Code session in a hidden `claude-<hash>` tmux session shown
in a popup, so normal tmux sessions stay for other work.

Plan:

- `set -g @plugin 'craftzdog/tmux-claude-hatch'` above the tpm line.
- Keys: prefix + y open/hide hatch for the current dir, prefix + u agent picker,
  prefix + d hide the popup (built-in detach). y and u are free in this config
  and in tmux defaults.
- `list-sessions.sh`: hide `claude-*` sessions with a `-f` format filter (no
  fork), so prefix + s/f, Cmd+<n> and cycle keep showing only work sessions.

Cost: key-press scripts only (not hot paths); one global `alert-bell` hook that
forks bash per bell. Status bar shows `claude:<account>` (a plain option, no
shell).

Known limit: the picker reads `~/.claude/sessions` (personal). Sessions started
with `clw` (`~/.claude-work`) do not show, because the tmux server has no
`CLAUDE_CONFIG_DIR`.

Gate: new plugin, deferred by default; made by choice on request (2026-11-18).
The account limit above is handled by prefix + Y (work/personal switch).
