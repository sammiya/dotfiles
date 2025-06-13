# ===========================
# Zsh Configuration
# ===========================
# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format
setopt SHARE_HISTORY             # Share history between all sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire a duplicate event first when trimming history
setopt HIST_IGNORE_DUPS          # Do not record an event that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete an old recorded event if a new event is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a previously found event
setopt HIST_IGNORE_SPACE         # Do not record an event starting with a space
setopt HIST_SAVE_NO_DUPS         # Do not write a duplicate event to the history file
setopt HIST_VERIFY               # Do not execute immediately upon history expansion

# ===========================
# Key Bindings
# ===========================
bindkey -e  # Emacs key bindings

# ===========================
# Completion System
# ===========================
autoload -Uz compinit
compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:*:*:*:descriptions' format '%F{green}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'

# ===========================
# Environment Variables
# ===========================
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# ===========================
# Path Configuration
# ===========================
# Add local bin to PATH (for mise and other tools)
export PATH="$HOME/.local/bin:$PATH"

# ===========================
# Aliases
# ===========================
# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ===========================
# Functions
# ===========================
# ghq + fzf repository switcher
function ghq-fzf() {
  local selected_dir=$(ghq list | fzf --height 40% --reverse --border --preview "ghq root && echo '/' && echo {} | sed 's|^|/|'" --preview-window=up:1)
  if [ -n "$selected_dir" ]; then
    BUFFER="cd $(ghq root)/$selected_dir"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq-fzf
bindkey '^]' ghq-fzf

# Git branch switcher with fzf
function fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m \
               --preview "git log --oneline --graph --date=short --color=always --pretty='format:%C(auto)%cd %h%d %s' {1}" \
               --preview-window=right:50%) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# ===========================
# Tool Initialization
# ===========================
# Starship prompt
eval "$(starship init zsh)"

# mise (if installed)
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# GitHub CLI completion (if installed)
if command -v gh &> /dev/null; then
    eval "$(gh completion -s zsh)"
fi

# ===========================
# OS-specific Configuration
# ===========================
case "$OSTYPE" in
    darwin*)
        [ -f ~/.zshrc_Darwin ] && source ~/.zshrc_Darwin
        ;;
    linux-gnu*)
        [ -f ~/.zshrc_Linux ] && source ~/.zshrc_Linux
        ;;
esac

# ===========================
# Local Configuration
# ===========================
# Source local configuration if it exists
[ -f ~/.zshrc_local ] && source ~/.zshrc_local
