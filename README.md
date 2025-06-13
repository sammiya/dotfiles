# dotfiles

macOSとUbuntu Linux用の個人設定ファイル集です。

## 必要な環境

- macOS (Apple Silicon) または Ubuntu Linux
- curl（初回セットアップ用）

## インストール方法

以下のコマンドを実行するだけで完了します：

```bash
curl -fsSL https://raw.githubusercontent.com/sammiya/dotfiles/20250614/bootstrap.sh | bash
```

このスクリプトは以下を実行します：
1. Homebrewのインストール（macOSのみ）
2. gitがない場合はインストール
3. このリポジトリを `$HOME/ghq/sammiya/dotfiles` にクローン
4. dotfilesのインストール確認（y/N）
   - yを選択した場合、自動的に `install.sh` を実行
   - 設定ファイルのシンボリックリンク作成（.gitconfig, .zshrc等）
   - 開発ツールのインストール（gh, ghq, fzf, ripgrep, starship, mise）

## 手動インストール

手動でインストールしたい場合：

```bash
# リポジトリをクローン
git clone -b 20250614 https://github.com/sammiya/dotfiles.git ~/ghq/sammiya/dotfiles
cd ~/ghq/sammiya/dotfiles
./install.sh
```

## 内容

- シェル設定（zsh）
- Git設定
- 各種開発ツールの設定