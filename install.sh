#!/bin/bash

# Dotfiles Install Script
# This script sets up dotfiles by creating symlinks and installing necessary packages.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting dotfiles installation...${NC}"

# Function to backup existing file
backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        echo -e "${YELLOW}Backing up $file to $file.backup${NC}"
        mv "$file" "$file.backup"
    fi
}

# Determine the dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"

# Backup and symlink dotfiles
backup_file ~/.bash_aliases
ln -sf "$DOTFILES_DIR/bash_aliases" ~/.bash_aliases

backup_file ~/.vimrc
ln -sf "$DOTFILES_DIR/vimrc" ~/.vimrc

backup_file ~/.gitconfig
ln -sf "$DOTFILES_DIR/gitconfig" ~/.gitconfig

# Symlink vim directory
if [ -d ~/.vim ] && [ ! -L ~/.vim ]; then
    echo -e "${YELLOW}Backing up ~/.vim to ~/.vim.backup${NC}"
    mv ~/.vim ~/.vim.backup
fi
ln -sf "$DOTFILES_DIR/vim" ~/.vim

# Symlink gnupg configs
mkdir -p ~/.gnupg
for config in dirmngr.conf gpg-agent.conf gpg.conf; do
    if [ -f "$DOTFILES_DIR/gnupg/$config" ]; then
        backup_file ~/.gnupg/$config
        ln -sf "$DOTFILES_DIR/gnupg/$config" ~/.gnupg/$config
    fi
done

# Install system packages
echo -e "${GREEN}Installing system packages...${NC}"
sudo apt update
sudo apt install -y apt-transport-https vim build-essential htop git dnsutils software-properties-common neofetch curl

# Install uv (modern Python package manager)
echo -e "${GREEN}Installing uv...${NC}"
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

# Install ruff (Python linter and formatter)
echo -e "${GREEN}Installing ruff...${NC}"
uv tool install ruff

# Optional: Install additional packages for desktop (commented out for headless)
# echo -e "${YELLOW}Installing desktop packages...${NC}"
# sudo apt install -y vim-gnome ubuntu-restricted-addons ubuntu-restricted-extras

# Set up MOTD
if [ ! -f /etc/profile.d/mymotd.sh ]; then
    echo -e "${GREEN}Setting up MOTD...${NC}"
    sudo bash -c 'echo "neofetch" >> /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'
fi

echo -e "${GREEN}Installation complete! Please restart your shell or run 'source ~/.bashrc' to apply changes.${NC}"
echo -e "${YELLOW}Remember to edit ~/.gitconfig with your name, email, and GPG key.${NC}"