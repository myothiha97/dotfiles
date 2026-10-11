#!/usr/bin/env bash
# Open Claude as a full-height pane on the right edge of a window, 35% of the
# window wide (Cmd+Ctrl+L, see the C-M-l binding in .tmux.conf). Claude is the
# pane's own process, so the pane closes when Claude exits.
#
# When that pane leaves the window (Claude exits, kill-pane, or the pane is
# moved), the layout saved here is restored, so the other panes get their old
# sizes back. If panes were added or removed meanwhile, the saved layout no
# longer fits and tmux keeps its default resize.
#
# The restore is a global window-layout-changed hook with the window id, pane id
# and layout written into it. A hook on the window itself is not reliable: when
# the closed pane was the window's active pane and the client is viewing another
# window, tmux runs the hook in the viewed window, so it never finds a window
# hook. The hook is a pure format check (no shell), does nothing while the pane
# is still in its window, and removes itself once it has run.
#
# Usage: claude-pane.sh <window-id> <start-dir>

set -euo pipefail

window=${1:?missing window id}
start_dir=${2:-$HOME}

layout=$(tmux display-message -p -t "$window" '#{window_layout}')
pane=$(tmux split-window -t "$window" -fh -l 35% -c "$start_dir" -P -F '#{pane_id}' \
  claude --model claude-sonnet-5-5 --effort medium)

# Lets the key binding see that this window already has its Claude pane.
tmux set-option -w -t "$window" @claude_pane "$pane"

# One hook entry per window. The 1000 offset keeps clear of index 0, which a
# plain `set-hook -g window-layout-changed ...` would use.
hook="window-layout-changed[$((1000 + ${window#@}))]"
in_window="#{m:*1*,#{S:#{W:#{?#{==:#{window_id},$window},#{P:#{==:#{pane_id},$pane}},}}}}"
window_exists="#{m:*1*,#{S:#{W:#{==:#{window_id},$window}}}}"

tmux set-hook -g "$hook" \
  "if -F '$in_window' '' { set-hook -ug $hook ; if -F '$window_exists' { select-layout -t $window '$layout' } }"
