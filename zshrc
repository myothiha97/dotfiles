# Change policy
# Runs on every new shell and tmux pane: startup speed and stability come first.
#   - Perf: measure with `time zsh -i -c exit`. Lazy-load slow tools (see nvm).
#     No heavy work in precmd, preexec or zle widgets.
#   - No regressions: keep `bindkey -e` above other bindkeys and plugin sources.
#     Test in tmux (inherits EDITOR=nvim) and in a fresh terminal:
#       EDITOR=nvim zsh -i -c "bindkey '^P'"
#       env -u EDITOR -u VISUAL zsh -i -c "bindkey '^P'"
#   - Minimal: smallest change that works, with one short comment saying why.

# Dedupe PATH. Panes and nested shells inherit it, so each prepend would repeat
# entries. -U keeps the first copy.
typeset -U path PATH

# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/mtkh97/.zsh/completions" $fpath)
# NOTE: no compinit here, it runs once below.
# OPENSPEC:END

ZVM_CURSOR_STYLE_ENABLED=false
# p10k instant prompt, keep near the top for speed
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Emacs keymap always. Otherwise zsh picks vi mode when EDITOR=nvim is inherited
# (tmux) and ^P/^N stop cycling history.
bindkey -e

# Theme
source ~/.powerlevel10k/powerlevel10k.zsh-theme

# Completion
if type brew &>/dev/null; then
  # Read HOMEBREW_PREFIX (from ~/.zprofile) instead of running brew (~24ms per shell).
  BREW_PREFIX=${HOMEBREW_PREFIX:-$(brew --prefix)}
  FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

# Tab completion, no live list. zsh-autocomplete was uninstalled (`brew uninstall
# zsh-autocomplete`, nothing depended on it) because it ran completion on every
# keystroke. To restore: `brew install zsh-autocomplete`, source its plugin here,
# and drop the compinit call (the plugin runs it).
# compinit: -C skips the security scan, -i silences insecure-dir prompts.
# No -D: it forces a full fpath rescan on every shell start.
autoload -Uz compinit
compinit -i -C -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compdump"

# Completion styling.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:options' description yes
zstyle ':completion:*' list-packed true
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**'

# Cache slow completions to disk.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/compcache

# Autosuggestions (ghost text).
# History only: the 'completion' strategy would run completion on every keystroke.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80          # skip very long lines
[[ -r $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^L' autosuggest-accept
# bindkey '^;' autosuggest-accept

bindkey '^[^[' autosuggest-clear  # Double-tap Esc to clear

# Environment & Tools

# nvm, lazy-loaded: nvm.sh costs ~0.6s per shell. Only the default Node goes on
# PATH here. nvm.sh loads on the first `nvm` call, or eagerly if the default
# alias does not resolve to an installed version (e.g. "lts/*").
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
() {
  local default_alias
  [[ -r $NVM_DIR/alias/default ]] && default_alias=$(<"$NVM_DIR/alias/default")
  # "22" or "v22.22.0" -> newest matching install (n = numeric sort, On = descending)
  local -a node_bin=("$NVM_DIR"/versions/node/v${default_alias#v}(|.*)/bin(N/nOn[1]))
  if [[ -n $default_alias && -n $node_bin ]]; then
    path=("$node_bin[1]" $path)
    nvm() { unset -f nvm; source "$NVM_DIR/nvm.sh"; nvm "$@"; }
  else
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  fi
}
export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# alias
alias vim='nvim'
alias vi="nvim"
alias v="nvim"

alias pn='pnpm'
alias lgit='lazygit'
alias g="git"
alias lg="lazygit"
alias cl="claude" # cl = alias for claude code
alias tm="tmux"
# yazi: `f` cds to where you quit (plain `yazi` does not). `q` quits and cds,
# `Q` quits and stays put.
function f() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Copy current branch name to clipboard
alias copybr="git branch --show-current | pbcopy"
# alias clh='history -p && :> ~/.zsh_history && exec $SHELL'

clear-screen-widget() {
    # 'clear' wipes the view and scrollback but keeps history, so autosuggestions still work
    clear
    
    # Redraw the prompt at the top
    zle reset-prompt
}

# Bind to Ctrl+O
zle -N clear-screen-widget
bindkey '^O' clear-screen-widget 

# Load p10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# pnpm
export PNPM_HOME="/Users/mtkh97/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# User scripts
export PATH="$HOME/.scripts:$PATH"

# go bin
export PATH="$PATH:$HOME/go/bin"

# Local-only secrets (API keys, tokens), kept outside the repo.
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# Claude Code accounts
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'
alias clw='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

# =============================================================================
# MAINTENANCE NOTES (measured 2026-09-19)
# Known quirks. Not urgent, but they save debugging time.
# =============================================================================
#
# 1. The OPENSPEC block at the top may be regenerated with a 'compinit' call
#    before fpath is complete. Delete any compinit it adds. Only the one
#    below should run.
#
# 2. nvm is lazy-loaded (2026-10-07). nvm.sh was ~0.6s of the ~0.9s to first
#    prompt in every pane. `nvm use` works as before. Volta (~/.zshenv) is
#    also installed, but nvm's Node comes first on PATH.
#
# 3. Dead settings, harmless:
#    - LS_COLORS is empty here, so the list-colors style does nothing.
#      Fix: populate it first, e.g. with gdircolors from coreutils.
#    - ZVM_CURSOR_STYLE_ENABLED does nothing, zsh-vi-mode is not loaded.
#
# 4. compinit uses -C (no security scan; 'compaudit' was clean when set), so a
#    world-writable completion dir will not warn. New completions appear only
#    after: rm ~/.cache/zsh/compdump
#
# 5. Never add -D to compinit: it forces a full fpath rescan on every start
#    (1.27s cold vs 0.87s warm).


# Added by Antigravity CLI installer
export PATH="/Users/mtkh97/.local/bin:$PATH"
