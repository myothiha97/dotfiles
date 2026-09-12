#!/usr/bin/env bash
# Compact session picker in a tmux popup, numbered from 1 in creation order.
#
# Two modes, bound to different keys because they want opposite things from the
# keyboard. A key is either typed into a search field or acts as a command; it
# cannot be both, so each mode picks one.
#
#   select  (prefix + s)  no input field. j/k, ctrl-n/ctrl-p, arrows and the
#                         digits 1-9 all navigate or jump, and x kills the
#                         session under the cursor. No search.
#   search  (prefix + f)  input field shown. Everything types, including j/k,
#                         x and the digits; only ctrl-n/ctrl-p and the arrows
#                         move.
#
# Killing is on ctrl-x in both modes, and additionally on plain x in select,
# where no field is competing for the key.
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

rows=$("$script_dir/session-rows.sh")

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
  # Wait for the whole list before the first draw, so the "start" binding below
  # runs against a loaded list.
  --sync
  --pointer='>'
  --marker=' '
  # fzf draws a "gutter" bar (default U+258C) at the start of every row that is
  # not the current one. Blank it so the ">" pointer is the only marker.
  --gutter=' '
  # Without this fzf paints bg+ only behind the item's own text, so the band
  # stops at the end of the session name. This runs it to the popup edge.
  --highlight-line
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

# Kill the row under the cursor, after a y/n prompt. execute() hands the popup's
# terminal to the prompt, then reload rebuilds the rows so the numbering and the
# "*" marker follow the kill.
kill_row="execute(\"$script_dir/kill-session.sh\" {})+reload(\"$script_dir/session-rows.sh\")"

# Arrows are fzf defaults in both modes; ctrl-n / ctrl-p are made explicit.
# ctrl-x is the kill key both modes can share, because a ctrl combination is
# never swallowed by the search field.
binds="ctrl-n:down,ctrl-p:up,ctrl-c:abort,esc:abort,ctrl-x:$kill_row"

if [ "$mode" = "select" ]; then
  # No text field, so every key is free to act as a command.
  binds="$binds,j:down,k:up,g:first,G:last,q:abort"
  # No field to type into, so the plain key is free as well.
  binds="$binds,x:$kill_row"
  for n in 1 2 3 4 5 6 7 8 9; do
    binds="$binds,$n:pos($n)+accept"
  done
  opts+=(--no-input)
else
  # Search mode: j/k, g/G, q, x and the digits must reach the input field, so
  # none of them are bound. Navigation is ctrl-n / ctrl-p and the arrow keys,
  # and killing is ctrl-x.
  opts+=(--prompt='  ')
fi

# Put the cursor on the current session instead of on row 1. "start" fires once
# at launch, unlike "load", which fires again on every reload and would drag the
# cursor back to a stale row number after a kill.
if [ -n "$current_row" ] && [ "$current_row" -gt 0 ] 2>/dev/null; then
  binds="$binds,start:pos($current_row)"
fi

choice=$(printf '%s\n' "$rows" | fzf "${opts[@]}" --bind="$binds") || exit 0

# Strip the leading number and the "*" current marker back off.
name=$(printf '%s' "$choice" \
  | sed -e 's/^[0-9]\{1,\}[[:space:]][[:space:]]*//' -e 's/[[:space:]][[:space:]]\*$//')

[ -n "$name" ] || exit 0

tmux switch-client -t "=$name"
