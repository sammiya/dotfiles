#!/bin/bash

set -e

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

echo "Installing dotfiles from: $DOTFILES_DIR"

# Create symbolic links
echo "Creating symbolic links..."
ln -sf "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
ln -sf "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.config/mise"

ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# NOTE: Symlink as different name to prevent mise warnings in dotfiles repo
ln -sf "$DOTFILES_DIR/.config/mise/config.toml" "$HOME/.config/mise/config.symlink.toml"

if [[ "$OS" == "macos" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Darwin" "$HOME/.zshrc_Darwin"
    ln -sf "$DOTFILES_DIR/.zprofile_Darwin" "$HOME/.zprofile_Darwin"
elif [[ "$OS" == "linux" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Linux" "$HOME/.zshrc_Linux"
    ln -sf "$DOTFILES_DIR/.zprofile_Linux" "$HOME/.zprofile_Linux"
fi

# Install tools
echo "Installing tools..."

if [[ "$OS" == "macos" ]]; then
    # Use Homebrew
    /opt/homebrew/bin/brew install git gh ghq fzf ripgrep

    # starship
    curl -sS https://starship.rs/install.sh | sh

    # mise
    curl https://mise.run | sh
    
    # Run mise install to install tools defined in config
    if [[ -x "$HOME/.local/bin/mise" ]]; then
        "$HOME/.local/bin/mise" install
    fi

elif [[ "$OS" == "linux" ]]; then
    # Install via apt and other methods
    sudo apt-get update

    # Install zsh first
    sudo apt-get install -y zsh

    # TODO
    echo "TODO: Install git, gh, ghq, fzf, ripgrep, starship, mise on Linux"
fi

echo "Done! Dotfiles installed successfully."
echo "- Please restart your shell or run 'source ~/.zshrc' to apply changes."
if command -v gh &> /dev/null; then
    echo "- GitHub CLI (gh) is now installed. Please run 'gh auth login -p ssh' to authenticate."
fi