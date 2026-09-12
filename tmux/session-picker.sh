#!/usr/bin/env bash
# Compact session picker in a tmux popup, numbered from 1 in creation order.
#
# Two modes, bound to different keys because they want opposite things from the
# keyboard. A key is either typed into a search field or acts as a command; it
# cannot be both, so each mode picks one.
#
#   select  (prefix + f)  no input field. j/k, ctrl-n/ctrl-p, arrows and the
#                         digits 1-9 all navigate or jump. No search.
#   search  (prefix + s)  input field shown. Everything types, including j/k
#                         and digits; only ctrl-n/ctrl-p and the arrows move.
#
# tmux's own display-menu is not used for either: menu.c hardcodes its
# navigation keys (arrows, j/k, tab, C-b/C-f, g/G) with no way to add
# ctrl-n / ctrl-p. Falls back to the display-menu version when fzf is missing.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

mode=${1:-select}
case "$mode" in
  select|search) ;;
  *) echo "mode must be 'select' or 'search'" >&2; exit 2 ;;
esac

if ! command -v fzf >/dev/null 2>&1; then
  exec "$script_dir/session-menu.sh"
fi

current=$(tmux display-message -p '#S')

rows=$("$script_dir/list-sessions.sh" | awk -v cur="$current" '
  { printf "%d  %s%s\n", NR, $0, ($0 == cur ? "  *" : "") }')

# Shared look, so both modes read as the same panel.
opts=(
  --reverse
  --cycle
  --no-multi
  --no-scrollbar
  --no-separator
  --info=hidden
  --border=none
  --height=100%
  --pointer='>'
  --marker=' '
  # fzf draws a "gutter" bar (default U+258C) at the start of every row that is
  # not the current one. Blank it so the ">" pointer is the only marker.
  --gutter=' '
  --color='pointer:green'
)

# Arrows are fzf defaults in both modes; ctrl-n / ctrl-p are made explicit.
binds='ctrl-n:down,ctrl-p:up,ctrl-c:abort,esc:abort'

if [ "$mode" = "select" ]; then
  # No text field, so every key is free to act as a command.
  binds="$binds,j:down,k:up,g:first,G:last,q:abort"
  for n in 1 2 3 4 5 6 7 8 9; do
    binds="$binds,$n:pos($n)+accept"
  done
  opts+=(--no-input)
else
  # Search mode: j/k, g/G, q and the digits must reach the input field, so none
  # of them are bound. Navigation is ctrl-n / ctrl-p and the arrow keys only.
  opts+=(--prompt='  ')
fi

choice=$(printf '%s\n' "$rows" | fzf "${opts[@]}" --bind="$binds") || exit 0

# Strip the leading number and the "*" current marker back off.
name=$(printf '%s' "$choice" \
  | sed -e 's/^[0-9]\{1,\}[[:space:]][[:space:]]*//' -e 's/[[:space:]][[:space:]]\*$//')

[ -n "$name" ] || exit 0

tmux switch-client -t "=$name"
