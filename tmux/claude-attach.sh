#!/usr/bin/env bash
# Open an agent from the hatch picker (prefix + u) without moving the main
# client. The plugin's own enter first switches the main client to the window
# where prefix + y was pressed, which changes your current session and window.
# This replaces enter / ctrl-l through @claude_fzf_options (see .tmux.conf).
#
#   claude-attach.sh action <pane_id> <kind>
#       Run by fzf's transform on enter. Prints the fzf action to run:
#       - kind "loose" (Claude in a normal pane): "accept", so the plugin's own
#         jump runs. A loose agent can only be seen by going to its pane.
#       - otherwise (a hidden claude-* session): attach it in this popup.
#   claude-attach.sh attach <pane_id>
#       Run by fzf's execute. Focuses the agent's pane inside its hidden session
#       and attaches that session in the popup, over the current window.
#
# Coupling to the plugin (tmux-claude-hatch), check after a plugin update:
# - Picker rows are "rank \t pane_id \t pid \t kind \t ...", so fzf's {2} is the
#   pane and {4} the kind (see the plugin's scripts/agents.sh). If that layout
#   changes, enter picks the wrong field and stops working until updated here.
# - This copies the plugin's attach step (select-window, select-pane,
#   attach-session) minus the switch-client. A new step added upstream to that
#   path is not picked up here.
# - The plugin's @claude_origin is left alone, so bell forwarding to the origin
#   window still works.

mode=$1
pane=$2

case $mode in
action)
  if [ -z "$pane" ] || [ "$3" = loose ]; then
    echo accept
  else
    echo "execute(~/.dotfiles/tmux/claude-attach.sh attach $pane)+abort"
  fi
  ;;
attach)
  session=$(tmux display-message -p -t "$pane" '#{session_name}' 2>/dev/null)
  [ -n "$session" ] || exit 0
  tmux select-window -t "$pane" 2>/dev/null
  tmux select-pane -t "$pane" 2>/dev/null
  # fzf's execute gives the command /dev/tty as stdin, which tmux refuses
  # ("can't use /dev/tty"). stderr is still the popup's real terminal, so
  # attach on that instead.
  if [ -t 2 ]; then
    exec tmux attach-session -t "$session" <&2
  fi
  exec tmux attach-session -t "$session"
  ;;
esac
