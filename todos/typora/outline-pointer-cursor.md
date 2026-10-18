# Pointer cursor on outline items

Requested 2026-10-17. Hovering an item in the outline sidebar shows the arrow
cursor; the wish is the hand (pointer) cursor.

Deferred by the change gate: a look tweak, clicking works today.

Notes for later:

- Typora's `base.css` already sets `cursor: pointer` on `.outline-item` and
  `.outline-label`, and `github-dark.css` sets no cursor, so something else wins.
  Find it in Typora's devtools before adding a rule; no guess fix.
- Likely fix is one rule in `typora/themes/github-dark.css`. Typora's own
  sidebar uses `cursor: default` on purpose (native macOS feel), so keep the
  change to the outline only.
