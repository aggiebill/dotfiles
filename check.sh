#!/bin/bash

# dotfiles/check.sh
# Feature-by-feature status check for the dotfiles setup on this machine.
# Run with: ./check.sh
# It will source bash_aliases if present for accurate PATH/alias checks.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=== Dotfiles Status Check ==="
echo "Dotfiles dir: $DOTFILES_DIR"
echo "Hostname: $(hostname)"
echo "Date: $(date)"
echo

# Source aliases if available for PATH etc.
if [ -f ~/.bash_aliases ]; then
  source ~/.bash_aliases 2>/dev/null || true
fi

# Helper functions
check_symlink() {
  local name="$1"
  local target="$2"
  local expected="$3"
  printf "%-35s " "$name:"
  if [ -L "$target" ]; then
    local real=$(readlink -f "$target" 2>/dev/null || echo "broken")
    local exp_real=$(readlink -f "$expected" 2>/dev/null || echo "$expected")
    if [ "$real" = "$exp_real" ]; then
      echo "✅ OK (→ $target)"
    else
      echo "⚠️  WRONG TARGET (→ $real, expected $expected)"
    fi
  else
    echo "❌ MISSING or not symlink"
  fi
}

check_command() {
  local name="$1"
  local cmd="$2"
  local expected_version="$3"
  printf "%-35s " "$name:"
  if command -v "$cmd" >/dev/null 2>&1; then
    local ver=$($cmd --version 2>/dev/null | head -1 || echo "unknown")
    if [ -n "$expected_version" ] && [[ "$ver" == *"$expected_version"* ]]; then
      echo "✅ OK ($ver)"
    else
      echo "✅ PRESENT ($ver)"
    fi
  else
    echo "❌ MISSING"
  fi
}

check_file() {
  local name="$1"
  local path="$2"
  printf "%-35s " "$name:"
  if [ -f "$path" ]; then
    echo "✅ EXISTS"
  else
    echo "❌ MISSING"
  fi
}

check_dir() {
  local name="$1"
  local path="$2"
  printf "%-35s " "$name:"
  if [ -d "$path" ]; then
    echo "✅ EXISTS ($(ls "$path" 2>/dev/null | wc -l) items)"
  else
    echo "❌ MISSING"
  fi
}

check_grep() {
  local name="$1"
  local file="$2"
  local pattern="$3"
  printf "%-35s " "$name:"
  if [ -f "$file" ] && grep -q "$pattern" "$file" 2>/dev/null; then
    echo "✅ OK"
  else
    echo "❌ MISSING or not matching"
  fi
}

echo "=== 1. Core Symlinks ==="
check_symlink "bash_aliases"     ~/.bash_aliases     "$DOTFILES_DIR/bash_aliases"
check_symlink "vimrc"            ~/.vimrc            "$DOTFILES_DIR/vimrc"
check_symlink "gitconfig"        ~/.gitconfig        "$DOTFILES_DIR/gitconfig"
check_symlink "vim dir"          ~/.vim              "$DOTFILES_DIR/vim"
check_symlink "nvim init.vim"    ~/.config/nvim/init.vim "$DOTFILES_DIR/nvim/init.vim"
check_symlink "nvim lua dir"     ~/.config/nvim/lua  "$DOTFILES_DIR/nvim/lua"
check_symlink "fastfetch config" ~/.config/fastfetch/config.jsonc "$DOTFILES_DIR/fastfetch/config.jsonc"

echo
echo "=== 2. GPG / gnupg ==="
check_dir  "gnupg dir" ~/.gnupg
check_symlink "gpg.conf"     ~/.gnupg/gpg.conf     "$DOTFILES_DIR/gnupg/gpg.conf"
check_symlink "gpg-agent.conf" ~/.gnupg/gpg-agent.conf "$DOTFILES_DIR/gnupg/gpg-agent.conf"
check_symlink "dirmngr.conf" ~/.gnupg/dirmngr.conf "$DOTFILES_DIR/gnupg/dirmngr.conf"
if [ -d ~/.gnupg ]; then
  perms=$(stat -c %a ~/.gnupg 2>/dev/null || echo "???")
  printf "%-35s " "gnupg perms (should be 700):"
  if [ "$perms" = "700" ]; then echo "✅ $perms"; else echo "⚠️  $perms"; fi
fi

echo
echo "=== 3. Neovim (latest via tarball) ==="
check_command "nvim (in PATH)" nvim "0.12"
if [ -L ~/.local/bin/nvim ]; then
  real=$(readlink -f ~/.local/bin/nvim)
  echo "  Symlink: ~/.local/bin/nvim → $real"
  if [[ "$real" == *nvim-linux-x86_64* ]]; then
    echo "  ✅ Using tarball install (x86_64)"
  fi
else
  echo "  ❌ No ~/.local/bin/nvim symlink"
fi
check_dir "nvim tarball dir" ~/.local/nvim-linux-x86_64
check_file "nvim binary" ~/.local/nvim-linux-x86_64/bin/nvim

