#!/bin/sh

app_name=$1
window_id=$(
  /opt/homebrew/bin/yabai -m query --windows |
    /usr/bin/jq -r --arg app "$app_name" \
      'map(select(.app == $app and .["has-ax-reference"] == true)) | first | .id // empty'
)

if [ -n "$window_id" ]; then
  /opt/homebrew/bin/yabai -m window --focus "$window_id" && exit 0
fi

if [ "$app_name" = "Finder" ]; then
  exec /usr/bin/open -a Finder "$HOME"
fi

exec /usr/bin/open -a "$app_name"
