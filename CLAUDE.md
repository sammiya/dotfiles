# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリ内のコードを扱う際のガイダンスを提供します。

## リポジトリ概要

これは、macOS（Apple Silicon）および Ubuntu Linux システム用の個人 dotfiles リポジトリです。このリポジトリは自動セットアップスクリプトを提供し、各種開発ツールやシェル環境の設定ファイルを含む予定です。

## ターゲットアーキテクチャ

- **プライマリシェル**: zsh
- **インストールスクリプト**: bash（より広い互換性のため）
- **ファイル構成**: ghq ディレクトリ構造を使用（`$HOME/ghq/github.com/sammiya/dotfiles`）

## プラットフォームサポート

- **macOS**: Apple Silicon のみ（`/opt/homebrew` パスを前提）
- **Linux**: Ubuntu のみ（`apt-get` パッケージマネージャーを使用）
- **サポート対象外**: Intel Mac、その他の Linux ディストリビューション

## 主要コンポーネント

- `install.sh`: 設定ファイルのシンボリックリンク作成と各種開発ツールのインストールを処理するスクリプト
- 将来的に zsh、git、各種開発ツール用の設定ファイルが追加される予定

## インストールフロー

1. 厳密なプラットフォーム検証を伴う OS 検出
2. Homebrew のインストール（macOS のみ）
3. 適切なパッケージマネージャーを使用した git のインストール
4. 標準化された場所へのリポジトリのクローン

## メモリ

- README.mdのbootstrap.shとinstall.shの関係: bootstrap.shは高レベルのインストールスクリプトで、install.shを呼び出すラッパースクリプトとして機能する。bootstrap.shは環境のセットアップや前提条件の確認を行い、実際のインストール処理はinstall.shに委譲する。
