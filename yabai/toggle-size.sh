#!/bin/sh

# Toggle the focused Ghostty window between its small and medium sizes,
# centered on its display. Bound in skhd to Cmd+Shift+Y for Ghostty only.
# Ghostty has no "resize to N x M" action, so yabai does the resize.
#
# Sizes are in points at font-size 14 and match ghostty/config:
#   small  892x652  = window-width 111, window-height 26 (the default)
#   medium 1284x960 = 160x40, the old default

YABAI=/opt/homebrew/bin/yabai
JQ=/usr/bin/jq

SMALL_W=892 SMALL_H=652
MEDIUM_W=1284 MEDIUM_H=960

window=$("$YABAI" -m query --windows --window) || exit 0
display=$("$YABAI" -m query --displays --window) || exit 0
width=$(printf '%s' "$window" | "$JQ" -r '.frame.w | round')

# At the small size (allow 2 pt of rounding): grow. Any other size: shrink.
if [ $((width - SMALL_W)) -ge -2 ] && [ $((width - SMALL_W)) -le 2 ]; then
  w=$MEDIUM_W h=$MEDIUM_H grow=true
else
  w=$SMALL_W h=$SMALL_H grow=false
fi

# Top-left corner that centers the new size, in yabai's global coordinates.
# shellcheck disable=SC2016 # $d is a jq variable, not shell
pos=$("$JQ" -n -r --argjson d "$display" --argjson w "$w" --argjson h "$h" '
  "\(($d.frame.x + ($d.frame.w - $w) / 2) | floor):\(($d.frame.y + ($d.frame.h - $h) / 2) | floor)"')

# macOS cuts a window off at the screen edge, so move first when growing and
# resize first when shrinking.
if [ "$grow" = true ]; then
  "$YABAI" -m window --move "abs:$pos"
  "$YABAI" -m window --resize "abs:$w:$h"
else
  "$YABAI" -m window --resize "abs:$w:$h"
  "$YABAI" -m window --move "abs:$pos"
fi
