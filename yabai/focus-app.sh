#!/bin/sh

# Focus an existing window of the given app, launching the app when none exists.
#
# macOS 27 broke yabai's SIP-enabled space switching (asmvik/yabai#2822): the
# synthetic swipe yabai posts is dropped by the Dock, so
# skip_window_focus_animation no longer suppresses the space slide. Until that
# is fixed upstream, InstantSpaceSwitcher performs the space change instead and
# yabai only focuses the window afterwards.
#
# InstantSpaceSwitcher always acts on the focused display and indexes spaces
# within that display, starting at 1. yabai cannot move focus between displays
# on macOS 27 either, so a hidden space on an unfocused display is left to the
# plain focus path and keeps the native animation.

YABAI=/opt/homebrew/bin/yabai
JQ=/usr/bin/jq
ISS=/Applications/InstantSpaceSwitcher.app/Contents/MacOS/ISSCli

app_name=$1

window=$(
  $YABAI -m query --windows |
    $JQ -r --arg app "$app_name" \
      'map(select(.app == $app and .["has-ax-reference"] == true)) | first
       | if . then "\(.id) \(.space)" else empty end'
)

if [ -n "$window" ]; then
  window_id=${window% *}
  space_index=${window#* }

  if [ -x "$ISS" ]; then
    # visible flag, display index and the space's 1-based position on that display
    target=$(
      $YABAI -m query --spaces |
        $JQ -r --argjson space "$space_index" \
          '(map(select(.index == $space)) | first) as $target
           | if $target == null then empty
             else "\($target["is-visible"]) \($target.display) \(
                    [.[] | select(.display == $target.display) | .index]
                      | index($space) + 1)"
             end'
    )
    set -- $target
    visible=$1
    display_index=$2
    display_position=$3

    focused_display=$($YABAI -m query --displays --display | $JQ -r '.index')

    if [ "$visible" = "false" ] && [ "$display_index" = "$focused_display" ]; then
      "$ISS" index "$display_position" >/dev/null 2>&1
    fi
  fi

  $YABAI -m window --focus "$window_id" && exit 0
fi

if [ "$app_name" = "Finder" ]; then
  exec /usr/bin/open -a Finder "$HOME"
fi

exec /usr/bin/open -a "$app_name"
