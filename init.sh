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

curl -OL -o ~ https://github.com/x-motemen/ghq/releases/latest/download/ghq_linux_amd64.zip
sudo unzip ~/ghq_linux_amd64.zip -d /usr/local
sudo ln -s /usr/local/ghq_linux_amd64/ghq /usr/local/bin/ghq
rm -f ~/ghq_linux_amd64.zip

sudo apt install fzf -y

ln -s ~/dotfiles/.zshrc_Linux ~/.zshrc_Linux

# 以下は Mac 用。あとで分離

# ln -s ~/dotfiles/.zshrc_Darwin ~/.zshrc_Darwin

# brew install fzf
# brew install ghq

# mkdir -p ~/Library/Application\ Support/Code/User
# ln -s ~/dotfiles/settings.json ~/Library/Application\ Support/Code/User/settings.json

# cat extensions.txt | xargs -L 1 code --install-extension
