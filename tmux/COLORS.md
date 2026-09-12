# tmux status bar colours

Every value tried while building the status bar, kept for reference.
HSL is hue/lightness/saturation, the axes that were actually tuned.

## IN USE

| hex | used for | notes | HSL |
|---|---|---|---|
| `#7aa2f7` | accent: session name, current window, date | tokyonight blue, the original accent | 221/72/89 |
| `#565f89` | inactive windows, clock | tokyonight dim | 229/44/23 |
| `#c0caf5` | status bar default foreground | tokyonight fg | 229/86/73 |
| `default` | status bar background | keeps ghostty background-opacity 0.9 + blur | - |

## Tried and rejected

| hex | what it was | why it went |
|---|---|---|
| `#37f499` | linkarzu's kitty green | too bright on screen (59% light / 90% sat) |
| `#5cbc8e` | muted version of the above | better, but blue was preferred in the end |
| `#bc955c` | muted amber, paired with `#5cbc8e` | reverted with the green |
| `#e0af68` | amber, session name while prefix held | prefix indicator dropped entirely |
| `#9ece6a` | tokyonight green | first powerline attempt |
| `#1a1b26` | tokyonight bg | opaque, killed ghostty's blur; use `default` |
| `#3b4261` | tokyonight border | right-side pill in the powerline version |
| `#4a5a63` | cool grey dim | replaced by `#565f89` |

## Green ladder (151deg, if it ever needs toning down)

| step | hex | light | sat |
|---|---|---|---|
| subtle | `#72c99f` | 62% | 45% |
| muted | `#5cbc8e` | 55% | 42% |
| dim | `#4ba87c` | 48% | 38% |
| dimmest | `#478e6c` | 42% | 33% |

## Blue ladder (221deg, if it ever needs toning down)

| step | hex | light | sat |
|---|---|---|---|
| subtle | `#728ec9` | 62% | 45% |
| muted | `#5c7abc` | 55% | 42% |
| dim | `#4b69a8` | 48% | 38% |
| dimmest | `#475e8e` | 42% | 33% |

## Amber ladder (36deg, if it ever needs toning down)

| step | hex | light | sat |
|---|---|---|---|
| subtle | `#c9a672` | 62% | 45% |
| muted | `#bc955c` | 55% | 42% |
| dim | `#a8824b` | 48% | 38% |
| dimmest | `#8e7147` | 42% | 33% |

## Differences from the pre-2026-09-12 config

Text colours are unchanged. One other thing is not:

- Bar background was `#1a1b26` (opaque). Now `default`, so ghostty's
  `background-opacity = 0.9` and blur show through.

## Reference, not tmux colours

| hex | what |
|---|---|
| `#031219` | ghostty background (`ghostty/config`), 0.9 opacity + blur |
| `#0a0a0a` | linkarzu's kitty background (`active-theme.conf`) |

## Regenerating a ladder

```python
import colorsys

base = "#7aa2f7"
r, g, b = (int(base[i:i+2], 16) / 255 for i in (1, 3, 5))
h, _, _ = colorsys.rgb_to_hls(r, g, b)
# hold the hue, vary lightness and saturation
rr, gg, bb = colorsys.hls_to_rgb(h, 0.55, 0.42)
print("#%02x%02x%02x" % (int(rr * 255), int(gg * 255), int(bb * 255)))
```
