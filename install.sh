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

# Create symbolic links
echo "Creating symbolic links..."
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
