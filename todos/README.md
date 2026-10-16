# Todos

Backlog and decision record. One file per idea. Nothing here is in the config
unless its own file says so.

Read the change gate in `CLAUDE.md` before acting on anything in this folder.
Items here are **collected, not executed**: they get triaged together in a
planned session, never picked up on impulse.

Ideas are grouped by app, in a folder named like the app's folder at the repo
root (`tmux/`, `zsh/`, `ghostty/`, `yabai/`, ...). A folder is created when its
first idea arrives. Two folders are not apps:

| folder                 | what it holds                                       |
| ---------------------- | --------------------------------------------------- |
| [`ghostty/`](#ghostty) | terminal config, keybinds, rendering                |
| [`lazygit/`](#lazygit) | lazygit config and its diff pager                   |
| [`tmux/`](#tmux)       | tmux config and its scripts                         |
| [`zsh/`](#zsh)         | zsh config, completion, prompt                      |
| `process/`             | how the config is worked on, not what it contains   |
| `done/`                | shipped and verified; kept for the reasoning        |

Status column meanings:

- **open**: real remaining work, not started or partly done
- **parked**: built or investigated, deliberately inactive; do not revive
  without a reason stated in the file
- **record**: a log of a past decision, not work to do
- **done**: shipped; the file is kept for what it measured or decided

To add an idea: create one file in the matching folder, add its row below
(and the folder's row above if it is new).

---

## ghostty

| file                                                         | hook                                                                                          | status |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------- | ------ |
| [`native-ghostty-splits.md`](ghostty/native-ghostty-splits.md) | Ghostty splits as a tmux replacement; on branch `unstable/ghostty-native-splits`, untested    | open   |

## lazygit

| file | hook | status |
| ---- | ---- | ------ |
| [`delta-nvim-theme.md`](lazygit/delta-nvim-theme.md) | syntax-coloured diffs via delta (TwoDark); made by choice on request; old instability cause still unknown | done |
| [`sync-delta-with-nvim-theme.md`](lazygit/sync-delta-with-nvim-theme.md) | generate a delta theme from the nvim palette so both match; approximate only (TextMate vs treesitter) | open |

## tmux

| file | hook | status |
| ---- | ---- | ------ |
| [`session-picker-open-latency.md`](tmux/session-picker-open-latency.md) | picker opens in ~130 ms; ~70 ms is forks before fzf, one `list-sessions` would cut it | open |

## zsh

| file | hook | status |
| ---- | ---- | ------ |
| [`disable-autocomplete-listing.md`](zsh/disable-autocomplete-listing.md) | turn off the zsh-autocomplete listing while typing; made by choice on request | done |
| [`nvim-cd-on-exit.md`](zsh/nvim-cd-on-exit.md) | `n` wrapper to cd into nvim's last cwd on exit; works in a fresh shell, fails in live panes | open |
