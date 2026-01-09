#!/bin/bash

function first_run() {
    if [ "${EUID}" -eq 0 ]; then
        exit 1
    fi
    ###
    echo "$(whoami) ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$(whoami)
    ###
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    #sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' /etc/default/grub
    sudo grubby --update-kernel=ALL --args "selinux=0 i915.force_probe=*"
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
    if ! dnf5 list --installed "samba" &> /dev/null; then
        sudo dnf install samba -y
        sudo systemctl enable --now smb
        sudo firewall-cmd --permanent --add-service=samba
        sudo firewall-cmd --reload
        sudo smbpasswd -a $(whoami)
    fi
    ###
    if ! dnf5 list --installed "cockpit" &> /dev/null; then
        sudo dnf install cockpit pcp python3-pcp -y
        sudo systemctl enable --now cockpit.socket
        sudo systemctl enable --now pmlogger.service
        sudo firewall-cmd --add-service=cockpit --permanent
        sudo firewall-cmd --reload
        sudo dnf install qemu-kvm-core libvirt virt-install cockpit-machines guestfs-tools -y
        sudo systemctl enable --now libvirtd 
    fi
    ###
    if ! dnf5 list --installed "jellyfin-server" &> /dev/null; then
        sudo dnf install jellyfin-server jellyfin-web intel-media-driver -y
        sudo dnf install --allowerasing ffmpeg-libs -y
        sudo usermod -aG $(whoami) jellyfin
        sudo systemctl enable --now jellyfin.service
    fi
}

${1:-first_run}
