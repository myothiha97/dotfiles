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
| `tmux` | Sessions, panes, keymaps, and persistence | `~/.tmux.conf` |
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

- Maple Mono NF at 12.5 pt with macOS font thickening enabled.
- Transparent dark background, blur, and display-P3 output.
- Global quick terminal on `Cmd+Ctrl+L`.
- `Ctrl+I` is distinct from Tab through the CSI-u sequence.
- Selected Command keys are translated to Meta keys for Neovim.
- macOS Option is not globally treated as Alt.

`Cmd+Ctrl+L` is also assigned to Slack in skhd. Keep only one binding if they
conflict on the machine.

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
