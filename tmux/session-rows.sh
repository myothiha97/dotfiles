#!/usr/bin/env bash
# Print the picker's rows: creation-order number, session name, and a "*" on
# the session the caller is in.
#
# Split out of session-picker.sh because the picker rebuilds this list after a
# kill, and fzf's reload needs a command it can run on its own.

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

current=$(tmux display-message -p '#S')

"$script_dir/list-sessions.sh" | awk -v cur="$current" '
  { printf "%d  %s%s\n", NR, $0, ($0 == cur ? "  *" : "") }'
