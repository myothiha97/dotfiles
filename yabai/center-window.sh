#!/bin/sh

# Move the focused window to the center of its display, keeping its size.
# Bound in skhd (Cmd+Shift+C, Ghostty only) to undo Cmd+Option+Arrow nudges.

YABAI=/opt/homebrew/bin/yabai
JQ=/usr/bin/jq

window=$("$YABAI" -m query --windows --window) || exit 0
display=$("$YABAI" -m query --displays --window) || exit 0

# Top-left corner that centers the window, in yabai's global coordinates.
pos=$("$JQ" -n -r --argjson w "$window" --argjson d "$display" '
  "\(($d.frame.x + ($d.frame.w - $w.frame.w) / 2) | floor):\(($d.frame.y + ($d.frame.h - $w.frame.h) / 2) | floor)"')

"$YABAI" -m window --move "abs:$pos"
