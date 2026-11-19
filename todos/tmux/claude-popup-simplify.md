# Claude popup: back to plugin defaults

Requested 2026-11-19. Two removals, both added in PR #4 (`ca064ab`, `881fc15`).

## 1. Drop ctrl-f hide

prefix + d is enough to hide the prefix + y popup.

Remove from `tmux/.tmux.conf`: the `session-created` hook, the `run-shell` that
copies the root table into the `claude` table, the `bind -T claude C-f` line,
and their comments. Keep `ctrl-f:abort` in `@claude_fzf_options`: the
prefix + u picker still closes with ctrl-f (user choice). Live state:
`tmux set-hook -gu session-created`; existing claude-* sessions keep
`key-table claude` until `set -u key-table` or a server restart.

Gain: Claude Code gets ctrl-f back, config load ~7 ms faster, no stale
key-table snapshot.

Not possible: prefix + d to close the prefix + u picker. That popup runs fzf
directly (no nested tmux client like prefix + y), so tmux gives every key to
fzf and the prefix never reaches tmux. fzf has no two-key chords. Esc still
closes it.

## 2. Revert "open agent without switching session"

Back to the plugin's own enter: it switches the main client to the window
where prefix + y was pressed, then opens the agent.

Remove `tmux/claude-attach.sh` and the two `transform` binds in
`@claude_fzf_options`. Keep ctrl-j / ctrl-k, and make ctrl-l plain `accept`
so it still opens the agent.

Gain: no coupling to the plugin's row layout and attach path, so a plugin or
fzf update can no longer silently break enter.

## Both

Update README "Claude hatch" (changes list, limits, recheck list) and the
`@claude_fzf_options` comments.

Gate: nothing broken, both worked; deferred, then made by choice on request (2026-11-19).
