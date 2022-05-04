set -eu

# SCRIPT_DIR=$(cd $(dirname $0); pwd)

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

sudo apt install zsh -y
chsh -s /bin/zsh

ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
ln -s ~/dotfiles/.zshrc ~/.zshrc
ln -s ~/dotfiles/.zshrc_Darwin ~/.zshrc_Darwin

mkdir -p ~/Library/Application\ Support/Code/User
ln -s ~/dotfiles/settings.json ~/Library/Application\ Support/Code/User/settings.json

cat extensions.txt | xargs -L 1 code --install-extension
