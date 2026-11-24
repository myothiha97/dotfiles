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
| [`git/`](#git)         | git config (`~/.gitconfig`, not tracked yet)        |
| [`lazygit/`](#lazygit) | lazygit config and its diff pager                   |
| [`skhd/`](#skhd)       | global hotkeys (skhd) and the yabai calls they make |
| [`tmux/`](#tmux)       | tmux config and its scripts                         |
| [`typora/`](#typora)   | Typora themes                                       |
| [`yazi/`](#yazi)       | yazi file manager config and openers                |
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
| [`small-window-size-toggle.md`](ghostty/small-window-size-toggle.md) | 111x26 centered default; Cmd+Shift+Y toggles 160x40, Cmd+Shift+U full screen; made by choice on request | done |

## git

| file | hook | status |
| ---- | ---- | ------ |
| [`delta-as-git-pager.md`](git/delta-as-git-pager.md) | syntax-coloured `git diff` in the shell via `core.pager = delta`; deferred, diffs are read in lazygit | open |

## lazygit

| file | hook | status |
| ---- | ---- | ------ |
| [`delta-nvim-theme.md`](lazygit/delta-nvim-theme.md) | syntax-coloured diffs via delta (TwoDark); made by choice on request; old instability cause still unknown | done |
| [`sync-delta-with-nvim-theme.md`](lazygit/sync-delta-with-nvim-theme.md) | generate a delta theme from the nvim palette so both match; approximate only (TextMate vs treesitter) | open |

## skhd

| file | hook | status |
| ---- | ---- | ------ |
| [`window-keys-all-apps.md`](skhd/window-keys-all-apps.md) | Ghostty window keys (Cmd+Shift+U/C, Cmd+Opt+Arrows) in every app; overrides app keys by choice | done |
| [`neovide-obsidian-focus-keys.md`](skhd/neovide-obsidian-focus-keys.md) | Cmd+Ctrl+N to Neovide, Obsidian to Cmd+Ctrl+,; Preview has no key now; made by choice on request | done |

## tmux

| file | hook | status |
| ---- | ---- | ------ |
| [`session-picker-open-latency.md`](tmux/session-picker-open-latency.md) | picker opens in ~130 ms; ~70 ms is forks before fzf, one `list-sessions` would cut it | open |
| [`claude-hatch-agent-layer.md`](tmux/claude-hatch-agent-layer.md) | Claude sessions in hidden popup sessions (tmux-claude-hatch), kept out of the session pickers; prefix + Y account switch; made by choice on request | done |
| [`claude-popup-simplify.md`](tmux/claude-popup-simplify.md) | Claude popup back to plugin defaults: drop ctrl-f hide (picker keeps ctrl-f), revert no-switch open from the picker; made by choice on request | done |
| [`claude-hatch-key-rotation.md`](tmux/claude-hatch-key-rotation.md) | rotate prefix + y/u/i: popup to u, picker to i, display-message to y; made by choice on request | done |

## typora

| file | hook | status |
| ---- | ---- | ------ |
| [`outline-pointer-cursor.md`](typora/outline-pointer-cursor.md) | hand cursor on outline items; Typora sets it already, cause unknown | open |

## yazi

| file | hook | status |
| ---- | ---- | ------ |
| [`enter-as-l-and-md-opener.md`](yazi/enter-as-l-and-md-opener.md) | Enter acts like `l`; markdown opens in Typora, not Neovide | done |

## zsh

| file | hook | status |
| ---- | ---- | ------ |
| [`disable-autocomplete-listing.md`](zsh/disable-autocomplete-listing.md) | turn off the zsh-autocomplete listing while typing; made by choice on request | done |
| [`nvim-cd-on-exit.md`](zsh/nvim-cd-on-exit.md) | `n` wrapper to cd into nvim's last cwd on exit; works in a fresh shell, fails in live panes | open |
