# WSL Environment Deltas for dotfiles

**Date**: 2026 (first application of this repo to WSL)
**Host**: Ubuntu 26.04 LTS ("Resolute Raccoon") on WSL2
**WSL Kernel**: 6.6.114.1-microsoft-standard-WSL2
**User**: bill
**Repo path**: ~/github_aggiebill/dotfiles
**Status**: Partially applied manually/semi-automatically before this analysis. Symlinks for bash_aliases, vimrc, .vim, and gnupg/* were already in place.

This document records differences between the assumptions in the dotfiles repo (designed for native Ubuntu and Raspberry Pi) and a modern WSL2 environment. It is intended to guide future uses of this repo on WSL and to highlight required manual steps or repo improvements.

## 1. What Was Already Matching / Applied

- `~/.bash_aliases` → symlinked (includes apt helpers, ls aliases, GPG_TTY, EDITOR=vim, .local/bin PATH, private aliases hook)
- `~/.vimrc` → symlinked (solarized + custom programming settings; works with both vim and neovim)
- `~/.vim/` → symlinked (large collection of base16 and solarized colors)
- `~/.gnupg/{gpg.conf,gpg-agent.conf,dirmngr.conf}` → symlinked
- `uv` (0.11.15) and `ruff` (via `uv tool install`) installed at `~/.local/bin`
- `fastfetch` package + WSL-optimized `~/.config/fastfetch/config.jsonc` installed (symlinked from repo)
- `byobu`, `tmux`, `neovim`, `vim`, full `gnupg` suite, `build-essential`, etc. present (some from prior user setup)
- Python 3.14.4 (system) + uv primary management
- Node.js via nvm (v18/20/22)
- SSH commit signing configured (see below)
- systemd enabled in WSL (`/etc/wsl.conf`)
- `.bashrc` already sources `~/.bash_aliases` (standard Ubuntu skeleton)

## 1.5. 2026 WSL Enhancements (Added During First WSL Application)

**Direction**: Neovim replaces vim as the primary editor. Fastfetch replaces neofetch.

These improvements were made so the repo works excellently on WSL without requiring manual hacks:

- **Neovim support**: New `nvim/init.vim` in the repo. It reuses the existing `.vimrc` + `~/.vim/colors/` (solarized + all base16 themes) via `runtimepath`, then layers `termguicolors`, `clipboard=unnamedplus`, mouse, etc. Symlinked to `~/.config/nvim/init.vim` by install.sh. `vim` and `nvim` now behave consistently.
- **Fastfetch**: Proper `fastfetch/config.jsonc` (WSL-aware modules including separate Disk C: entry for the 9p mount, compact small logo, clean for MOTD use). Symlinked + installed automatically.
- **Private aliases**: Added `bash_aliases_private.example` (with full documented WSL block: cdc/cdw, clip.exe, ipwin, wsl-*, etc.). The existing hook in `bash_aliases` sources `~/.bash_aliases_private` if present. A ready-to-use version was also created for this machine.
- **GPG hygiene**: install.sh now does `chmod 700 ~/.gnupg` (fixes the long-standing unsafe permissions warning).
- **Package list**: Updated to `bind9-dnsutils` (with comment) + explicit `neovim` + `vim`.
- **All neofetch references removed** from source. Fastfetch (with dedicated WSL config) fully replaces it. install.sh will even purge neofetch if it finds the old package.
- **Neovim is now primary**: `EDITOR`/`VISUAL` = nvim, `alias vim='nvim'`, gitconfig template updated. The vim/ + vimrc tree is kept as the *shared configuration backend* so classic vim still works when needed (many scripts/tools call `vim`). nvim/init.vim bootstraps it + adds termguicolors, clipboard, etc.
- **Color schemes converted to submodules** (2026): Removed all vendored copies of base16-vim and vim-colors-solarized from `vim/colors/`. They are now proper git submodules under `vim/bundle/`. This keeps the themes up-to-date. Updated vimrc + nvim/init.vim + README + install.sh accordingly. (Note: classic Vim may have some syntax warnings on the very old solarized code; Neovim works cleanly.)
- **Removed legacy `vim/syntax/python.vim`** (2015 hdima/python-syntax): This outdated file (pre-f-strings, pre-match/case) has been deleted along with the empty `vim/syntax/` directory. It was overriding Neovim's better built-in syntax file due to runtimepath. The repo now strongly recommends Tree-sitter via `nvim-treesitter` for Python and other languages (see README).
- **install.sh improvements**: Now creates the nvim + fastfetch symlinks + directories automatically.

These changes make the dotfiles repo much more "drop-in" friendly for future WSL (or modern Ubuntu) machines while preserving full backward compatibility with classic vim + Raspberry Pi / headless use cases.

## 2. Critical Deltas & Manual Interventions Required

### Git Configuration & Commit Signing (MOST IMPORTANT)

**Repo assumption**: GPG-based signing (`[commit] gpgsign = true`, `signingkey` in `[user]` section of gitconfig template).

**Actual WSL setup**:
- Uses **SSH-based signing** (`gpg.format = ssh`)
- Key: `~/.ssh/id_ed25519_signing`
- Allowed signers: `~/.config/git/allowed_signers`
- Full `[user]` name + email + custom sections present in `~/.gitconfig` (not a symlink)

**Action**: **NEVER** run the symlink step for `.gitconfig` from install.sh or manually on this machine. It would:
- Overwrite name/email
- Switch from SSH signing back to (non-existent) GPG signing
- Break `git commit` signatures

**Recommendation for repo**: Make gitconfig a template with placeholders or document SSH vs GPG variants. Provide a `gitconfig.ssh` or `gitconfig.gpg` option.

Current `.gitconfig` (preserved):
```ini
[user]
    name = Aggie Bill
    email = 8082637+aggiebill@users.noreply.github.com
    signingkey = ~/.ssh/id_ed25519_signing.pub
[commit]
    gpgsign = true
[core]
    autocrlf = input
    editor = vim
[gpg]
    format = ssh
[gpg "ssh"]
    allowedSignersFile = ~/.config/git/allowed_signers
```

### GPG / pinentry

- `gpg-agent.conf` forces `pinentry-program /usr/bin/pinentry-curses`
  - This is **actually appropriate and good** for WSL (no GUI pinentry installed by default; WSLg XWayland would be required for graphical pinentry).
  - Matches the "Headless server" guidance in README.md even though README claims "desktop defaults".
- **Repo bug**: `install.sh` + symlinks leave `~/.gnupg` at 755 (world-readable). GPG emits `WARNING: unsafe permissions on homedir` on every invocation.
  - **Fixed during this setup** (2026-05): `chmod 700 ~/.gnupg` (user-owned, no sudo needed).
- No GPG keys imported yet (`gpg --list-keys` empty). User relies on SSH signing for git.
- `bash_aliases` unconditionally does `export GPG_TTY=$(tty)`. This can produce errors in non-interactive contexts (e.g. some scripts, IDE terminals). Common pattern but ideally guarded:
  ```bash
  if [ -t 0 ]; then export GPG_TTY=$(tty); fi
  ```

**Future WSL GPG notes**:
- For GUI pinentry under WSLg: install `pinentry-gnome3` or `pinentry-qt` and update agent.conf + `update-alternatives`.
- GPG agent socket forwarding from Windows host is another advanced pattern (not used here).

### MOTD + fastfetch (Now Properly Supported)

The repo now ships a dedicated WSL-optimized fastfetch config at `fastfetch/config.jsonc` (symlinked to `~/.config/fastfetch/config.jsonc` by install.sh).

`install.sh` creates `/etc/profile.d/mymotd.sh` containing just `fastfetch` (no more neofetch references anywhere in the source).

See also the new `nvim/` support and `bash_aliases_private.example` added during the first WSL application of this repo.

### Package Name / Availability Deltas (apt)

| Repo / README          | Actual in Ubuntu 26.04 WSL | Notes |
|------------------------|----------------------------|-------|
| `dnsutils`            | Virtual; provided by `bind9-dnsutils` (already present) | `dig`, `nslookup` work. `apt install dnsutils` succeeds via Provides: but dpkg -s dnsutils reports not installed. |
| `vim` (install.sh)    | Both `vim` + `neovim` present | README claims neovim in one place, script installs vim. User's env had neovim independently. Both fine; vimrc is mostly compatible. |
| `neofetch` (MOTD)     | Removed from all repo sources. Only fastfetch + dedicated config is used. |
| `byobu`               | Installed (from prior RPi/legacy setup) | Not in current install.sh apt list (was in older Raspberry_Pi_Zeek.md guide). Harmless. |
| `apt-transport-https` | Present (transitional in modern apt) | Still listed for compatibility. |

**Safe install command** (if re-running parts of setup):
```bash
sudo apt update
sudo apt install -y apt-transport-https vim build-essential htop git bind9-dnsutils software-properties-common fastfetch curl neovim
# (or keep "dnsutils" — it works as virtual)
```

### Shell & PATH

- `.local/bin` PATH additions appear in **three** places now:
  1. `bash_aliases` (if [ -d ~/.local/bin ])
  2. `~/.bashrc` (`. "$HOME/.local/bin/env"` from uv installer)
  3. uv/ruff installers
- Redundant but harmless. uv's env script is the modern preferred way.
- `TERM=xterm-256color` forced in bash_aliases. Usually overridden by Windows Terminal / VSCode to something better (xterm-256color, alacritty, wezterm, etc.). Fine for compatibility.

### Irrelevant Aliases for WSL (harmless)

From `bash_aliases`:
- `gsuon` / `gsuoff` (xhost root for graphical sudo under Wayland)
- `mediavm`, `dockervm` (VirtualBox headless VMs)
- `vncchromebook`

These can stay. Consider moving niche/hardware-specific aliases to `~/.bash_aliases_private` (the hook already exists).

### WSL-Specific Environmental Realities (Not Covered by Repo)

- **Filesystem**: `/mnt/c` etc. use 9p protocol → case-sensitivity quirks, slow for many small files (e.g. node_modules, .git), Windows ACL mapping. Keep large builds/repos in Linux filesystem (`~` or `/home`).
- **Networking**: `networkingMode=mirrored` (in ~/.wslconfig). Affects localhost, DNS, port forwarding. `systemd=true` changes resolv.conf management.
- **No local X11/GUI** by default. Install `wslu` or enable WSLg for `wslview`, graphical apps, GUI pinentry.
- **Windows interop pollution**: Windows `python.exe`, `node.exe`, `git.exe` etc. can appear in PATH before Linux versions depending on order. Use full paths or `wslpath`.
- **Performance**: AV/Windows Defender real-time protection can slow compiles. Exclude WSL paths in Windows Security.
- **User experience**: VSCode Remote-WSL, Windows Terminal, and 1Password / Windows Hello SSH agent integration are common (not in dotfiles scope).
- **.wslconfig** and **/etc/wsl.conf** are WSL-specific (this env has mirrored networking + systemd + default user).

