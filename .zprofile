# ===========================
# Environment Variables
# ===========================

if command -v vim &> /dev/null; then
    export EDITOR=vim
    export VISUAL=vim
fi

# ===========================
# OS-specific Configuration
# ===========================
case "$OSTYPE" in
    darwin*)
        [ -f ~/.zprofile_Darwin ] && source ~/.zprofile_Darwin
        ;;
    linux-gnu*)
        [ -f ~/.zprofile_Linux ] && source ~/.zprofile_Linux
        ;;
esac

# ===========================
# mise
# ===========================
if [ -x "$HOME/.local/bin/mise" ]; then
    # Re-assert mise shims after login-only PATH setup such as brew shellenv.
    eval "$("$HOME/.local/bin/mise" activate zsh --shims)"
fi

# ===========================
# Local Configuration
# ===========================
# Source local configuration if it exists
[ -f ~/.zprofile_local ] && source ~/.zprofile_local
