# dotfiles
These are my personal dotfiles and my attempt at getting more organized.

# Installation

**Recommended (with submodules):**
```bash
git clone --recurse-submodules https://github.com/aggiebill/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

If you already cloned without submodules:
```bash
git submodule update --init --recursive
```

Download the repo as a zip, extract, and run the install script (submodules will be missing):
```bash
chmod +x install.sh
./install.sh
```
This will create symlinks for the dotfiles, install latest Neovim (tarball), pinned nvim-treesitter, tree-sitter CLI, uv/ruff, and set up MOTD + submodules.

After `./install.sh`, open Neovim once to let treesitter auto-install the parsers listed in `nvim/lua/treesitter.lua` (python, bash, etc.), or run `:TSInstall python bash` inside Neovim.

## Manual Installation (fallback)
```bash
ln -s <dotfiles_dir>/bash_aliases ~/.bash_aliases
ln -s <dotfiles_dir>/vimrc ~/.vimrc
ln -s <dotfiles_dir>/gitconfig ~/.gitconfig
ln -s <dotfiles_dir>/vim ~/.vim
# Neovim (installed via tarball by install.sh; manual equivalent below)
mkdir -p ~/.local/bin ~/.config/nvim
# (download + extract nvim-linux-x86_64.tar.gz to ~/.local/nvim-linux-x86_64 then ln -s .../bin/nvim ~/.local/bin/nvim)
ln -s <dotfiles_dir>/nvim/init.vim ~/.config/nvim/init.vim
ln -s <dotfiles_dir>/nvim/lua ~/.config/nvim/lua
ln -s <dotfiles_dir>/fastfetch ~/.config/fastfetch # WSL-optimized fastfetch (replaces neofetch)
ln -s <dotfiles_dir>/gnupg/* ~/.gnupg/
```

After manual setup, also:
- mkdir -p ~/.vim/pack/plugins/start
- git clone https://github.com/nvim-treesitter/nvim-treesitter ~/.vim/pack/plugins/start/nvim-treesitter
- cd that dir && git checkout v0.9.3
- Install tree-sitter CLI to ~/.local/bin as shown in install.sh
- Ensure ~/.local/bin is first in $PATH (see bash_aliases)

**Note:** After manual symlink setup, initialize submodules so color schemes work:
```bash
cd <dotfiles_dir>
git submodule update --init --recursive
```

## Required Packages
The install script installs these packages automatically (plus latest Neovim via official tarball, nvim-treesitter pinned, and tree-sitter CLI):
```bash
sudo apt install apt-transport-https vim build-essential htop git bind9-dnsutils software-properties-common fastfetch curl
# - Neovim is installed from the latest GitHub release (tar ball to ~/.local/nvim-...) because Ubuntu repos lag behind
# - vim is kept only for compatibility/scripts that call it
# - fastfetch replaces neofetch (neofetch is deprecated and not installed)
# - bind9-dnsutils provides dig/nslookup (old "dnsutils" name is a virtual package)
```

**Note on Neovim version:** We pin nvim-treesitter to v0.9.3 for compatibility. The install script handles the latest Neovim + pinned plugin + CLI. After install, start Neovim to let `ensure_installed` fetch the parsers for python/bash/etc. (or run `:TSInstall python bash`).
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
The install script sets up fastfetch (replacing neofetch) with a WSL-optimized config in /etc/profile.d/mymotd.sh and ~/.config/fastfetch/. Neovim is the primary editor.

### Legacy Vim syntax files
The old `vim/syntax/python.vim` (from hdima/python-syntax, last updated 2015) has been removed.  
Modern Neovim should use Tree-sitter for Python instead (see "Recommended Modern Setup" below).  
Classic `vim/syntax/` and `vim/colors/` directories are no longer used directly — color schemes now live in git submodules under `vim/bundle/`.

### Recommended Modern Setup (Neovim + Tree-sitter)
For the best Python (and other language) experience in Neovim, install `nvim-treesitter`:

```bash
mkdir -p ~/.vim/pack/plugins/start
git clone https://github.com/nvim-treesitter/nvim-treesitter.git ~/.vim/pack/plugins/start/nvim-treesitter
```

Then add this to your Neovim config (already partially prepared in `nvim/init.vim`):

```vim
" In nvim/init.vim or after loading
lua << EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "lua", "vim", "bash" },
  highlight = { enable = true },
  indent = { enable = true },
}
EOF
```

After first launch, run inside Neovim:
```
:TSInstall python
```

This completely replaces legacy `syntax/python.vim` files with superior, accurate highlighting and indentation.

# Thanks to:
* @chriskempson for [base16-vim](https://github.com/chriskempson/base16-vim) (included as git submodule)
* @altercation for [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized) (included as git submodule)
* For the number of other GitHub dotfile repos I borrowed from:
  * @tpope for numerous useful repos
  * @webpro for [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
  * @kdeldycke for [dotfiles](https://github.com/kdeldycke/dotfiles)
