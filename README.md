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
curl -fsSL https://raw.githubusercontent.com/sammiya/dotfiles/20250614/bootstrap.sh | bash
```

このスクリプトは以下を実行する：
1. Homebrewのインストール（macOSのみ）
2. gitがない場合はインストール
3. このリポジトリを `$HOME/github.com/ghq/sammiya/dotfiles` にクローン

### 2. `install.sh` で、設定ファイルへのシンボリックリンク作成と、よく使うライブラリのインストール

```
cd $HOME/github.com/ghq/sammiya/ && ./install.sh
```

このスクリプトは以下を実行する：

1. `$HOME/github.com/ghq/sammiya/dotfiles` 内の設定ファイルへのシンボリックリンクを `$HOME` に作成
  - `.gitignore_global`
    - `.gitconfig`
    - `.zshrc`
    - `.zprofile`

2. よく使うライブラリのインストール（※Ubuntu Linux 側はWIP）
  - `gh`
  - `ghq`
  - `fzf`
  - `ripgrep`
  - `starship`
  - `mise`

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

## TODO

- [ ] Linux 側のライブラリインストール
- [ ] VSCode の設定周りの明記
  - 以前は `settings.json` をシンボリックリンクしていたが、環境ごとの差分をうまく管理できないので断念。ただドキュメントには載せたい
  - よく使う拡張機能のインストール
- [ ] Windows にも対応
  - 原則 WSL2 の Ubuntu Linux 上で開発する想定だが、VSCode の設定などは記載したい