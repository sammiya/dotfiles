#!/bin/bash
set -eu

# カラー出力用の関数
info() { echo -e "\033[34m[INFO]\033[0m $1"; }
success() { echo -e "\033[32m[OK]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1"; }

ln -s ~/ghq/github.com/sammiya/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/ghq/github.com/sammiya/dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/ghq/github.com/sammiya/dotfiles/.zshrc ~/.zshrc

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "📱 Detected macOS"

  ln -s ~/ghq/github.com/sammiya/dotfiles/.zshrc_Darwin ~/.zshrc_Darwin

  # homebrew がインストールされていない場合はインストール
    if ! command -v brew &> /dev/null; then
        info "Homebrew is not installed. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        success "Homebrew installed successfully."
    else
        info "Homebrew is already installed."
    fi

    tools=(
        "git"
        "gh"
        "fzf"
        "ghq"
        "ripgrep"
        "starship"
        "mise"
    )

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            info "$tool is not installed. Installing..."
            brew install "$tool"
            success "$tool installed successfully."
        else
            info "$tool is already installed."
        fi
    done


    mkdir -p ~/Library/Application\ Support/Code/User
    ln -s ~/ghq/github.com/sammiya/dotfiles/settings.json ~/Library/Application\ Support/Code/User/settings.json

    cat extensions.txt | xargs -L 1 code --install-extension

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  echo "🐧 Detected Linux"
    # apt-get がインストールされていない場合はエラー
    if ! command -v apt-get &> /dev/null; then
        error "apt-get is not installed. This script is only supported on Ubuntu."
        exit 1
    fi

    sudo apt update

    info "Installing packages for Linux..."

    packages=(
        "git"
        "fzf"
        "ripgrep"
    )

    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            info "$package is not installed. Installing..."
            sudo apt install -y "$package"
            success "$package installed successfully."
        else
            info "$package is already installed."
        fi
    done

    if ! command -v gh &> /dev/null; then
        info "gh is not installed. Installing..."

        # https://github.com/cli/cli/blob/trunk/docs/install_linux.md#official-sources
        (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
            && sudo mkdir -p -m 755 /etc/apt/keyrings \
                && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
            && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
            && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
            && sudo apt update \
            && sudo apt install gh -y
        success "gh installed successfully."
    else
        info "gh is already installed."
    fi

    if ! command -v ghq &> /dev/null; then
        info "ghq is not installed. Installing..."
        curl -OL https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_amd64.zip
        sudo unzip ghq_linux_amd64.zip -d /usr/local
        sudo ln -s /usr/local/ghq_linux_amd64/ghq /usr/local/bin/ghq
        rm -f ghq_linux_amd64.zip
        success "ghq installed successfully."
    fi

    if ! command -v starship &> /dev/null; then
        info "starship is not installed. Installing..."
        curl -sS https://starship.rs/install.sh | sh
        success "starship installed successfully."
    else
        info "starship is already installed."
    fi

    if ! command -v mise &> /dev/null; then
        info "mise is not installed. Installing..."
        curl https://mise.run/install.sh | sh
        success "mise installed successfully."
    else
        info "mise is already installed."
    fi
else
  error "Unsupported OS: $OSTYPE"
  exit 1
fi
