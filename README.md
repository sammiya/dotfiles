# dotfiles

macOSとUbuntu Linux用の個人設定ファイル集です。

## 必要な環境

- macOS (Apple Silicon) または Ubuntu Linux
- curl（インストール用）

## インストール方法

以下のコマンドを実行してインストールします：

```bash
curl -fsSL https://raw.githubusercontent.com/sammiya/dotfiles/20250614/install.sh | bash
```

このスクリプトは以下を実行します：
1. Homebrewのインストール（macOSのみ）
2. gitがない場合はインストール
3. このリポジトリを `$HOME/ghq/sammiya/dotfiles` にクローン

## 手動インストール

手動でインストールしたい場合：

```bash
# リポジトリをクローン
git clone -b 20250614 https://github.com/sammiya/dotfiles.git ~/ghq/sammiya/dotfiles
```

## 内容

- シェル設定（zsh）
- Git設定
- 各種ツールの設定