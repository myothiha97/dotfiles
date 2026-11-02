# Session picker opens in ~130-190 ms

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

Re-measured 2026-11-02 on the real client (Ghostty 1.4.0, tmux 3.8, fzf 0.73.1,
3 sessions), 5 runs, from `display-popup` to fzf's `start` event:

- popup up and its command running: ~35-60 ms
- script before fzf: ~105-125 ms (about 25 ms of that is the timing wrapper)
- fzf's own start: ~45-50 ms
- total: ~190-220 ms. Same on an isolated test server without Ghostty, and
  unchanged after 90 s idle, so it is not the Ghostty upgrade and not a cold start.

The user feels it as ~700 ms of blank popup, and it was there before the
Ghostty 1.4.0 upgrade. The fix idea above still applies and is still the biggest
lever: the script, not fzf or Ghostty, is most of the wait.

Fixed 2026-11-02 on branch `perf/tmux-session-picker-forks` (user chose to do it
anyway), in two steps:

1. Passed the current session to `session-rows.sh` and read the cursor row from
   its "*" marker. Only ~30 ms, and the marker match picked the wrong row for a
   session whose own name ends in "  *".
2. Final: the picker builds its rows inline from ONE tmux call
   (`display-message -p '#S' \; list-sessions ...`) + `sort` + `awk`, and
   matches the whole row for the cursor. `session-rows.sh` is back to its
   original (kill `reload()` only). Sort and row format now live in two places;
   both files carry a "change both together" comment.

- Passing the session from the bind is NOT possible: tmux 3.8 does not expand
  formats in the `display-popup` command or in `-e` values (tested).
- Interleaved, 10 runs each, isolated server: total median ~222 -> ~166 ms,
  script ~120 -> ~65 ms (both include ~25 ms of timing wrapper). What is left is
  tmux opening the popup (~50) and fzf starting (~50), neither ours.
- Checked: rows and numbering identical to `session-rows.sh` / `list-sessions.sh`
  (names with spaces, a quote, and "b  *"), cursor start on rows 1-4, digit jump,
  `l`, `x` kill + reload, search mode.

Move to `done/` after merging.
