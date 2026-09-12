#!/usr/bin/env bash
# Switch a client to the Nth session (1-based) in tmux's session list.
#
# tmux has no positional session target, so the index is resolved against
# list-sessions.sh, which orders sessions by creation time. That is the same
# order session-menu.sh numbers, so the two stay in sync.
#
# Usage: switch-session.sh <index> [client-tty]

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

index=${1:?missing session index}
client=${2:-}

name=$("$script_dir/list-sessions.sh" | sed -n "${index}p")

if [ -z "$name" ]; then
  tmux display-message "No session #${index}"
  exit 0
fi

# "=" forces an exact name match instead of tmux's prefix matching.
if [ -n "$client" ]; then
  tmux switch-client -c "$client" -t "=$name"
else
  tmux switch-client -t "=$name"
fi
