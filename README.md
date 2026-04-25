# dotfiles

macOSとUbuntu Linux用の個人設定ファイル集

## 必要な環境

- macOS (Apple Silicon) または Ubuntu Linux
- curl（初回セットアップ用）

## 使い方

### 1. `bootstrap.sh` で最低限必要なもののインストールとリポジトリの clone

下記のコマンドで実行

```bash
sudo -v
curl -fsSL https://raw.githubusercontent.com/sammiya/dotfiles/main/bootstrap.sh | bash
```

このスクリプトは以下を実行する：
1. Homebrewのインストール（macOSのみ）
2. gitがない場合はインストール
3. このリポジトリを `$HOME/ghq/github.com/sammiya/dotfiles` にクローン

### 2. `install.sh` で、設定ファイルへのシンボリックリンク作成と、よく使うライブラリのインストール

```
cd $HOME/ghq/github.com/sammiya/dotfiles && ./install.sh
```

このスクリプトは以下を実行する：

- `link.sh` を実行して、`$HOME/ghq/github.com/sammiya/dotfiles` 内の設定ファイルへのシンボリックリンクを作成
  - `$HOME/.gitignore_global`
  - `$HOME/.gitconfig`
  - `$HOME/.zshrc`
  - `$HOME/.zprofile`
  - `$HOME/.zshrc_Darwin` (macOS用)
  - `$HOME/.zprofile_Darwin` (macOS用)
  - `$HOME/.zshrc_Linux` (Linux用)
  - `$HOME/.zprofile_Linux` (Linux用)
  - `$HOME/.config/mise/conf.d/00-shared.toml`
  - `$HOME/.claude/settings.json`

- `mise` のローカル設定ファイルを用意
  - `$HOME/.config/mise/config.toml`
  - これは symlink ではなくローカル実ファイルとして作成し、`mise use -g` などの環境依存な変更を dotfiles 側に混ぜない

- よく使うライブラリのインストール
  - `gnupg`
  - `mise`
  - `spaceship`
  - `mise install` を実行して `.config/mise/conf.d/00-shared.toml` の CLI・言語ランタイムをインストール

設定ファイルへのシンボリックリンクだけ作り直したい場合は、以下を実行する：

```bash
./link.sh
```

### 3. GUI系のアプリケーションや、環境によって必要なもののインストール（※柔軟性のため、ここは README.md に記載して手動実行を想定する）

#### macOS

##### VSCode
```bash
brew install --cask visual-studio-code
```

##### Google Chrome
```bash
brew install --cask google-chrome
```

##### Docker
```bash
brew install --cask docker
```

##### Slack

```bash
brew install --cask slack
```

##### Karabiner Elements
```bash
brew install --cask karabiner-elements
```

#### Ubuntu Linux

##### docker

```bash
./install-docker-linux.sh
```

※ `./install.sh` に統合するか検討

WSL2 上の Ubuntu Linux の場合、歯車マークから Resources > WSL INTEGRATION で、Docker Desktop の WSL Integration を有効にする

## TODO

- [x] Linux 側のライブラリインストール
- [ ] VSCode の設定周りの明記
  - 以前は `settings.json` をシンボリックリンクしていたが、環境ごとの差分をうまく管理できないので断念。ただドキュメントには載せたい
  - よく使う拡張機能のインストール
- [ ] Windows にも対応
  - 原則 WSL2 の Ubuntu Linux 上で開発する想定だが、VSCode の設定などは記載したい
