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
| `iina` | Video player key bindings for course playback | `~/Library/Application Support/com.colliderli.iina/input_conf/Custom.conf` |
| `karabiner` | Key remapping, including vim keys inside Finder | `~/.config/karabiner/` |
| `yazi` | Terminal file manager layout and extra keys | `~/.config/yazi/` |
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

mkdir -p ~/.config/yazi
ln -sf ~/.dotfiles/yazi/yazi.toml ~/.config/yazi/yazi.toml
ln -sf ~/.dotfiles/yazi/keymap.toml ~/.config/yazi/keymap.toml
ln -sf ~/.dotfiles/yazi/theme.toml ~/.config/yazi/theme.toml

ln -s ~/.dotfiles/karabiner ~/.config/karabiner

mkdir -p "$HOME/Library/Application Support/lazygit"
ln -sf ~/.dotfiles/lazygit/config.yml \
  "$HOME/Library/Application Support/lazygit/config.yml"

mkdir -p "$HOME/Library/Application Support/com.colliderli.iina/input_conf"
ln -sf ~/.dotfiles/iina/Custom.conf \
  "$HOME/Library/Application Support/com.colliderli.iina/input_conf/Custom.conf"
```

Back up any existing real file before replacing it with a symlink.

The tmux config runs the scripts from `~/.dotfiles/tmux/` by path, so they need
no symlink, but the clone must live at `~/.dotfiles`. The session pickers use
`fzf` and fall back to a plainer menu without it (`brew install fzf`).

Local API keys and tokens belong in `~/.zshenv.local`. This file is sourced by
`zshrc` and must not be committed.

## Yazi

Terminal file manager with vim keys by default. Install it and the preview
helpers with:

```sh
brew install yazi ffmpegthumbnailer sevenzip jq imagemagick resvg
```

Run it with `y` (the zsh function in `zshrc`), not `yazi`, so the shell cds to
the directory you were in when you quit. Built-in keys already cover `j/k/h/l`,
`gg`/`G`, `ctrl-u`/`ctrl-d`, `v` visual mode, and `space` to toggle one file.

`keymap.toml` pulls the rest closer to vim:

- `d` cuts and `x` trashes, swapping yazi's defaults so `d` then `p` moves a
  file the way vim moves text. `X` deletes permanently
- `V` selects whole rows. Yazi's unselect mode moves to `ctrl-v`
- `ctrl-h` and `ctrl-l` leave and enter directories, matching the oil.nvim setup
- `ctrl-e` and `ctrl-y` scroll the preview pane
- `ctrl-v` is unselect visual mode, since `V` now selects
- `F` reveals the hovered file in Finder
- `y` also puts the real files on the macOS clipboard via
  `yazi/clipboard-files.sh`, so `Cmd+V` pastes them in Finder. Yazi's own yank
  is internal to yazi and invisible to other apps
- `ctrl-o` cancels a yank, next to yazi's own `X` and `Y`

Shell commands stay on yazi's defaults: `;` runs one, `:` runs one and waits.

`theme.toml` turns off yazi's mime-based colours for images, media, archives,
and PDFs so file names read as plain white. Directories stay blue, executables
green, and broken symlinks red.

## Karabiner

The whole `~/.config/karabiner` directory is symlinked, not just
`karabiner.json`. Karabiner-Elements rewrites that file whenever you change a
setting in its UI, and an atomic rewrite replaces a symlinked file with a real
one. Linking the directory keeps every write inside the repo.

`automatic_backups/` is gitignored; Karabiner fills it on its own.

The Finder rules give Finder vim motions while it is the frontmost app: `j`/`k`
move, `h`/`l` collapse and expand, `ctrl-d`/`ctrl-u` page, `gg`/`G` jump,
`y`/`p` copy and paste, `v` visual select, `x` trash. `Return` and `/` switch to
an insert mode so typing works for renaming and searching, and `Escape` switches
back.

Rules live in `assets/complex_modifications/` but only take effect once they are
listed in `karabiner.json` under the selected profile, which is what the
Karabiner-Elements UI does under Complex Modifications.

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
| `Cmd+Ctrl+O` | Neovide |
| `Cmd+Ctrl+\`` | YouTube Music |
| `Cmd+Ctrl+,` | IINA |

The helper focuses an existing accessible window or launches the app. If Finder
has no usable window, it opens the home folder.

Enable both services at login:

```sh
yabai --start-service
skhd --start-service
```

Grant both binaries access in **System Settings > Privacy & Security >
Accessibility**. The scripting addition is not used, so SIP remains enabled.

### Space switching on macOS 27

macOS 27 broke Yabai's SIP-enabled space switching
([asmvik/yabai#2822](https://github.com/asmvik/yabai/issues/2822)). Both
`yabai -m space --focus` and `yabai -m display --focus` report success while
doing nothing, so `skip_window_focus_animation` no longer suppresses the slide.

Until that is fixed upstream, `focus-app.sh` changes the Space with
[InstantSpaceSwitcher](https://github.com/jurplel/InstantSpaceSwitcher) and lets
Yabai focus the window afterwards. The macOS 27 fix is still an unmerged pull
request, so the app is built from source:

```sh
git clone https://github.com/jurplel/InstantSpaceSwitcher.git ~/projects/InstantSpaceSwitcher
cd ~/projects/InstantSpaceSwitcher
git fetch origin pull/88/head:macos27
git switch macos27
./dist/build.sh
cp -R build/InstantSpaceSwitcher.app /Applications/
```

The helper calls `ISSCli` inside the bundle, so the menu bar app does not need
to run. `skhd` is the responsible process for the synthetic gesture, so its
Accessibility grant covers it.

Hidden Spaces on an unfocused display still use the native animation, because
Yabai cannot move focus between displays on macOS 27 either.

Remove `/Applications/InstantSpaceSwitcher.app` and drop the `ISS` branch from
`focus-app.sh` once Yabai ships the fix.

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

## IINA

IINA is the default video player, used for watching course videos. `iina/Custom.conf`
is a copy of the bundled `IINA Default` binding set with the speed keys rebound. The
built-in sets live inside the app bundle and cannot be edited, so a full copy is the
supported way to change them.

| Shortcut | Speed change |
| --- | --- |
| `Cmd+]` / `Cmd+[` | Faster or slower by 1.0x |
| `Ctrl+]` / `Ctrl+[` | Faster or slower by 0.5x |
| `Cmd+Ctrl+]` / `Cmd+Ctrl+[` | Faster or slower by 0.25x |
| `Opt+Cmd+]` / `Opt+Cmd+[` | Faster or slower by 10 percent, left at the default |
| `Cmd+\` | Back to 1x |

The defaults multiplied the rate (`Cmd+]` doubled it), which overshoots for lecture
video. These add a flat amount instead, and nothing clamps the result, so repeated
presses will run past any useful speed. `Cmd+\` resets.

The file is inert until it is selected: **Preferences > Key Bindings > Configuration**
must be set to `Custom`. IINA reads the file at that moment and does not watch it
afterwards, so edits made outside the app need the dropdown toggled away and back, or
a restart. Editing bindings inside IINA rewrites the file, which may replace the
symlink with a regular file; check `git status` here after doing that.

Playlist behaviour for a course folder is set under **Preferences > General**: turn on
`Add files in the same folder automatically` and `Play next item automatically`, plus
`Resume last playback position` to continue a part-watched video. Those are app
preferences, not part of this config file, so they are not tracked here.

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
