#!/bin/sh
# cmd+ctrl+l in Ghostty, bound in skhd/skhdrc.
#
# Without tmux (ghostty/no-tmux loaded): focus this tab's Claude split, or open
# one on the right in the current directory. Same idea as tmux/claude-pane.sh.
# With a tmux client attached: send the key on to tmux, exactly as the old
# Ghostty keybind did, so tmux's own Claude pane still works.
set -eu

state_dir="$HOME/.cache/ghostty-claude"
claude_cmd="exec claude --model claude-sonnet-5-5 --effort medium"
# Pixels the divider moves right after splitting, so Claude gets ~35%, not 50%
shrink_px=200

if tmux list-clients 2>/dev/null | grep -q .; then
  osascript -e 'tell application "Ghostty" to perform action "text:\\x1b[27;7;108~" on focused terminal of selected tab of front window' >/dev/null
  exit 0
fi

# One file per tab holds the id of that tab's Claude split
mkdir -p "$state_dir"
tab_id=$(osascript -e 'tell application "Ghostty" to get id of selected tab of front window')
state="$state_dir/$tab_id"
saved=$(cat "$state" 2>/dev/null || true)

# Interactive login zsh, so nvm's PATH (where claude lives) is set up
new_id=$(osascript "$(dirname "$0")/claude-split.applescript" \
  "$saved" "/bin/zsh -ilc '$claude_cmd'" "$shrink_px")

if [ -n "$new_id" ]; then
  printf '%s\n' "$new_id" >"$state"
fi
