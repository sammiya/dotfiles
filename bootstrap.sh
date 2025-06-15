#!/bin/bash

set -euo pipefail

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    # Check if Ubuntu
    if ! command -v apt-get &> /dev/null; then
        echo "Error: Only Ubuntu Linux is supported"
        exit 1
    fi
else
    echo "Error: Unsupported OS"
    exit 1
fi

# Install Homebrew (macOS only)
if [[ "$OS" == "macos" ]] && [[ ! -f "/opt/homebrew/bin/brew" ]]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install git (macOS and Linux)
if [[ "$OS" == "macos" ]] && ! /opt/homebrew/bin/brew list git &>/dev/null; then
    echo "Installing git via Homebrew..."
    /opt/homebrew/bin/brew install git
elif [[ "$OS" == "linux" ]] && ! command -v git &>/dev/null; then
    echo "Installing git via apt-get..."
    sudo apt-get update

    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt-get install -y git gh fzf ripgrep

    # install ghq
    if ! command -v ghq &>/dev/null; then
        echo "Installing ghq via apt-get..."
        sudo apt-get install -y ghq
    fi
fi

# Clone dotfiles
DOTFILES_DIR="$HOME/ghq/github.com/sammiya/dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Directory $DOTFILES_DIR already exists. Skipping clone."
else
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone https://github.com/sammiya/dotfiles.git "$DOTFILES_DIR"
fi

echo "Done! Dotfiles repository cloned to: $DOTFILES_DIR"
echo
echo "Next, you can install dotfiles configuration and tools."
echo "Run the following command to install:"
echo
echo "cd $DOTFILES_DIR && ./install.sh"
