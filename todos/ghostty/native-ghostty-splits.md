# Native Ghostty as a tmux replacement

Goal: cover about 80% of tmux's workflows with Ghostty's own splits. Keymaps
first; session restore is low priority.

## State

Work lives on branch `unstable/ghostty-native-splits` (pushed, not merged,
untested):

- `ghostty/no-tmux` keymaps (`ctrl+space` prefix)
- `ghostty/claude-split.sh` + `.applescript` (`cmd+ctrl+l` Claude split)
- an skhd bind

## Before merging

- Test it.
- Resolve the conflict with the `cmd+hjkl` pane-nav binds in `ghostty/config`.

## Still missing vs tmux

Sessions, copy mode, swap panes, prefix timeout.
