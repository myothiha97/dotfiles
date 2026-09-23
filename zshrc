# OPENSPEC:START
# OpenSpec shell completions configuration
fpath=("/Users/mtkh97/.zsh/completions" $fpath)
# NOTE: no compinit here. zsh-autocomplete runs compinit itself (see below).
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
  BREW_PREFIX=$(brew --prefix)
  FPATH=$BREW_PREFIX/share/zsh-completions:$FPATH
fi

# Real-time completion list below the cursor (fish style).
# zsh-autocomplete owns compinit, so it must be sourced before any compdef call
# and no compinit may run before it.
#
# Performance guards. These must be set BEFORE sourcing the plugin.
# Autocomplete runs the completion system on every keystroke, so without these
# it can feel laggy in big repos or directories with many files.
zstyle ':autocomplete:*' min-input 2        # stay quiet until 2 characters are typed
zstyle ':autocomplete:*' delay 0.1          # only fetch after typing pauses (seconds)
zstyle ':autocomplete:*' timeout 1          # drop slow completers instead of blocking (seconds)
zstyle ':autocomplete:*' list-lines 15      # cap the real-time listing height.
                                            # Blank lines, group headers and the (MORE)
                                            # marker all count, and each extra group
                                            # costs 2 lines, so this gives roughly
                                            # 12 items at 1 group and 8 at 3 groups.
                                            # Does NOT apply once you enter the menu
                                            # with Down / Ctrl+N; that is zsh's own
                                            # menu-select and always uses the screen.
# ignored-input is a pattern matched against the word you are currently typing.
# When it matches, the plugin sets compstate[list]= and shows nothing.
# Using the 'zstyle -e' (evaluated) form lets the pattern depend on the whole
# line, because $words is in scope when the plugin reads this style. Returning
# '*' matches any current word, which suppresses the list entirely.
#   - after 'git add': show nothing (file lists here are noise)
#   - otherwise: skip only bare '..', '...' and longer dot runs
zstyle -e ':autocomplete:*' ignored-input '
  if [[ ${words[1]:-} == (git|g) && ${words[2]:-} == add ]]; then
    reply=( "*" )
  else
    reply=( "..##" )
  fi'
# compinit arguments. -C skips the slow per-file security scan, -i silences any
# insecure-directory prompt. Do NOT add -D here (the README's example includes it):
# -D disables writing the completion dump, which forces a full fpath rescan on
# every single shell start. -w only adds diagnostic noise to the prompt.
zstyle '*:compinit' arguments -i -C
[[ -r $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh ]] &&
  source $BREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Completion styling. Set after the plugin so these win over its defaults.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:options' description yes
zstyle ':completion:*' list-packed true
zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' matcher-list 'm:{[:lower:]-}={[:upper:]_}' '+r:|[.]=**'

# Blank line above each group header, so groups are visually separated.
# zsh-autocomplete wires ':completion:*:descriptions' with 'zstyle -e', which
# evaluates this function at completion time, so redefining it here overrides
# the plugin's version. The $'\n' is what creates the gap; the escape codes are
# the plugin's own dim-bold header styling, kept as-is.
autocomplete:config:format() {
  reply=( $'\n%{\e[0;1;2m%}'$1$'%{\e[0m%}' )
}

# Cache slow completions (brew formulas, git config keys, etc.) to disk.
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh/compcache

# Tab / Shift+Tab / arrow keys are bound by zsh-autocomplete. Do not rebind '^I'
# or '^[[Z' here, or the real-time menu stops working.

# Autosuggestions (ghost text).
# Strategy is history only: the 'completion' strategy runs the completion system
# a second time per keystroke, which duplicates zsh-autocomplete's work.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666"
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80          # skip suggesting only for very long lines
[[ -r $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
  source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^L' autosuggest-accept
# bindkey '^;' autosuggest-accept

bindkey '^[^[' autosuggest-clear  # Double-tap Esc to clear

# Environment & Tools
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="/opt/homebrew/opt/ruby@3.2/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# alias
alias vim='nvim'
alias vi="nvim"

alias pn='pnpm'
alias lgit='lazygit'
alias g="git"
alias lg="lazygit"
alias cc="claude" # cc = alias for claude code 
alias tm="tmux"
# yazi: `y` opens the file manager, and on quit the shell follows the directory
# you ended up in (plain `yazi` leaves you where you started). `q` quits and
# cds, `Q` quits and stays put.
function y() {
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

# go bin
export PATH="$PATH:$HOME/go/bin"

# Local-only secrets (API keys, tokens). File lives outside ~/.dotfiles, never committed.
[ -f ~/.zshenv.local ] && source ~/.zshenv.local

# Claude Code accounts
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

# =============================================================================
# MAINTENANCE NOTES
# Known quirks in this file. None of these are bugs to fix urgently, but they
# will save you debugging time later. Measured on 2026-09-19.
# =============================================================================
#
# 1. Esc-Esc has a 0.4s delay.
#    'bindkey ^[^[ autosuggest-clear' below binds a sequence that is a strict
#    prefix of the Alt+Up / Alt+Down sequences zsh-autocomplete binds
#    (^[^[[A and ^[^[[B). zsh must wait $KEYTIMEOUT (40, meaning 0.4s) to see
#    which one you meant. Both keys work, Esc-Esc just feels slow.
#    To fix: rebind autosuggest-clear to something that is not an Esc prefix.
#
# 2. The OPENSPEC block at the top is a landmine.
#    If the OpenSpec tool ever regenerates it, it re-adds a 'compinit' call.
#    zsh-autocomplete must own compinit, so that would break completion.
#    If completion misbehaves after an OpenSpec update, check the top of
#    this file first and delete any compinit line it added back.
#
# 3. nvm is the slowest thing here.
#    Sourcing nvm.sh costs ~0.40s of the ~0.87s time to first prompt.
#    p10k is only ~0.02s, so the theme is not the problem.
#    To fix: lazy-load nvm (define a shim that sources nvm.sh on first use).
#
# 4. Two dead settings, harmless but misleading.
#    - LS_COLORS is empty on this machine, so the ':completion:*' list-colors
#      line above expands to nothing and completion lists are uncoloured.
#      To fix: populate LS_COLORS first, e.g. with gdircolors from coreutils.
#    - ZVM_CURSOR_STYLE_ENABLED at the top does nothing, zsh-vi-mode is not
#      loaded anywhere in this file.
#
# 5. compinit runs with -C, which skips the security scan.
#    'compaudit' was clean when this was set. If you later install something
#    that creates a world-writable completion directory, you will NOT be
#    warned. Also, newly installed completions only appear after the dump is
#    invalidated: rm ~/.cache/zsh/compdump
#
# 6. Do not add -D to the compinit arguments.
#    The zsh-autocomplete README suggests '-D -i -u -C -w'. The -D disables
#    writing the completion dump, which forces a full fpath rescan on every
#    shell start (measured: 1.27s cold vs 0.87s warm). -w only adds the
#    "regenerating" noise you see at the prompt.
