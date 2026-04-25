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

echo "Installing dotfiles from: $DOTFILES_DIR"

"$DOTFILES_DIR/link.sh"

# Function to install mise
install_mise() {
    mise_install_path="$HOME/.local/bin/mise"

    if [[ ! -x "$mise_install_path" ]]; then
        curl -fsSL https://mise.run | sh
    else
       "$mise_install_path" self-update
    fi

    # Run mise install to install tools defined in config
    if [[ -x "$HOME/.local/bin/mise" ]]; then
        export PATH="$HOME/.local/bin:$PATH"
        "$HOME/.local/bin/mise" trust -y "$DOTFILES_DIR/.config/mise/conf.d/00-shared.toml"
        "$HOME/.local/bin/mise" install
    fi
}

# Function to install Spaceship prompt
install_spaceship() {
    if [[ "$OS" == "macos" ]]; then
        /opt/homebrew/bin/brew install spaceship
    elif [[ "$OS" == "linux" ]]; then
        local spaceship_dir="$HOME/.zsh/spaceship"

        mkdir -p "$(dirname "$spaceship_dir")"

        if [[ -d "$spaceship_dir/.git" ]]; then
            git -C "$spaceship_dir" pull --ff-only
        elif [[ ! -e "$spaceship_dir" ]]; then
            git clone --depth=1 https://github.com/spaceship-prompt/spaceship-prompt.git "$spaceship_dir"
        else
            echo "Error: $spaceship_dir exists but is not a git repository"
            return 1
        fi
    fi
}

# Function to install Claude Code
install_claude_code() {
    if ! command -v claude &> /dev/null; then
        curl -fsSL https://claude.ai/install.sh | bash
    else
        echo "Claude Code is already installed; skipping reinstall."
    fi
}

# Install tools
echo "Installing tools..."

if [[ "$OS" == "macos" ]]; then
    # Use Homebrew
    /opt/homebrew/bin/brew update

    /opt/homebrew/bin/brew install git gnupg

    # Install mise
    install_mise

    # Install Spaceship prompt
    install_spaceship

    # Install Claude Code
    install_claude_code

elif [[ "$OS" == "linux" ]]; then
    # Add Git PPA for latest git version
    sudo add-apt-repository -y ppa:git-core/ppa

    # Install via apt
    sudo apt-get update

    # Install OS-level dependencies. CLI tools are managed by mise.
    sudo apt-get install -y git zsh unzip gnupg

    # Install mise
    install_mise

    # Install Spaceship prompt
    install_spaceship

    # Install Claude Code
    install_claude_code

    # Change default shell to zsh
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    else
        echo "Default shell is already set to zsh."
    fi
fi

echo "Done! Dotfiles installed successfully."
echo "- Please restart your shell or run 'source ~/.zshrc' to apply changes."
echo "- GitHub CLI (gh) is managed by mise. Please run 'gh auth login -p ssh' after restarting your shell."
