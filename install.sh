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

# Symlink vim directory (shared backend for both vim and neovim: colors, syntax, etc.)
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
# Secure the GPG directory (prevents "unsafe permissions" warnings)
chmod 700 ~/.gnupg 2>/dev/null || true

# Symlink Neovim config (primary editor).
# The nvim/init.vim bootstraps the shared configuration from .vimrc + ~/.vim/
# (colors, autocmds, etc.) while adding modern/WSL improvements.
# 'vim' command is aliased to nvim for convenience; classic vim remains available.
mkdir -p ~/.config/nvim
backup_file ~/.config/nvim/init.vim
ln -sf "$DOTFILES_DIR/nvim/init.vim" ~/.config/nvim/init.vim

# Symlink Neovim Lua modules (e.g. treesitter.lua).
# This lets us use real .lua files + `lua require('treesitter')` from init.vim
# instead of inline heredocs with EOF markers.
if [ -d "$DOTFILES_DIR/nvim/lua" ]; then
    ln -sfn "$DOTFILES_DIR/nvim/lua" ~/.config/nvim/lua
fi

# Symlink fastfetch config (WSL-optimized, compact, good for MOTD)
mkdir -p ~/.config/fastfetch
backup_file ~/.config/fastfetch/config.jsonc
ln -sf "$DOTFILES_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/config.jsonc

# Note: For machine-specific aliases (including WSL-only ones), copy the example
# and edit the copy. It is automatically sourced by bash_aliases if present.
#   cp "$DOTFILES_DIR/bash_aliases_private.example" ~/.bash_aliases_private
#   chmod 600 ~/.bash_aliases_private


# Install system packages
echo -e "${GREEN}Installing system packages...${NC}"
sudo apt update
sudo apt install -y apt-transport-https vim build-essential htop git bind9-dnsutils software-properties-common fastfetch curl
# - neovim is the primary editor (vim kept for compatibility/scripts that call it)
# - bind9-dnsutils provides dig/nslookup (the old "dnsutils" package name is virtual)
# - fastfetch replaces neofetch (neofetch is deprecated; we never install it)

# Install latest Neovim from official GitHub release (much newer than Ubuntu 26.04 repos which have 0.11)
echo -e "${GREEN}Installing latest Neovim from release...${NC}"
curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
rm -rf ~/.local/nvim-linux-x86_64
mkdir -p ~/.local
tar -C ~/.local -xzf /tmp/nvim.tar.gz
mkdir -p ~/.local/bin
ln -sf ~/.local/nvim-linux-x86_64/bin/nvim ~/.local/bin/nvim
rm -f /tmp/nvim.tar.gz
echo -e "${GREEN}Neovim installed to ~/.local/nvim-linux-x86_64 (symlinked to ~/.local/bin/nvim)${NC}"

# Install nvim-treesitter plugin pinned to v0.9.3 (the version our lua config and health checks are written for;
# the main branch now requires Neovim 0.12+ and breaks on 0.11-era setups).
echo -e "${GREEN}Installing nvim-treesitter (pinned to v0.9.3)...${NC}"
mkdir -p ~/.vim/pack/plugins/start
if [ ! -d ~/.vim/pack/plugins/start/nvim-treesitter ]; then
    git clone https://github.com/nvim-treesitter/nvim-treesitter ~/.vim/pack/plugins/start/nvim-treesitter
fi
cd ~/.vim/pack/plugins/start/nvim-treesitter
git fetch --tags
git checkout v0.9.3 || echo -e "${YELLOW}Pinned checkout may have failed; continuing${NC}"

# Install tree-sitter CLI (needed by some treesitter commands; placed in ~/.local/bin which is in PATH)
echo -e "${GREEN}Installing tree-sitter CLI...${NC}"
mkdir -p ~/.local/bin
curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x86_64.gz -o /tmp/ts.gz
gunzip -c /tmp/ts.gz > ~/.local/bin/tree-sitter 2>/dev/null || echo -e "${YELLOW}tree-sitter CLI download may need manual check${NC}"
chmod +x ~/.local/bin/tree-sitter 2>/dev/null || true
rm -f /tmp/ts.gz
echo -e "${GREEN}tree-sitter CLI installed (if successful: $(~/.local/bin/tree-sitter --version 2>/dev/null || echo 'verify manually'))${NC}"

# Install uv (modern Python package manager)
echo -e "${GREEN}Installing uv...${NC}"
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="~/.local/bin:$PATH"  # ensure our nvim + cli are first

# Install ruff (Python linter and formatter)
echo -e "${GREEN}Installing ruff...${NC}"
uv tool install ruff

# Optional: Install additional packages for desktop (commented out for headless)
# echo -e "${YELLOW}Installing desktop packages...${NC}"
# sudo apt install -y vim-gnome ubuntu-restricted-addons ubuntu-restricted-extras

# Set up MOTD with fastfetch (replaces any old neofetch usage)
if [ ! -f /etc/profile.d/mymotd.sh ]; then
    echo -e "${GREEN}Setting up MOTD...${NC}"
    sudo bash -c 'echo "fastfetch" > /etc/profile.d/mymotd.sh && chmod +x /etc/profile.d/mymotd.sh'
fi

# Ensure neofetch (legacy) is not present — fastfetch is the replacement
if dpkg -s neofetch >/dev/null 2>&1; then
    echo -e "${YELLOW}Removing legacy neofetch package (fastfetch is the replacement)...${NC}"
    sudo apt remove -y neofetch 2>/dev/null || true
fi

# Initialize git submodules (base16-vim and vim-colors-solarized color schemes)
if [ -d .git ]; then
    if [ ! -f vim/bundle/base16-vim/colors/base16-default-dark.vim ] || [ ! -f vim/bundle/vim-colors-solarized/colors/solarized.vim ]; then
        echo -e "${GREEN}Initializing git submodules for color schemes...${NC}"
        git submodule update --init --recursive || echo -e "${YELLOW}Submodule init failed or not needed.${NC}"
    fi
fi

echo -e "${GREEN}Installation complete! Please restart your shell (or source ~/.bash_aliases) and start Neovim at least once.${NC}"
echo -e "${YELLOW}On first Neovim start, the treesitter config will auto-install parsers for python, bash, etc. (or manually run :TSInstall python bash inside Neovim).${NC}"

# Only remind if the gitconfig template still has blank/placeholder user info.
# (Many people keep personalized values in their local copy of this repo.)
if ! grep -qE '^[[:space:]]*name[[:space:]]*=[[:space:]]*[^[:space:]]' "$DOTFILES_DIR/gitconfig" 2>/dev/null; then
    echo -e "${YELLOW}Remember to edit $DOTFILES_DIR/gitconfig (symlinked to ~/.gitconfig) with your name, email, and GPG/SSH signing key.${NC}"
fi