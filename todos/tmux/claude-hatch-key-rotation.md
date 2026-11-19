# Rotate prefix + y / u / i

Requested 2026-11-19. Deferred by the change gate (rebinding keys), then
made by choice on request the same day.

Wanted:

- prefix + u: hatch popup (today prefix + y)
- prefix + i: agent picker (today prefix + u)
- prefix + y: `display-message` (today prefix + i, tmux default)

How: `set -g @claude_launch_key 'u'` and `set -g @claude_list_key 'i'` before
the hatch `@plugin` line, plus `bind y display-message`. Update the key
comments at lines ~144 and ~285. No hot-path cost
(plain binds). A reload is enough: all three keys get a new binding, so
source-file replaces the old ones.
