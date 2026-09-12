#!/usr/bin/env bash
# Confirm and kill the session on the picker's current row, bound to "x".
#
# Takes the whole row ("3  name  *") and resolves the name by its position in
# list-sessions.sh rather than parsing it back out of the row text, so a name
# containing spaces or ending in "*" cannot be mangled.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# fzf hands the terminal over exactly as the list left it, so each message has
# to wipe the screen itself. Without this they stack on top of one another.
clear_screen() { printf '\033[2J\033[H'; }

pause() {
  clear_screen
  printf '%s\n\npress any key ' "$1"
  read -rsn 1 _ || true
}

row=${1:-}
n=$(printf '%s' "$row" | sed -n 's/^[[:space:]]*\([0-9]\{1,\}\).*/\1/p')
[ -n "$n" ] || exit 0

sessions=$("$script_dir/list-sessions.sh")
name=$(printf '%s\n' "$sessions" | sed -n "${n}p")
[ -n "$name" ] || exit 0

total=$(printf '%s\n' "$sessions" | grep -c '')
current=$(tmux display-message -p '#S')

# Killing the last session takes the whole tmux server down with it.
if [ "$total" -le 1 ]; then
  pause "only one session left"
  exit 0
fi

# The popup runs inside the current session's client. Killing it out from under
# the popup is the one case that is not safe to do from here, so switch away
# first with prefix + s and kill it from the session you land in.
if [ "$name" = "$current" ]; then
  pause "cannot kill the current session"
  exit 0
fi

clear_screen
printf 'kill "%s"? (y/n) ' "$name"
reply=''
read -rsn 1 reply || true
case "$reply" in
  y|Y) tmux kill-session -t "=$name" ;;
esac
