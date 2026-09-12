#!/usr/bin/env bash
# 1-based session picker for tmux, ordered oldest session first.
# tmux's built-in choose-tree assigns shortcut keys 0-9 itself and offers no
# way to rebase them, so this builds an equivalent display-menu instead.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

current=$(tmux display-message -p '#S')
args=()
i=1

while IFS= read -r name; do
  # Sessions 1-9 get the digit keys; anything beyond falls back to letters.
  if [ "$i" -le 9 ]; then
    key="$i"
  else
    key=$(printf "\\$(printf '%03o' $((87 + i)))")  # 10 -> a, 11 -> b, ...
  fi

  label="$i: $name"
  [ "$name" = "$current" ] && label="$label (current)"

  # Escape single quotes so names with quotes survive tmux's command parser.
  escaped=${name//\'/\'\\\'\'}

  # "=" forces an exact name match instead of tmux's prefix matching.
  args+=("$label" "$key" "switch-client -t '=$escaped'")
  i=$((i + 1))
done < <("$script_dir/list-sessions.sh")

if [ ${#args[@]} -eq 0 ]; then
  tmux display-message "No sessions"
  exit 0
fi

tmux display-menu -T '#[align=centre]Sessions' -x C -y C "${args[@]}"
