#!/bin/bash

SCRIPT=$(realpath "$0")

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
    if ! dnf list installed "cockpit" &> /dev/null; then
        sudo dnf install cockpit cockpit-pcp -y
        sudo systemctl enable --now cockpit.socket
        sudo firewall-cmd --add-service=cockpit --permanent
        sudo firewall-cmd --reload
    fi
    ###
    if ! dnf list installed "jellyfin-server" &> /dev/null; then
        sudo dnf install jellyfin-server jellyfin-web intel-media-driver -y
        sudo usermod -aG adner jellyfin
        sudo systemctl enable --now jellyfin.service
    fi
    ###
    if ! dnf list installed "qbittorrent-nox" &> /dev/null; then
        sudo useradd -r -s /usr/sbin/nologin -m qbittorrent
        sudo usermod -aG adner qbittorrent
        sudo dnf install qbittorrent-nox -y
        sudo -u qbittorrent qbittorrent-nox
    fi

}

${1:-first_run}
