#byobu configurations
export TERM=xterm-256color
#if [ -z "$_motd_listed" ]; then
#    case "$TMUX_PANE" in
#        %1) cat /run/motd.dynamic
#            export _motd_listed=yes
#            ;;
#        *)  ;;
#    esac
#fi

# To get GPG signing working with git
export GPG_TTY=$(tty)

export grepip="grep -oE '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'"

# Make vim default editor
export VISUAL="vim"
export EDITOR="$VISUAL"

# some more ls aliases
alias ll='ls -alF'
alias lh='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# To handle wayland and launching graphical applications as root
alias gsuon='xhost si:localuser:root'
alias gsuoff='xhost -si:localuser:root'

# apt helpers
alias update="sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade"
alias cleanup='echo "Cleaning Up" && sudo apt -f install && sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean'

# Virtual Box helpers
alias mediavm='VBoxManage startvm "xubuntu-media-test" --type headless'
alias dockervm='VBoxManage startvm "xubuntu-docker-test" --type headless'

# VNC helpers
alias vncchromebook='vncserver :1 -geometry 1366x768 -depth 24'

# Exports for python virtualenvs
# http://docs.python-guide.org/en/latest/dev/virtualenvs/
# Jumping on the pipenv bandwagon!
#export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
#export WORKON_HOME=$HOME/.virtualenvs
#export PROJECT_HOME=$HOME/Devel
#source /usr/local/bin/virtualenvwrapper.sh

if [ -d ~/.local/bin ]; then
    export PATH=$PATH:~/.local/bin
fi

#For aliases we don't want to check into git
#Things like path names and internal network information
if [ -f ~/.bash_aliases_private ]; then
    . ~/.bash_aliases_private
fi
