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
mkdir -p "$HOME/.config/mise"

ln -sf "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"

# NOTE: Symlink as different name to prevent mise warnings in dotfiles repo
ln -sf "$DOTFILES_DIR/.config/mise/config.symlink.toml" "$HOME/.config/mise/config.toml"

ln -sf "$DOTFILES_DIR/.claude/settings.json" "$HOME/.claude/settings.json"

if [[ "$OS" == "macos" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Darwin" "$HOME/.zshrc_Darwin"
    ln -sf "$DOTFILES_DIR/.zprofile_Darwin" "$HOME/.zprofile_Darwin"
elif [[ "$OS" == "linux" ]]; then
    ln -sf "$DOTFILES_DIR/.zshrc_Linux" "$HOME/.zshrc_Linux"
    ln -sf "$DOTFILES_DIR/.zprofile_Linux" "$HOME/.zprofile_Linux"
fi

# Function to install starship
install_starship() {
    if ! command -v starship &> /dev/null; then
        echo "starship is not installed. Installing..."
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y
    else
        CURRENT_STARSHIP_VERSION=$(starship --version | head -1 | awk '{print $2}')

        LATEST_STARSHIP_VERSION=$(curl -fsSL https://api.github.com/repos/starship/starship/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')

        if [ -z "$LATEST_STARSHIP_VERSION" ]; then
            echo "Failed to fetch latest version info for starship"
            return 1
        fi

        if [ "$CURRENT_STARSHIP_VERSION" != "$LATEST_STARSHIP_VERSION" ]; then
            echo "Updating starship from $CURRENT_STARSHIP_VERSION to $LATEST_STARSHIP_VERSION"
            curl -fsSL https://starship.rs/install.sh | sh -s -- -y
        else
            echo "starship is already up to date ($CURRENT_STARSHIP_VERSION)"
        fi
    fi
}

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
        "$HOME/.local/bin/mise" install
    fi
}

# Function to install ghq on Linux
install_ghq_linux() {
    (
        set -e

        local temp_dir
        temp_dir=$(mktemp -d) || { echo "Failed to create temp dir"; exit 1; }
        trap 'rm -rf "$temp_dir"' EXIT

        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64|arm64) arch=arm64 ;;
            *) echo "Unsupported arch: $arch"; exit 1 ;;
        esac

        if ! command -v ghq &> /dev/null; then
            echo "ghq is not installed. Installing..."
            curl -fsSL https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_"$arch".zip -o "$temp_dir/ghq_linux_$arch.zip"
            unzip -q "$temp_dir/ghq_linux_$arch.zip" -d "$temp_dir"
            sudo install -m 755 "$temp_dir/ghq_linux_$arch/ghq" /usr/local/bin/
        else
            CURRENT_GHQ_VERSION=$(ghq --version | head -1 | awk '{print $3}')

            LATEST_GHQ_VERSION=$(curl -fsSL https://api.github.com/repos/x-motemen/ghq/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
            if [ -z "$LATEST_GHQ_VERSION" ]; then
                echo "Failed to fetch latest version info for ghq"
                exit 1
            fi

            if [ "$CURRENT_GHQ_VERSION" != "$LATEST_GHQ_VERSION" ]; then
                echo "Updating ghq from $CURRENT_GHQ_VERSION to $LATEST_GHQ_VERSION"
                curl -fsSL https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_"$arch".zip -o "$temp_dir/ghq_linux_$arch.zip"
                unzip -q "$temp_dir/ghq_linux_$arch.zip" -d "$temp_dir"
                sudo install -m 755 "$temp_dir/ghq_linux_$arch/ghq" /usr/local/bin/
            else
                echo "ghq is already up to date ($CURRENT_GHQ_VERSION)"
            fi
        fi
    )
}

# Function to install fzf on Linux
install_fzf_linux() {
    (
        set -e

        local temp_dir
        temp_dir=$(mktemp -d) || { echo "Failed to create temp dir"; exit 1; }
        trap 'rm -rf "$temp_dir"' EXIT

        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch=amd64 ;;
            aarch64|arm64) arch=arm64 ;;
            *) echo "Unsupported arch: $arch"; exit 1 ;;
        esac

        if ! command -v fzf &> /dev/null; then
            echo "fzf is not installed. Installing..."
            LATEST_FZF_VERSION=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
            if [ -z "$LATEST_FZF_VERSION" ]; then
                echo "Failed to fetch latest version info for fzf"
                exit 1
            fi
            curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${LATEST_FZF_VERSION}/fzf-${LATEST_FZF_VERSION}-linux_${arch}.tar.gz" -o "$temp_dir/fzf.tar.gz"
            tar -xzf "$temp_dir/fzf.tar.gz" -C "$temp_dir"
            sudo install -m 755 "$temp_dir/fzf" /usr/local/bin/
        else
            CURRENT_FZF_VERSION=$(fzf --version | head -1 | awk '{print $1}')

            LATEST_FZF_VERSION=$(curl -fsSL https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/v//')
            if [ -z "$LATEST_FZF_VERSION" ]; then
                echo "Failed to fetch latest version info for fzf"
                exit 1
            fi

            if [ "$CURRENT_FZF_VERSION" != "$LATEST_FZF_VERSION" ]; then
                echo "Updating fzf from $CURRENT_FZF_VERSION to $LATEST_FZF_VERSION"
                curl -fsSL "https://github.com/junegunn/fzf/releases/download/v${LATEST_FZF_VERSION}/fzf-${LATEST_FZF_VERSION}-linux_${arch}.tar.gz" -o "$temp_dir/fzf.tar.gz"
                tar -xzf "$temp_dir/fzf.tar.gz" -C "$temp_dir"
                sudo install -m 755 "$temp_dir/fzf" /usr/local/bin/
            else
                echo "fzf is already up to date ($CURRENT_FZF_VERSION)"
            fi
        fi
    )
}

# Function to setup GitHub CLI apt repository
setup_github_cli_apt_repo() {
    # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian-ubuntu-linux-raspberry-pi-os-apt
    (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
        && sudo mkdir -p -m 755 /etc/apt/keyrings \
            && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
        && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
}

# Install tools
echo "Installing tools..."

if [[ "$OS" == "macos" ]]; then
    # Use Homebrew
    /opt/homebrew/bin/brew update

    /opt/homebrew/bin/brew install git gh ghq fzf ripgrep jq

    # Install starship
    install_starship

    # Install mise
    install_mise

elif [[ "$OS" == "linux" ]]; then
    # Setup GitHub CLI repository
    setup_github_cli_apt_repo

    # Install via apt
    sudo apt-get update

    # Install git, gh, ripgrep, zsh, unzip (for ghq), jq
    sudo apt-get install -y git gh ripgrep zsh unzip jq

    # Install ghq
    install_ghq_linux

    # Install fzf from binary
    install_fzf_linux

    # Install starship
    install_starship

    # Install mise
    install_mise

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
if command -v gh &> /dev/null; then
    echo "- GitHub CLI (gh) is now installed. Please run 'gh auth login -p ssh' to authenticate."
fi
