#!/bin/bash
set -eu

# カラー出力用の関数
info() { echo -e "\033[34m[INFO]\033[0m $1"; }
success() { echo -e "\033[32m[OK]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1"; }
warning() { echo -e "\033[33m[WARN]\033[0m $1"; }

# 設定
GITHUB_USER="sammiya"
DOTFILES_REPO="github.com/${GITHUB_USER}/dotfiles"
DOTFILES_DIR="${HOME}/ghq/${DOTFILES_REPO}"
GHQ_ROOT="${HOME}/ghq"

# シンボリックリンクを安全に作成する関数
create_symlink() {
    local source="$1"
    local target="$2"

    if [[ ! -e "$source" ]]; then
        error "Source file not found: $source"
        return 1
    fi

    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            warning "Symlink already exists: $target"
        else
            warning "File already exists (not a symlink): $target"
            warning "Please backup and remove it manually if you want to replace it."
            return 1
        fi
    else
        ln -s "$source" "$target"
        success "Created symlink: $target -> $source"
    fi
}

# 最初に基本的なツールをインストール
info "Installing essential tools first..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "📱 Detected macOS"

    # Homebrew のインストール
    if ! command -v brew &> /dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Homebrew のパスを追加（Apple Siliconの場合）
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        success "Homebrew installed successfully."
    fi

    # gitのインストール（最優先）
    if ! command -v git &> /dev/null; then
        info "Installing git..."
        brew install git
        success "git installed successfully."
    fi

    # ghqのインストール（dotfilesクローン用）
    if ! command -v ghq &> /dev/null; then
        info "Installing ghq..."
        brew install ghq
        success "ghq installed successfully."
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "🐧 Detected Linux"

    # apt-get の確認
    if ! command -v apt-get &> /dev/null; then
        error "apt-get is not installed. This script is only supported on Debian/Ubuntu."
        exit 1
    fi

    sudo apt update

    # 必須パッケージのインストール
    essential_packages=(
        "git"
        "curl"
        "wget"
        "unzip"
    )

    for package in "${essential_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            info "Installing $package..."
            sudo apt install -y "$package"
            success "$package installed successfully."
        fi
    done

    # ghq のインストール（dotfilesクローン用）
    if ! command -v ghq &> /dev/null; then
        info "Installing ghq..."

        # アーキテクチャの判定
        ARCH=$(dpkg --print-architecture)
        case $ARCH in
            amd64) GHQ_ARCH="amd64" ;;
            arm64) GHQ_ARCH="arm64" ;;
            *) error "Unsupported architecture: $ARCH"; exit 1 ;;
        esac

        # 最新バージョンを取得してインストール
        GHQ_VERSION=$(curl -s https://api.github.com/repos/x-motemen/ghq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        curl -OL "https://github.com/x-motemen/ghq/releases/download/${GHQ_VERSION}/ghq_linux_${GHQ_ARCH}.zip"
        sudo unzip -o "ghq_linux_${GHQ_ARCH}.zip" -d /usr/local/bin
        rm -f "ghq_linux_${GHQ_ARCH}.zip"
        sudo chmod +x /usr/local/bin/ghq
        success "ghq installed successfully."
    fi
fi

# ghq のルートディレクトリを設定
if ! git config --global ghq.root >/dev/null 2>&1; then
    info "Setting ghq root to $GHQ_ROOT"
    git config --global ghq.root "$GHQ_ROOT"
fi

# dotfiles リポジトリのクローン
if [[ ! -d "$DOTFILES_DIR" ]]; then
    info "Cloning dotfiles repository..."
    ghq get "https://${DOTFILES_REPO}.git"
    success "Dotfiles repository cloned successfully."
else
    info "Dotfiles repository already exists. Pulling latest changes..."
    (cd "$DOTFILES_DIR" && git pull)
fi

# 共通の設定ファイルのシンボリックリンク作成
info "Creating common symlinks..."
create_symlink "$DOTFILES_DIR/.gitconfig" ~/.gitconfig
create_symlink "$DOTFILES_DIR/.gitignore_global" ~/.gitignore_global
create_symlink "$DOTFILES_DIR/.zshrc" ~/.zshrc

# OS固有の処理とその他のツールのインストール
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS固有のzshrc設定
    if [[ -f "$DOTFILES_DIR/.zshrc_Darwin" ]]; then
        create_symlink "$DOTFILES_DIR/.zshrc_Darwin" ~/.zshrc_Darwin
    fi

    # その他のツールのインストール
    info "Installing additional tools..."
    tools=(
        "gh"
        "fzf"
        "ripgrep"
        "starship"
        "mise"
    )

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            info "Installing $tool..."
            brew install "$tool"
            success "$tool installed successfully."
        else
            info "$tool is already installed."
        fi
    done

    # VSCode の設定（macOS）
    if command -v code &> /dev/null; then
        info "Setting up VSCode..."
        vscode_dir=~/Library/Application\ Support/Code/User
        mkdir -p "$vscode_dir"
        create_symlink "$DOTFILES_DIR/settings.json" "$vscode_dir/settings.json"

        # 拡張機能のインストール
        if [[ -f "$DOTFILES_DIR/extensions.txt" ]]; then
            info "Installing VSCode extensions..."
            cat "$DOTFILES_DIR/extensions.txt" | xargs -L 1 code --install-extension
            success "VSCode extensions installed."
        else
            warning "extensions.txt not found. Skipping VSCode extension installation."
        fi
    else
        warning "VSCode not found. Skipping VSCode setup."
    fi

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux固有のzshrc設定（存在する場合）
    if [[ -f "$DOTFILES_DIR/.zshrc_Linux" ]]; then
        create_symlink "$DOTFILES_DIR/.zshrc_Linux" ~/.zshrc_Linux
    fi

    info "Installing additional packages..."

    # 追加パッケージ
    additional_packages=(
        "fzf"
        "ripgrep"
    )

    for package in "${additional_packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            info "Installing $package..."
            sudo apt install -y "$package"
            success "$package installed successfully."
        else
            info "$package is already installed."
        fi
    done

    # GitHub CLI (gh) のインストール
    if ! command -v gh &> /dev/null; then
        info "Installing gh..."

        # 公式の手順に従ってインストール
        sudo mkdir -p -m 755 /etc/apt/keyrings
        out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg
        cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
        success "gh installed successfully."
    else
        info "gh is already installed."
    fi

    # Starship のインストール
    if ! command -v starship &> /dev/null; then
        info "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        success "starship installed successfully."
    else
        info "starship is already installed."
    fi

    # mise のインストール
    if ! command -v mise &> /dev/null; then
        info "Installing mise..."
        curl https://mise.run/install.sh | sh
        # mise のパスを追加
        export PATH="$HOME/.local/bin:$PATH"
        success "mise installed successfully."
    else
        info "mise is already installed."
    fi

    # VSCode の設定（Linux）
    if command -v code &> /dev/null; then
        info "Setting up VSCode..."
        vscode_dir=~/.config/Code/User
        mkdir -p "$vscode_dir"
        create_symlink "$DOTFILES_DIR/settings.json" "$vscode_dir/settings.json"

        # 拡張機能のインストール
        if [[ -f "$DOTFILES_DIR/extensions.txt" ]]; then
            info "Installing VSCode extensions..."
            cat "$DOTFILES_DIR/extensions.txt" | xargs -L 1 code --install-extension
            success "VSCode extensions installed."
        else
            warning "extensions.txt not found. Skipping VSCode extension installation."
        fi
    else
        warning "VSCode not found. Skipping VSCode setup."
    fi
fi

# 完了メッセージ
echo ""
success "Setup completed!"
echo ""
info "Next steps:"
info "1. Restart your shell or run: source ~/.zshrc"
info "2. Configure your Git user:"
info "   git config --global user.name \"Your Name\""
info "   git config --global user.email \"your.email@example.com\""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    info "3. Add mise to your PATH if not already done:"
    info "   export PATH=\"\$HOME/.local/bin:\$PATH\""
fi