echo
echo "=== 4. treesitter setup ==="
check_dir "treesitter plugin (pinned)" ~/.vim/pack/plugins/start/nvim-treesitter
if [ -d ~/.vim/pack/plugins/start/nvim-treesitter ]; then
  cd ~/.vim/pack/plugins/start/nvim-treesitter
  tag=$(git describe --tags --always 2>/dev/null || echo "no git")
  printf "%-35s " "treesitter plugin version:"
  if [[ "$tag" == v0.9.3* ]]; then
    echo "✅ $tag (pinned as intended)"
  else
    echo "⚠️  $tag (not the pinned v0.9.3)"
  fi
fi
check_command "tree-sitter CLI" tree-sitter "0.26"
check_dir "treesitter parsers (in pack)" ~/.vim/pack/plugins/start/nvim-treesitter/parser
parsers=$(ls ~/.vim/pack/plugins/start/nvim-treesitter/parser/ 2>/dev/null | grep -E '\.so$' | wc -l || echo 0)
printf "%-35s " "parsers in plugin dir:"
if [ "$parsers" -gt 5 ]; then echo "✅ $parsers parsers (incl. python/bash expected)"; else echo "⚠️  only $parsers"; fi

# Check lua config
if [ -f ~/.config/nvim/lua/treesitter.lua ]; then
  printf "%-35s " "treesitter.lua present:"
  if grep -q "nvim-treesitter.configs" ~/.config/nvim/lua/treesitter.lua; then
    echo "✅ uses classic configs.setup"
  else
    echo "⚠️  unexpected content"
  fi
  if grep -q "python.*bash" ~/.config/nvim/lua/treesitter.lua; then
    echo "  ✅ ensure_installed includes python + bash"
  fi
else
  echo "❌ ~/.config/nvim/lua/treesitter.lua missing"
fi

echo
echo "=== 5. Vim / colors (submodules) ==="
check_dir "vim/bundle" ~/.vim/bundle
if [ -d ~/.vim/bundle/base16-vim/colors ]; then
  count=$(ls ~/.vim/bundle/base16-vim/colors/ | wc -l)
  printf "%-35s " "base16-vim colors:"
  if [ "$count" -gt 50 ]; then echo "✅ $count colors"; else echo "⚠️  only $count"; fi
fi
if [ -f ~/.vim/bundle/vim-colors-solarized/colors/solarized.vim ]; then
  echo "  ✅ solarized colors present"
else
  echo "  ❌ solarized missing"
fi

echo
echo "=== 6. PATH and shell setup ==="
printf "%-35s " "PATH starts with ~/.local/bin:"
if echo "$PATH" | grep -q "^$HOME/.local/bin:" ; then
  echo "✅ YES (prepended)"
elif echo "$PATH" | grep -q "$HOME/.local/bin" ; then
  echo "⚠️  present but not first"
else
  echo "❌ MISSING"
fi
printf "%-35s " "EDITOR/VISUAL:"
echo "${EDITOR:-unset} / ${VISUAL:-unset}"
printf "%-35s " "vim alias to nvim:"
if alias vim 2>/dev/null | grep -q nvim; then echo "✅ YES"; else echo "❌ NO"; fi

echo
echo "=== 7. Python / uv / ruff ==="
check_command "uv" uv
check_command "ruff" ruff
check_file "pynvim (for neovim python provider)" /usr/bin/pynvim-python || check_command "python3 -c 'import pynvim'" "python3"

echo
echo "=== 8. fastfetch + MOTD ==="
check_command "fastfetch" fastfetch
check_file "MOTD script" /etc/profile.d/mymotd.sh
if [ -f /etc/profile.d/mymotd.sh ]; then
  if grep -q fastfetch /etc/profile.d/mymotd.sh; then
    echo "  ✅ MOTD uses fastfetch"
  else
    echo "  ⚠️  MOTD exists but not fastfetch"
  fi
fi
check_symlink "fastfetch user config" ~/.config/fastfetch/config.jsonc "$DOTFILES_DIR/fastfetch/config.jsonc"

echo
echo "=== 9. Legacy cleanup ==="
printf "%-35s " "neofetch removed:"
if ! dpkg -s neofetch >/dev/null 2>&1; then echo "✅ not installed"; else echo "❌ still present"; fi

echo
echo "=== 10. Other (GPG_TTY, aliases, etc.) ==="
printf "%-35s " "GPG_TTY exported:"
if [ -n "$GPG_TTY" ]; then echo "✅ $GPG_TTY"; else echo "⚠️  not set in this shell"; fi
printf "%-35s " "update/cleanup aliases:"
if alias update >/dev/null 2>&1 && alias cleanup >/dev/null 2>&1; then echo "✅ present"; else echo "❌ missing"; fi

echo
echo "=== Summary ==="
echo "Run this script anytime with ./check.sh (after sourcing or in new shell)."
echo "For full treesitter health: nvim -c 'checkhealth nvim-treesitter' +q"
