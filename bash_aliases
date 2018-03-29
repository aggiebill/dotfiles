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

#To get GPG signing working with git
export GPG_TTY=$(tty)

#apt helpers
alias update="sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade"
alias cleanup='echo "Cleaning Up" && sudo apt -f install && sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean'

#Virtual Box helpers
alias mediavm='VBoxManage startvm "xubuntu-media-test" --type headless'
alias dockervm='VBoxManage startvm "xubuntu-docker-test" --type headless'

#VNC helpers
alias vncchromebook='vncserver :1 -geometry 1366x768 -depth 24'

#Exports for python virtualenvs
#http://docs.python-guide.org/en/latest/dev/virtualenvs/
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=$HOME/Devel
source /usr/local/bin/virtualenvwrapper.sh

#For aliases we don't want to check into git
#Things like path names and internal network information
if [ -f ~/.bash_aliases_private ]; then
    . ~/.bash_aliases_private
fi
