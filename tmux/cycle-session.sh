#!/usr/bin/env bash
# Switch a client to the next or previous session, wrapping at the ends.
#
# tmux's own `switch-client -n/-p` cycles in tmux's internal (name-sorted)
# order, which would disagree with the creation order used by session-menu.sh
# and switch-session.sh. Walk list-sessions.sh instead so all three agree.
#
# Usage: cycle-session.sh next|prev [client-tty]

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

direction=${1:?missing direction (next|prev)}
client=${2:-}

case "$direction" in
  next|prev) ;;
  *) echo "direction must be 'next' or 'prev'" >&2; exit 2 ;;
esac

list=$("$script_dir/list-sessions.sh")
count=$(printf '%s\n' "$list" | wc -l | tr -d ' ')

if [ "$count" -le 1 ]; then
  tmux display-message "Only one session"
  exit 0
fi

# Resolve the client's current session. A client tty is passed in from the key
# binding so the right client moves when several are attached.
if [ -n "$client" ]; then
  current=$(tmux list-clients -F '#{client_tty} #{client_session}' \
    | awk -v t="$client" '$1 == t { print $2; exit }')
else
  current=$(tmux display-message -p '#S')
fi

# -x matches the whole line, so a session named "bp" cannot match "bp-staging".
index=$(printf '%s\n' "$list" | grep -nxF "$current" | cut -d: -f1 || true)

if [ -z "$index" ]; then
  index=1
fi

if [ "$direction" = "next" ]; then
  target=$(( index % count + 1 ))
else
  target=$(( (index - 2 + count) % count + 1 ))
fi

name=$(printf '%s\n' "$list" | sed -n "${target}p")

if [ -n "$client" ]; then
  tmux switch-client -c "$client" -t "=$name"
else
  tmux switch-client -t "=$name"
fi
