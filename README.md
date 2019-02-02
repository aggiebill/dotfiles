# dotfiles
These are my personal dotfiles and my attempt at getting more organized.

# Installation
## Manual Installation
Until I get a better method for installing these files, it will largely be:
```bash
ln -s ~/Documents/src/<file> ~/.<file>
```
## Required Packages
These are my typical apt packages to get up and running:
```bash
sudo apt install byobu vim build-essential htop python3-pip python-dev python-pip ubuntu-restricted-addons ubuntu-restricted-extras git dnsutils
sudo apt install vim-gnome
```

## Cleanup
Since I like to use Python 3, I need to separate pip3 and pip2.  
```bash
python3 -m pip install -U --force-reinstall pip
python -m pip install -U --force-reinstall pip
```
After this, ```pip == pip2```.

### VirtualEnvWrapper

```bash
sudo -H pip3 install virtualenvwrapper
```

### Fix Citrix Receiver

```bash
sudo ln -s /usr/share/ca-certificates/mozilla/* /opt/Citrix/ICAClient/keystore/cacerts
```

# Thanks to:
* @chriskempson for [base16-vim](https://github.com/chriskempson/base16-vim)
* @altercation for [vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)
* For the number of other GitHub dotfile repos I borrowed from:
  * @tpope for numerous useful repos
  * @webpro for [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
  * @kdeldycke for [dotfiles](https://github.com/kdeldycke/dotfiles)
