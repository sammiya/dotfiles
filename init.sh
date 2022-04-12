set -eu

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y

# SCRIPT_DIR=$(cd $(dirname $0); pwd)

ln -s ~/dotfiles/.gitconfig ~/.gitconfig
ln -s ~/dotfiles/.gitignore_global ~/.gitignore_global
