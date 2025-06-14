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
# Local Configuration
# ===========================
# Source local configuration if it exists
[ -f ~/.zprofile_local ] && source ~/.zprofile_local
