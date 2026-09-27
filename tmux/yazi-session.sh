#!/usr/bin/env bash
# Toggle between the current pane and the "yazi" window of the "yazi-files"
# session (prefix + o).
#
# From anywhere else: remember the current pane, then switch to yazi-files:yazi,
# creating the session or window in the current directory if it is missing.
# From yazi-files:yazi: switch back to the remembered pane, or to the last
# session if that pane is gone.
#
# yazi is typed into a shell rather than run as the window command, so quitting
# it leaves a usable prompt behind instead of closing the window.
#
# Usage: yazi-session.sh <client-tty> <session> <window> <pane> <start-dir>

set -euo pipefail

client=${1:?missing client tty}
current_session=${2:?missing session name}
current_window=${3:?missing window name}
current_pane=${4:?missing pane id}
start_dir=${5:-$HOME}

session="yazi-files"
window="yazi"
target="=$session:$window"

if [ "$current_session" = "$session" ] && [ "$current_window" = "$window" ]; then
  back=$(tmux show-options -gqv @yazi-return)

  if [ -n "$back" ] && tmux display-message -p -t "$back" '' >/dev/null 2>&1; then
    tmux select-window -t "$back"
    tmux select-pane -t "$back"
    tmux switch-client -c "$client" -t "$back"
  else
    tmux switch-client -c "$client" -l 2>/dev/null ||
      tmux display-message -c "$client" "No session to go back to"
  fi
  exit 0
fi

tmux set-option -g @yazi-return "$current_pane"

# Naming the window with -n turns off automatic-rename, so the name sticks.
if ! tmux has-session -t "=$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -n "$window" -c "$start_dir"
  tmux send-keys -t "$target" yazi Enter
elif ! tmux list-windows -t "=$session" -F '#{window_name}' | grep -qxF "$window"; then
  tmux new-window -d -t "=$session:" -n "$window" -c "$start_dir"
  tmux send-keys -t "$target" yazi Enter
else
  # The window exists but yazi was quit: restart it if a shell is waiting.
  case "$(tmux display-message -p -t "$target" '#{pane_current_command}')" in
    zsh|bash|sh|fish) tmux send-keys -t "$target" yazi Enter ;;
  esac
fi

tmux switch-client -c "$client" -t "$target"
