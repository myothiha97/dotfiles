# dotfiles

Personal macOS terminal and window-management configuration. Files are tracked here
and symlinked to their live locations.

## Included configuration

| Folder | Purpose | Live location |
| --- | --- | --- |
| `ghostty` | Terminal appearance, rendering, and key translation | `~/.config/ghostty/config` |
| `yabai` | Floating window manager and app-focus helper | `~/.config/yabai/` |
| `skhd` | Global app-focus shortcuts | `~/.config/skhd/skhdrc` |
| `aerospace` | Disabled floating-only fallback config | `~/.config/aerospace/aerospace.toml` |
| `tmux` | Sessions, panes, keymaps, session scripts, and persistence | `~/.tmux.conf` |
| `lazygit` | Faster log ordering and UI layout | `~/Library/Application Support/lazygit/config.yml` |
| `zshrc` | Shell completion, aliases, tools, and prompt | `~/.zshrc` |

Neovim is maintained separately at
[`~/.config/nvim`](https://github.com/myothiha97/nvim).

## Setup

```sh
git clone git@github.com:myothiha97/dotfiles.git ~/.dotfiles

ln -sf ~/.dotfiles/zshrc ~/.zshrc
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

mkdir -p ~/.config/ghostty ~/.config/aerospace ~/.config/yabai ~/.config/skhd
ln -sf ~/.dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/.dotfiles/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
ln -sf ~/.dotfiles/yabai/yabairc ~/.config/yabai/yabairc
ln -sf ~/.dotfiles/yabai/focus-app.sh ~/.config/yabai/focus-app.sh
ln -sf ~/.dotfiles/skhd/skhdrc ~/.config/skhd/skhdrc

mkdir -p "$HOME/Library/Application Support/lazygit"
ln -sf ~/.dotfiles/lazygit/config.yml \
  "$HOME/Library/Application Support/lazygit/config.yml"
```

Back up any existing real file before replacing it with a symlink.

The tmux config runs the scripts from `~/.dotfiles/tmux/` by path, so they need
no symlink, but the clone must live at `~/.dotfiles`. The session pickers use
`fzf` and fall back to a plainer menu without it (`brew install fzf`).

Local API keys and tokens belong in `~/.zshenv.local`. This file is sourced by
`zshrc` and must not be committed.

## Yabai and skhd

Yabai runs in floating mode. It does not tile or resize windows. It is used to
focus applications across native macOS Spaces without the normal Space animation.

| Shortcut | App |
| --- | --- |
| `Cmd+Ctrl+H` | Google Chrome |
| `Cmd+Ctrl+I` | Safari |
| `Cmd+Ctrl+J` | Ghostty |
| `Cmd+Ctrl+K` | Finder |
| `Cmd+Ctrl+L` | Slack |
| `Cmd+Ctrl+\`` | YouTube Music |

The helper focuses an existing accessible window or launches the app. If Finder
has no usable window, it opens the home folder.

Enable both services at login:

```sh
yabai --start-service
skhd --start-service
```

Grant both binaries access in **System Settings > Privacy & Security >
Accessibility**. The scripting addition is not used, so SIP remains enabled.

AeroSpace is retained as a fallback but has `start-at-login = false`.

## Ghostty

- FiraCode Nerd Font at 13.7 pt with macOS font thickening enabled.
- Transparent dark background (`#031219`, opacity 0.9), blur, and display-P3 output.
- Global quick terminal on `Cmd+Ctrl+L`.
- `Ctrl+I` is distinct from Tab through the CSI-u sequence.
- Selected Command keys are translated to Meta keys for Neovim.
- Cmd+`n`/`p` and Cmd+`1`-`9` are translated for tmux session switching (see below).
- macOS Option is not globally treated as Alt.

`Cmd+Ctrl+L` is also assigned to Slack in skhd. Keep only one binding if they
conflict on the machine.

The config carries long comments on the stroke-weight dial (`font-thicken`) and
on why the session-switch keys use those exact escape sequences. Read them before
changing either.

## tmux

The prefix is `Ctrl+Space`.

| Keys after prefix | Action |
| --- | --- |
| `v` / `e` | Split left-right / top-bottom in the current path |
| `h` `j` `k` `l` | Move between panes |
| `Ctrl+h/j/k/l` | Resize panes |
| `n` / `p` / `Tab` | Next, previous, or last window |
| `c` | Create a window in the current path |
| `Enter` | Enter copy mode |
| `x` / `X` / `Q` | Kill pane, window, or session |
| `r` | Reload the configuration |

### Session switching

Sessions are numbered from 1 in creation order, oldest first.
`tmux/list-sessions.sh` is the single source of truth for that order, so the
pickers and the number shortcuts always agree. tmux's own ordering is by name,
which would reshuffle whenever a session is renamed.

| Keys after prefix | Action |
| --- | --- |
| `s` | Session picker, no search field: `j`/`k`, `Ctrl+n`/`Ctrl+p`, arrows, or digits `1`-`9`. `x` or `Ctrl+x` kills the row under the cursor |
| `f` | Session picker with a search field: everything types, arrows and `Ctrl+n`/`Ctrl+p` move, `Ctrl+x` kills |
| `S` | Built-in `choose-tree` |
| `Cmd+1` ... `Cmd+9` | Jump to a session by position |
| `Cmd+n` / `Cmd+p` | Cycle to the next or previous session |

Both pickers are fzf in a popup, sharing one look. Both open with the cursor
on the session you are in, which is marked `*`, and that row carries a faint
band (`#0d2a38`) run to the popup edge so it reads without a pointer column.

The popup sets no background, so the terminal's shows through and Ghostty's
opacity and blur reach it. Its border is dimmed to `#3b4261`, the inactive
pane-border colour: tmux defaults the frame to the terminal foreground, and that
bright white ring competes with the session names inside it.

Killing a session is `Ctrl+x` in both, and `s` takes a plain `x` as well, since
it has no field competing for the key. In `f` a plain `x` has to stay typable,
or no session with an `x` in its name could be searched for. Either key asks for
`y`/`n` first, and refuses on the current session, whose client the popup runs
in, and on the last remaining session, which would stop the server.

`choose-tree` is not used for them because its row keys start at 0 and cannot
be rebased, and `display-menu` hardcodes its navigation keys. Without fzf
installed, the pickers fall back to `tmux/session-menu.sh`, a `display-menu`
version.

The Cmd shortcuts work because tmux has no Super modifier: `ghostty/config`
translates Cmd+`<digit>` into the Ctrl+`<digit>` extended-key sequence and
Cmd+`n`/`p` into `M-n`/`M-p`. The key pressed is Cmd, the key tmux matches is
Ctrl or Alt. Ghostty cannot tell whether the prefix was just pressed, so these
fire on every Cmd+key; outside the prefix tmux forwards them to the running
program.

Scripts in `tmux/`:

| Script | Role |
| --- | --- |
| `list-sessions.sh` | Session names in creation order; the shared numbering |
| `session-picker.sh` | fzf popup picker, `select` and `search` modes |
| `session-rows.sh` | The picker's numbered rows; rerun to refresh after a kill |
| `kill-session.sh` | Confirm and kill the session behind a picker row |
| `session-menu.sh` | `display-menu` fallback when fzf is missing |
| `switch-session.sh` | Jump to the session at a given position |
| `cycle-session.sh` | Move to the next or previous session, wrapping |

### Status bar

Plain text, no powerline pills: session name on the left, clock and date on the
right, windows as `<index>:<name>`. The background is `default` rather than a
hex colour so Ghostty's opacity and blur show through. Colours are tokyonight
blue `#7aa2f7` for the accent, `#565f89` for dim text, `#c0caf5` for the
default foreground. `tmux/COLORS.md` records every colour tried, why the
rejected ones went, and how to regenerate a lighter or darker ladder.

### Plugins

TPM manages `tmux-resurrect` and `tmux-continuum`. Sessions auto-save every 15
minutes and restore when tmux starts. Install plugins with `Prefix+I` after TPM is
installed at `~/.tmux/plugins/tpm`.

## zsh and lazygit

Useful aliases include `vim`/`vi` for Neovim, `g` for Git, `lg` for Lazygit,
`pn` for pnpm, `tm` for tmux, and `cc` for Claude Code. `copybr` copies the current
Git branch name.

Lazygit uses Git's default commit order to avoid slow full-history sorting. Its
command log is hidden, the focused side panel expands, and delta paging remains
disabled because it was unstable.

Lazygit's `state.yml` is intentionally not tracked because it contains changing
runtime state.

## Adding another config

1. Move the live file into an app folder in `~/.dotfiles`.
2. Symlink it back to its live location.
3. Commit the tracked file and README change.

See `notes.md` for known issues and deferred work.
