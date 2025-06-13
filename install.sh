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

if [[ "$OS" == "macos" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Darwin" "$HOME/.zshrc_Darwin"
elif [[ "$OS" == "linux" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Linux" "$HOME/.zshrc_Linux"
fi

# Install tools
echo "Installing tools..."

if [[ "$OS" == "macos" ]]; then
    # Use Homebrew
    /opt/homebrew/bin/brew install gh ghq fzf ripgrep starship mise
elif [[ "$OS" == "linux" ]]; then
    # Install via apt and other methods
    sudo apt-get update

    # Install zsh first
    sudo apt-get install -y zsh

    # # gh (GitHub CLI)
    # # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
    # (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
    #     && sudo mkdir -p -m 755 /etc/apt/keyrings \
    #         && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    #         && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    #     && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    #     && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    #     # && sudo apt update \
    #     && sudo apt install gh -y

    # # ripgrep
    # sudo apt-get install -y ripgrep

    # # fzf
    # sudo apt install fzf

    # # ghq
    # if ! command -v ghq &> /dev/null; then
    #     GHQ_VERSION=$(curl -s https://api.github.com/repos/x-motemen/ghq/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    #     wget -O /tmp/ghq.tar.gz "https://github.com/x-motemen/ghq/releases/download/${GHQ_VERSION}/ghq_linux_amd64.tar.gz"
    #     tar -xzf /tmp/ghq.tar.gz -C /tmp
    #     sudo mv /tmp/ghq_linux_amd64/ghq /usr/local/bin/
    #     rm -rf /tmp/ghq*
    # fi

    # # starship
    # if ! command -v starship &> /dev/null; then
    #     curl -sS https://starship.rs/install.sh | sh -s -- -y
    # fi

    # # mise
    # if ! command -v mise &> /dev/null; then
    #     curl https://mise.run | sh
    #     echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    # fi
fi

echo "Done! Dotfiles installed successfully."
echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
