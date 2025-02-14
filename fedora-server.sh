#!/bin/bash

function first_run() {
    if [ "${EUID}" -eq 0 ]; then
        exit 1
    fi
    ###
    echo "$(whoami)   ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    ###
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
    sudo sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ selinux=0"/' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    ###
    if ! dnf list installed "cronie" &> /dev/null; then
        sudo dnf install cronie -y
    fi
    ###
    (crontab -l  ; echo "@reboot $SCRIPT second_run") | crontab -
    ###
    sudo reboot
}

function second_run() {
    ###
    (crontab -l  | grep -v "@reboot $SCRIPT second_run") | crontab -
    ###
    echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf
    echo 'max_parallel_downloads=20' | sudo tee -a /etc/dnf/dnf.conf
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    sudo dnf update -y
    ###
    if ! dnf list installed "samba" &> /dev/null; then
        sudo dnf install samba -y
        sudo systemctl enable --now smb
        sudo firewall-cmd --permanent --add-service=samba
        sudo firewall-cmd --reload
        sudo smbpasswd -a $(whoami)
    fi
    ###
    if ! dnf list installed "cockpit" &> /dev/null; then
        sudo dnf install cockpit pcp python3-pcp -y
        sudo systemctl enable --now cockpit.socket
        sudo systemctl enable --now pmlogger.service
        sudo firewall-cmd --add-service=cockpit --permanent
        sudo firewall-cmd --reload
    fi
    ###
    if ! dnf list installed "jellyfin-server" &> /dev/null; then
        sudo dnf install jellyfin-server jellyfin-web intel-media-driver -y
        sudo dnf install --allowerasing ffmpeg-libs -y
        sudo usermod -aG $(whoami) jellyfin
        sudo systemctl enable --now jellyfin.service
    fi
    ###
    if ! dnf list installed "qbittorrent-nox" &> /dev/null; then
        sudo useradd -r -s /usr/sbin/nologin -m qbittorrent
        sudo usermod -aG $(whoami) qbittorrent
        sudo dnf install qbittorrent-nox -y
        sudo -u qbittorrent qbittorrent-nox
    fi
    ###
    if ! dnf list installed "sing-box-beta" &> /dev/null; then
        sudo dnf config-manager addrepo --from-repofile=https://sing-box.app/sing-box.repo
        sudo dnf install sing-box-beta -y
    fi
    ###
    if ! dnf list installed "nginx" &> /dev/null; then
        sudo dnf install nginx -y
        sudo usermod -aG $(whoami) nginx
        sudo firewall-cmd --add-service=http --permanent
        sudo firewall-cmd --add-service=https --permanent
        sudo firewall-cmd --reload
        sudo systemctl enable --now nginx.service
    fi
    ###
    if ! dnf list installed "nodejs" &> /dev/null; then
        sudo dnf install nodejs nodemon -y
    fi
    ###
    if ! dnf list installed "powershell" &> /dev/null; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc -y
        curl https://packages.microsoft.com/config/rhel/9/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
        sudo dnf makecache
        sudo dnf install powershell -y
    fi
}

${1:-first_run}
