# Session picker opens in ~130 ms

Measured 2026-10-13 in a real `display-popup` (nested test server, fzf 3.8 era):

- empty popup (`true`): ~25 ms
- full picker, key to fzf `start`: ~125-145 ms
- of that, the script before fzf: ~70 ms; fzf's own start: ~25-35 ms

Where the 70 ms goes: about six forks before fzf. `display-message -p '#S'`,
`list-sessions.sh` (bash + tmux + sort + cut), then `session-rows.sh` runs
`display-message` and `list-sessions.sh` again.

Idea: pass the current session from the bind (`'#{session_name}'` in the
`display-popup` command) and build rows and `current_row` from one
`tmux list-sessions` + `sort` + `awk`. Expected ~70 ms down to ~20 ms, so the
picker opens in ~80 ms. Keep `session-rows.sh` for the kill `reload()`.

Gate: no breakage, ~50 ms per open does not pay back ~45 min of work. Deferred.
