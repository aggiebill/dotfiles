#apt helpers
alias update="sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade"
alias cleanup='echo "Cleaning Up" && sudo apt -f install && sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean'

#Virtual Box helpers
alias mediavm='VBoxManage startvm "xubuntu-media-test" --type headless'
alias dockervm='VBoxManage startvm "xubuntu-docker-test" --type headless'

#VNC helpers
alias vncchromebook='vncserver :1 -geometry 1366x768 -depth 24'
