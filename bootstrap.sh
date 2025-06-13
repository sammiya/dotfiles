#!/bin/bash

set -e

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

# Install git
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    
    if [[ "$OS" == "macos" ]]; then
        /opt/homebrew/bin/brew install git
    elif [[ "$OS" == "linux" ]]; then
        sudo apt-get update
        sudo apt-get install -y git
    fi
fi

# Clone dotfiles
DOTFILES_DIR="$HOME/ghq/sammiya/dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Directory $DOTFILES_DIR already exists. Skipping clone."
else
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone -b 20250614 https://github.com/sammiya/dotfiles.git "$DOTFILES_DIR"
fi

echo "Done! Dotfiles repository cloned to: $DOTFILES_DIR"
echo
echo "Next, you can install dotfiles configuration and tools."
read -p "Do you want to run install.sh now? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running install.sh..."
    cd "$DOTFILES_DIR"
    ./install.sh
else
    echo "Skipped install.sh. You can run it later with:"
    echo "  cd $DOTFILES_DIR && ./install.sh"
fi