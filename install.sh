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
    echo "Directory $DOTFILES_DIR already exists. Remove it first if you want to reinstall."
    exit 1
fi

mkdir -p "$(dirname "$DOTFILES_DIR")"
git clone -b 20250614 https://github.com/sammiya/dotfiles.git "$DOTFILES_DIR"

echo "Done! Dotfiles installed to: $DOTFILES_DIR"