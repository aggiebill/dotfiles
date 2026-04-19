# dotfiles
These are my personal dotfiles and my attempt at getting more organized.

# Installation
Download the repo as a zip, extract, and run the install script:
```bash
chmod +x install.sh
./install.sh
```
This will create symlinks for the dotfiles and install necessary packages.

## Manual Installation (fallback)
```bash
ln -s <dotfiles_dir>/bash_aliases ~/.bash_aliases
ln -s <dotfiles_dir>/vimrc ~/.vimrc
ln -s <dotfiles_dir>/gitconfig ~/.gitconfig
ln -s <dotfiles_dir>/vim ~/.vim
ln -s <dotfiles_dir>/gnupg/* ~/.gnupg/
```

## Required Packages
The install script installs these packages automatically:
```bash
sudo apt install apt-transport-https vim build-essential htop git dnsutils software-properties-common neofetch curl
```
Additionally, it installs:
- uv: Modern Python package manager
- ruff: Python linter and formatter

## Python Setup
Using uv for Python package management and ruff for linting/formatting.

## Cleanup
No longer needed with modern tools.

### MOTD
The install script sets up neofetch in /etc/profile.d/mymotd.sh

# Thanks to:
* @chriskempson for [base16-vim](https://github.com/chriskempson/base16-vim)
* @altercation for [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
* For the number of other GitHub dotfile repos I borrowed from:
  * @tpope for numerous useful repos
  * @webpro for [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
  * @kdeldycke for [dotfiles](https://github.com/kdeldycke/dotfiles)
