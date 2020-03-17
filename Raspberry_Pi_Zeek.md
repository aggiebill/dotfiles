# Yet Another Guide to Setting up Zeek on the Raspberry Pi

```bash
sudo raspi-config
```
*  Change password
*  Change network settings
    *  Change hostname `zeekpi`
    *  Enable predicable network interface names
*  Boot Options
    *  Desktop / CLI - Text Console, requiring user to login
    *  **Might revisit**
*  Localization options
    *  Change locale - en_US.UTF-8
    *  Change timezone - None of the Above, UTC
*  Advanced Options
    *  Expand file system
*  Exit and Reboot

From host computer enter this to make life easier:
```bash
ssh-copy-id pi@zeekpi.local
scp ~/.ssh/github_id_rsa* pi@zeekpi.local:~/.ssh
```
```bash
sudo apt install apt-transport-https
alias update="sudo apt update && sudo apt -y upgrade && sudo apt -y dist-upgrade"
alias cleanup='echo "Cleaning Up" && sudo apt -f install && sudo apt -y autoremove && sudo apt -y autoclean && sudo apt -y clean'
update
cleanup
sudo apt install byobu vim build-essential htop git dnsutils software-properties-common python3 python3-pip python-dev cmake make gcc g++ flex bison libpcap-dev libssl-dev swig zlib1g-dev libmaxminddb-dev postfix curl

apt-get install cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev swig zlib1g-dev libgeoip-dev build-essential libelf-dev raspberrypi-kernel-headers
update
cleanup
git clone git@github.com:aggiebill/dotfiles.git
ln -s dotfiles/bash_aliases .bash_aliases
ln -s dotfiles/vim .vim
ln -s dotfiles/vimrc .vimrc
source .bashrc
```
https://holdmybeersecurity.com/2019/04/03/part-1-install-setup-zeek-pf_ring-on-ubuntu-18-04-on-proxmox-5-3-openvswitch/
git clone https://github.com/ntop/PF_RING.git
cd PF_RING/kernel
make
insmod ./pf_ring.ko
cd ../userland
make
cd lib
./configure --prefix=/opt/PF_RING
sudo make install
cd ../libpcap
./configure --prefix=/opt/PF_RING
sudo make install
cd ../tcpdump-*
./configure --prefix=/opt/PF_RING
sudo make install
cd ../../kernel
make
sudo make install
sudo -- sh -c 'echo "pf_ring" >> /etc/modules'
reboot
lsmod | grep pf_ring

```  
wget http://packages.ntop.org/apt/ntop.key
sudo apt-key add ntop.key
sudo -- sh -c 'echo "deb http://apt.ntop.org/stretch_pi armhf/" > /etc/apt/sources.list.d/ntop.list'
sudo -- sh -c 'echo "deb http://apt.ntop.org/stretch_pi all/" >> /etc/apt/sources.list.d/ntop.list'
```

ifconfig
sudo ip link set enxb827ebd41043 up
sudo ip link set enxb827ebd41043 promisc on
ifconfig
add these lines to rc.local file

Start installing Zeek
```bash
cd ~
git clone --recursive https://github.com/zeek/zeek
cd zeek
./configure --with-pcap=/opt/PF_RING --prefix=/opt/zeek/

make
sudo make install

```
