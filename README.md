# dotfiles

Personal macOS development environment config, tracked in git and applied via symlinks.

Each app lives in its own folder here; the real config location is a symlink pointing
back into this repo. Edit files in place — changes are reflected live and tracked by git.

## What's inside

| Folder    | Tracked file   | Symlinked to                                          |
| --------- | -------------- | ----------------------------------------------------- |
| `ghostty` | `config`       | `~/.config/ghostty/config`                            |
| `aerospace` | `aerospace.toml` | `~/.config/aerospace/aerospace.toml`              |
| `yabai`   | `yabairc`, `focus-app.sh` | `~/.config/yabai/`                         |
| `skhd`    | `skhdrc`       | `~/.config/skhd/skhdrc`                               |
| `tmux`    | `.tmux.conf`   | `~/.tmux.conf`                                         |
| `lazygit` | `config.yml`   | `~/Library/Application Support/lazygit/config.yml`     |
| `zshrc`   | `zshrc`        | `~/.zshrc`                                             |

> Neovim config is maintained separately at [`~/.config/nvim`](https://github.com/myothiha97).

> Note: lazygit's `state.yml` is intentionally **not** tracked — it's runtime state
> (recent repos, window layout) that churns on every launch.

## Setup on a new machine

```sh
git clone git@github.com:myothiha97/dotfiles.git ~/.dotfiles

ln -sf ~/.dotfiles/zshrc           ~/.zshrc
ln -sf ~/.dotfiles/tmux/.tmux.conf ~/.tmux.conf

mkdir -p ~/.config/ghostty
ln -sf ~/.dotfiles/ghostty/config  ~/.config/ghostty/config

mkdir -p ~/.config/aerospace ~/.config/yabai ~/.config/skhd
ln -sf ~/.dotfiles/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
ln -sf ~/.dotfiles/yabai/yabairc ~/.config/yabai/yabairc
ln -sf ~/.dotfiles/yabai/focus-app.sh ~/.config/yabai/focus-app.sh
ln -sf ~/.dotfiles/skhd/skhdrc ~/.config/skhd/skhdrc

mkdir -p "$HOME/Library/Application Support/lazygit"
ln -sf ~/.dotfiles/lazygit/config.yml "$HOME/Library/Application Support/lazygit/config.yml"
```

If a target already exists as a real file, back it up first (`mv ~/.zshrc ~/.zshrc.bak`)
before creating the symlink.

## Adding a new config

1. Move the real config into a folder here: `mv <live-config> ~/.dotfiles/<app>/`
2. Symlink it back to its live location: `ln -s ~/.dotfiles/<app>/<file> <live-config>`
3. Commit it.

See `notes.md` for outstanding issues / tweaks.
