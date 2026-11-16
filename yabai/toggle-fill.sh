#!/bin/sh

# Toggle the focused window between filling its display and its previous frame,
# like Ghostty's toggle_maximize. Bound in skhd to Cmd+Shift+U for every app but
# Ghostty, which keeps its own action. The previous frame is kept per window in
# $TMPDIR, so it is forgotten on reboot.

YABAI=/opt/homebrew/bin/yabai
JQ=/usr/bin/jq
STATE_DIR="${TMPDIR:-/tmp}/yabai-fill"

# Frame as x:y:w:h in whole points (+ 0 turns -0 into 0).
FRAME='.frame | "\((.x|round) + 0):\((.y|round) + 0):\(.w|round):\(.h|round)"'

window=$("$YABAI" -m query --windows --window) || exit 0
set -- $(printf '%s' "$window" | "$JQ" -r "\"\(.id) \(.\"is-native-fullscreen\") \" + ($FRAME)")
id=$1 fullscreen=$2 current=$3
[ "$fullscreen" = true ] && exit 0

state="$STATE_DIR/$id"

# Filled by us and not moved since: go back to the saved frame. Resize before
# moving, so the window is small enough to land where it was.
if [ -f "$state" ]; then
  read -r previous filled < "$state"
  rm -f "$state"
  if [ "$current" = "$filled" ]; then
    IFS=: read -r x y w h <<EOF
$previous
EOF
    "$YABAI" -m window "$id" --resize "abs:$w:$h"
    "$YABAI" -m window "$id" --move "abs:$x:$y"
    exit 0
  fi
fi

"$YABAI" -m window "$id" --grid 1:1:0:0:1:1
filled=$("$YABAI" -m query --windows --window "$id" | "$JQ" -r "$FRAME")

if [ "$filled" != "$current" ]; then
  mkdir -p "$STATE_DIR"
  printf '%s %s\n' "$current" "$filled" > "$state"
else
  # Already filling the display with no saved frame (opened that way): shrink
  # to a centered two-thirds frame so the key still does something.
  "$YABAI" -m window "$id" --grid 6:6:1:1:4:4
fi
