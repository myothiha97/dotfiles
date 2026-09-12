#!/usr/bin/env bash
# Compact session picker in a tmux popup, numbered from 1 in creation order.
#
# Two modes, bound to different keys because they want opposite things from the
# keyboard. A key is either typed into a search field or acts as a command; it
# cannot be both, so each mode picks one.
#
#   select  (prefix + s)  no input field. j/k, ctrl-n/ctrl-p, arrows and the
#                         digits 1-9 all navigate or jump. No search.
#   search  (prefix + f)  input field shown. Everything types, including j/k
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

sessions=$("$script_dir/list-sessions.sh")

rows=$(printf '%s\n' "$sessions" | awk -v cur="$current" '
  { printf "%d  %s%s\n", NR, $0, ($0 == cur ? "  *" : "") }')

# Row number of the session we are in, so the cursor can start there instead of
# on the first row. Empty if the current session is somehow not in the list, in
# which case the cursor is left where fzf puts it.
current_row=$(printf '%s\n' "$sessions" | awk -v cur="$current" '$0 == cur { print NR; exit }')

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
  # Backgrounds are pinned to the terminal default (-1) so ghostty's window
  # transparency and blur show through the popup.
  #
  # bg+ is the one deliberate exception. A terminal cannot draw a translucent
  # cell background, so the current row's band has to be a solid colour, and
  # that one row is opaque. It is kept close to the ghostty background
  # (#031219) so it reads as a faint lift rather than a block. fg+ is reset to
  # regular because the band, not bold text, is what marks the current row.
  --color='bg:-1,gutter:-1,preview-bg:-1,border:-1,header:-1,bg+:#0d2a38,fg+:-1:regular,pointer:green'
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

# Put the cursor on the current session instead of on row 1. This uses "load",
# not "start": "start" fires before fzf has read stdin, so pos() would run
# against an empty list and do nothing.
if [ -n "$current_row" ] && [ "$current_row" -gt 0 ] 2>/dev/null; then
  binds="$binds,load:pos($current_row)"
fi

choice=$(printf '%s\n' "$rows" | fzf "${opts[@]}" --bind="$binds") || exit 0

# Strip the leading number and the "*" current marker back off.
name=$(printf '%s' "$choice" \
  | sed -e 's/^[0-9]\{1,\}[[:space:]][[:space:]]*//' -e 's/[[:space:]][[:space:]]\*$//')

[ -n "$name" ] || exit 0

tmux switch-client -t "=$name"
