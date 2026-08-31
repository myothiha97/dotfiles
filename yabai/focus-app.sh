#!/bin/sh

app_name=$1
window_id=$(
  /opt/homebrew/bin/yabai -m query --windows |
    /usr/bin/jq -r --arg app "$app_name" 'map(select(.app == $app)) | first | .id // empty'
)

if [ -n "$window_id" ]; then
  exec /opt/homebrew/bin/yabai -m window --focus "$window_id"
fi

exec /usr/bin/open -a "$app_name"
