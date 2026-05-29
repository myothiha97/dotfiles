# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/mtkh97/.zsh/completions" $fpath)
autoload -Uz compinit
compinit
# OPENSPEC:END

ZVM_CURSOR_STYLE_ENABLED=false
# 1. Instant Prompt (Keep at very top for speed)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Theme
source ~/.powerlevel10k/powerlevel10k.zsh-theme

# Completion System
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi
autoload -Uz compinit && compinit -u

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:options' description yes
zstyle ':completion:*' verbose yes

# COLUMNAR LAYOUT (fixes the long vertical list)
zstyle ':completion:*' list-packed true
zstyle ':completion:*' list-dirs-first true

# Case-insensitive path completion + partial matching
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Key Bindings - Tab for completion (no autosuggestions)
bindkey '^I' complete-word        # Tab = complete
bindkey '^[[Z' reverse-menu-complete  # Shift+Tab = reverse through menu

# Autosuggestions (ghost text)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^L' autosuggest-accept
# bindkey '^;' autosuggest-accept

bindkey '^[^[' autosuggest-clear  # Double-tap Esc to clear

# Environment & Tools
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"


# alias
alias vim='nvim'
alias vm='nvim'
alias v="nvim"
alias pn='pnpm'
alias lgit='lazygit'
# Copy current branch name to clipboard
alias copybr="git branch --show-current | pbcopy"
# alias clh='history -p && :> ~/.zsh_history && exec $SHELL'

clear-screen-widget() {
    # 'clear' wipes the terminal view and scrollback without touching history files
    # This keeps zsh-autosuggestions working perfectly
    clear
    
    # Redraw the prompt at the top of the screen
    zle reset-prompt
}

# 2. Register and bind to Ctrl+f
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

# Local-only secrets (API keys, tokens). File lives outside ~/.dotfiles, never committed.
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

