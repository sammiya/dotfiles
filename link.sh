#!/bin/bash

set -euo pipefail

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if ! command -v apt-get &> /dev/null; then
        echo "Error: Only Ubuntu Linux is supported"
        exit 1
    fi
else
    echo "Error: Unsupported OS"
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating symbolic links from: $DOTFILES_DIR"

ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.config/mise/conf.d"

# Shared mise config: symlink to conf.d/ (merged with local config.toml)
ln -sf "$DOTFILES_DIR/.config/mise/conf.d/00-shared.toml" "$HOME/.config/mise/conf.d/00-shared.toml"

# Local mise config: ensure config.toml is a real file (not a symlink to dotfiles)
# mise use -g writes here, so it must be a local file to avoid dotfiles diffs
if [ -L "$HOME/.config/mise/config.toml" ]; then
    rm -f "$HOME/.config/mise/config.toml"
fi
if [ ! -f "$HOME/.config/mise/config.toml" ]; then
    touch "$HOME/.config/mise/config.toml"
fi

ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

if [[ "$OS" == "macos" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Darwin" "$HOME/.zshrc_Darwin"
    ln -sf "$DOTFILES_DIR/.zprofile_Darwin" "$HOME/.zprofile_Darwin"
elif [[ "$OS" == "linux" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Linux" "$HOME/.zshrc_Linux"
    ln -sf "$DOTFILES_DIR/.zprofile_Linux" "$HOME/.zprofile_Linux"
fi

echo "Done! Dotfiles linked successfully."
