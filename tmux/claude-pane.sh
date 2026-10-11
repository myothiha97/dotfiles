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
# The layout is only restored while the window has the same number of panes as
# before Claude opened. Otherwise it no longer fits, select-layout would fail
# halfway, and tmux keeps its default resize instead.
#
# The window may have changed size since the layout was saved (for example the
# terminal was resized). select-layout applies a smaller layout as is, leaving
# the panes small inside a bigger window, so the restore first resizes the
# window to the saved size, applies the layout, then unsets the window-size
# option that resize-window forces to manual. tmux then fits the window back to
# the client and scales the panes the same way as a normal terminal resize.
#
# Usage: claude-pane.sh <window-id> <start-dir>

set -euo pipefail

window=${1:?missing window id}
start_dir=${2:-$HOME}

read -r layout width height panes < <(tmux display-message -p -t "$window" \
  '#{window_layout} #{window_width} #{window_height} #{window_panes}')
pane=$(tmux split-window -t "$window" -fh -l 35% -c "$start_dir" -P -F '#{pane_id}' \
  claude --model claude-sonnet-5-5 --effort medium)

# Lets the key binding see that this window already has its Claude pane.
tmux set-option -w -t "$window" @claude_pane "$pane"

# One hook entry per window. The 1000 offset keeps clear of index 0, which a
# plain `set-hook -g window-layout-changed ...` would use.
hook="window-layout-changed[$((1000 + ${window#@}))]"
in_window="#{m:*1*,#{S:#{W:#{?#{==:#{window_id},$window},#{P:#{==:#{pane_id},$pane}},}}}}"
window_exists="#{m:*1*,#{S:#{W:#{==:#{window_id},$window}}}}"
layout_fits="#{m:*1*,#{S:#{W:#{&&:#{==:#{window_id},$window},#{==:#{window_panes},$panes}}}}}"

tmux set-hook -g "$hook" \
  "if -F '$in_window' '' { set-hook -ug $hook ; if -F '$window_exists' { set-option -uw -t $window @claude_pane } ; if -F '$layout_fits' { resize-window -t $window -x $width -y $height ; select-layout -t $window '$layout' ; set-option -uw -t $window window-size } }"

# Claude may already have exited (for example it failed to start) before the
# hook was set. Its layout change is then missed, so drop the hook now rather
# than let it restore an old layout on some later change.
if ! tmux list-panes -t "$window" -F '#{pane_id}' 2>/dev/null | grep -qxF "$pane"; then
  tmux set-hook -ug "$hook"
  tmux set-option -uw -t "$window" @claude_pane 2>/dev/null || true
fi
