# ===========================
# History
# ===========================

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

setopt share_history
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt extended_history

autoload -U compinit
compinit -i

# ===========================
# Key Bindings
# ===========================

bindkey -e

# ===========================
# Tool Initialization
# ===========================a

# fzf
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# starship
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# mise
if [ -x "$HOME/.local/bin/mise" ]; then
    eval "$("$HOME/.local/bin/mise" activate zsh)"
    # Add tool to shared (dotfiles-managed) config
    alias mise-shared='mise use --path ~/.config/mise/conf.d/00-shared.toml'
fi

# GitHub CLI completion
if command -v gh &> /dev/null; then
    eval "$(gh completion -s zsh)"
fi

# ===========================
# Functions
# ===========================

# gitingest to clipboard
if command -v gitingest &> /dev/null; then
  function gic() {
    case "$1" in
      -h|--help)
        cat <<'USAGE'
Usage: gic [path]

Run gitingest on the given path (default: .) and copy the output to clipboard.

Arguments:
  [path]    Target directory (default: current directory)

Options:
  -h, --help    Show this help
USAGE
        return 0
        ;;
    esac

    local target="${1:-.}"

    if [[ ! -d "$target" ]]; then
      echo "Error: '$target' is not a directory" >&2
      return 1
    fi

    gitingest "$target" -o - | pbcopy || return 1
    echo "Copied gitingest output of '$target' to clipboard"
  }
fi

# Save clipboard content to a file
function pbsave() {
  case "$1" in
    -h|--help)
      cat <<'USAGE'
Usage: pbsave [filename]

Save clipboard content to a file in the current directory.
If filename is omitted, defaults to "paste" (paste.md, paste-1.md, paste-2.md, ...).
If filename has no extension, MIME type is auto-detected to determine one.

Arguments:
  [filename]    Output filename (default: paste)

Options:
  -h, --help    Show this help

MIME → Extension mapping:
  text/html         → .html
  application/json  → .json
  text/xml          → .xml
  application/xml   → .xml
  (other)           → .md
USAGE
      return 0
      ;;
  esac

  local content
  content=$(pbpaste)

  if [[ -z "$content" ]]; then
    echo "Error: clipboard is empty" >&2
    return 1
  fi

  local name="${1:-paste}"

  # Add extension if filename has none
  if [[ "$name" != *.* ]]; then
    local mime
    mime=$(printf '%s' "$content" | file -b --mime-type -)
    case "$mime" in
      text/html)        name="${name}.html" ;;
      application/json) name="${name}.json" ;;
      text/xml|application/xml) name="${name}.xml" ;;
      *)                name="${name}.md" ;;
    esac
  fi

  # Avoid overwriting: paste.md -> paste-1.md -> paste-2.md ...
  if [[ -e "$name" ]]; then
    local base="${name%.*}" ext="${name##*.}"
    local i=1
    while [[ -e "${base}-${i}.${ext}" ]]; do
      (( i++ ))
    done
    name="${base}-${i}.${ext}"
  fi

  printf '%s' "$content" > "$name"
  echo "Saved clipboard to $name"
}

# Git branch switcher with fzf
if command -v git &> /dev/null && command -v fzf &> /dev/null; then
  function fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
             fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m \
                 --preview "git log --oneline --graph --date=short --color=always --pretty='format:%C(auto)%cd %h%d %s' {1}" \
                 --preview-window=right:50%) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
  }
fi

# ghq + fzf repository switcher
if command -v ghq &> /dev/null && command -v fzf &> /dev/null; then
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
fi

# mktouch - Create a file and its parent directories if they don't exist
function mktouch() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: mktouch <file_path>"
    return 1
  fi

  local file="$1"
  local dir=$(dirname "$file")

  # Create directory if it doesn't exist
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi

  # Create the file
  touch "$file"
}

# ghstart - Create GitHub repo and cd into it
if command -v gh &> /dev/null && command -v ghq &> /dev/null; then
  function ghstart() {
    local visibility="--private"
    local -a gh_extra=()

    while [[ $# -gt 0 ]]; do
      case "$1" in
        -P|--public) visibility="--public"; shift ;;
        --)          shift; gh_extra=("$@"); break ;;
        -h|--help)
          cat <<'USAGE'
Usage: ghstart <repo> [-P|--public] [-- <gh repo create options>]

Create a GitHub repository, clone via ghq, and cd into it.
If the repository already exists, skip creation and just clone.

Arguments:
  <repo>    Repository name (e.g., "my-project" or "myorg/my-project")

Options:
  -P, --public    Create as public (default: private)
  --              Pass remaining args to "gh repo create"

Examples:
  ghstart my-project
  ghstart my-project -P
  ghstart my-org/my-project
  ghstart my-project -- --license mit --gitignore Node --add-readme
USAGE
          return 0
          ;;
        -*) echo "Unknown option: $1" >&2; return 1 ;;
        *)  break ;;
      esac
    done

    local repo="${1:?Repository name required}"
    local full="$repo"
    [[ "$repo" != */* ]] && full="$(gh api user --jq .login)/${repo}"

    # Create repo (skip if already exists)
    if gh repo view "$full" &>/dev/null; then
      echo "Repository '$full' already exists, skipping creation"
    else
      gh repo create "$full" "$visibility" "${gh_extra[@]}" || return 1
    fi

    ghq get "git@github.com:${full}.git" || return 1
    cd "$(ghq root)/github.com/${full}"
  }
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
