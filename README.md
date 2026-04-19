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
sudo apt install apt-transport-https neovim build-essential htop git dnsutils software-properties-common fastfetch curl
```
Additionally, it installs:
- uv: Modern Python package manager
- ruff: Python linter and formatter

## Python Setup
Using uv for Python package management and ruff for linting/formatting.

## GPG Setup
To import a GPG key from a file (e.g., a public key or private key export):
```bash
gpg --import /path/to/your/key.asc
```
After importing, verify the key:
```bash
gpg --list-keys
```
If importing a private key, you may need to trust it:
```bash
gpg --edit-key <key-id>
# Then type 'trust' and select the trust level.
```
Ensure your GPG configs are symlinked via the install script for modern compatibility.

## GPG Environment-Specific Setup
This repo defaults to desktop use, so the packaged GPG settings are aimed at a GUI-capable machine.

### Desktop (default)
- Use the repo as-is; the current `gnupg/` config is intended for desktop GPG usage.
- GUI pinentry is expected, and the default pinentry program works with your desktop environment.
- If you sign Git commits, make sure your signing key is configured in Git.

### Headless server
- Install `pinentry-curses` for terminal-based passphrase entry.
- Set `GPG_TTY=$(tty)` in your shell environment before using GPG.
- Override `pinentry-program` if needed, for example:
  ```bash
  echo 'pinentry-program /usr/bin/pinentry-curses' >> ~/.gnupg/gpg-agent.conf
  ```
- The repo already uses `no-honor-keyserver-url` in `gnupg/dirmngr.conf`, which is safer for server environments.

## Cleanup
No longer needed with modern tools.

### MOTD
The install script sets up fastfetch in /etc/profile.d/mymotd.sh

# Thanks to:
* @chriskempson for [base16-vim](https://github.com/chriskempson/base16-vim)
* @altercation for [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
* For the number of other GitHub dotfile repos I borrowed from:
  * @tpope for numerous useful repos
  * @webpro for [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
  * @kdeldycke for [dotfiles](https://github.com/kdeldycke/dotfiles)
