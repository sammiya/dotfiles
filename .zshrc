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
# starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# mise
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# GitHub CLI completion
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