### Other Tools Present (Beyond dotfiles Scope)

- Grok CLI (`~/.grok`)
- nvm + multiple Node versions
- VSCode server
- tmux + byobu
- Partial .NET (`~/.dotnet/corefx` only — not full SDK)
- Many Python system packages (from Ubuntu 26.04 python3-* metapackages)

These are user additions layered on top of the minimal dotfiles philosophy.

## 3. Recommended Repo Improvements (for Maintainability on WSL + Modern Ubuntu)

1. **Split or template gitconfig** — document SSH signing as first-class option (very common now on GitHub).
2. (done) MOTD now uses fastfetch + dedicated WSL config from the repo.
3. **Secure ~/.gnupg** in install.sh after mkdir/ln:
   ```bash
   chmod 700 ~/.gnupg
   chmod 600 ~/.gnupg/*.conf 2>/dev/null || true   # only if not symlinks, or handle targets
   ```
4. **Guard GPG_TTY**:
   ```bash
   [[ -t 1 ]] && export GPG_TTY=$(tty)
   ```
5. **Package list hygiene**: 
   - Note that `dnsutils` is virtual on Debian 12+/Ubuntu 24.04+.
   - Consider adding `neovim` explicitly or choosing one editor.
   - Add `ripgrep`, `fd-find`, `bat`, `fzf` as optional "modern CLI" section? (or keep minimal).
