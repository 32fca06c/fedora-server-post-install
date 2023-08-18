#!/bin/bash
wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && sudo rpm --import repomd.xml.key
sudo dnf config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-rpm
sudo dnf install coolwsd CODE-brand -y
sudo coolconfig set ssl.enable false
sudo coolconfig set ssl.termination true
sudo coolconfig set storage.wopi.host nextcloud.example.com
sudo coolconfig set-admin-password
sudo systemctl enable --now coolwsd
