#!/usr/bin/env bash
# Print session names in creation order, oldest first.
#
# This is the single source of truth for session numbering. Both
# session-menu.sh and switch-session.sh use it so the numbers shown in the
# picker always match the prefix + Ctrl + <number> shortcuts.
#
# tmux's own `list-sessions` sorts by name, which reshuffles the numbering
# whenever a session is renamed, so sort on #{session_created} instead.
# Sessions made within the same second tie-break on name to stay deterministic.

set -euo pipefail

tmux list-sessions -F '#{session_created} #{session_name}' \
  | sort -t' ' -k1,1n -k2,2 \
  | cut -d' ' -f2-