6. **Add WSL detection** in bash_aliases or a new `wsl_aliases`:
   ```bash
   if grep -qi microsoft /proc/version; then
       export WSL=1
       # Windows-specific PATH tweaks, aliases for clip.exe, etc.
   fi
   ```
7. **Document pinentry choices** more clearly (curses is good default for servers/WSL without GUI).
8. **Test on non-Debian**? (but scope is Ubuntu/RPi).
9. (optional future) Consider an update-motd.d script for even better systemd/WSL integration.

## 4. Quick Verification Commands (Post-Setup)

```bash
# Core dotfiles
ls -l ~/.bash_aliases ~/.vimrc ~/.vim ~/.gnupg/gpg.conf | cat
source ~/.bash_aliases 2>&1 | cat

# No GPG warnings
gpg --list-keys 2>&1 | cat

# Fastfetch works
fastfetch

# MOTD script
cat /etc/profile.d/mymotd.sh

# Git signing still SSH (critical)
git config --get commit.gpgsign
git config --get gpg.format

# Editor
echo $EDITOR $VISUAL
vim --version | head -1
nvim --version | head -1

# uv/ruff
uv --version && ruff --version

# DNS tools
dig +short example.com | head -1
```

## 5. How This Environment Was Set Up (Chronology Notes)

1. Base WSL Ubuntu 26.04 provisioned (with systemd, mirrored networking).
2. Various dev tools installed independently (nvm, Node, VSCode Remote, uv, ruff, neovim, byobu, etc.).
3. Dotfiles repo cloned to ~/github_aggiebill/dotfiles.
4. Manual or partial install.sh run: created the four main symlinks + gnupg.
5. Custom `.gitconfig` with SSH signing created (overwriting or instead of repo version).
6. 2026 WSL polish pass (phase 2): Neovim made the explicit primary editor (EDITOR=nvim + alias vim=nvim, gitconfig template updated, comments clarified everywhere). Fastfetch fully replaces neofetch with package purge logic. Shared vim/ backend preserved for compatibility. All changes documented here.

---

**Maintained by**: aggiebill (adapted during first WSL application)
**Next steps for user**: Run the documented sudo command for MOTD, test a login shell, consider adding WSL-specific private aliases if needed. Do not blindly re-run full `install.sh` without reviewing the gitconfig step.
