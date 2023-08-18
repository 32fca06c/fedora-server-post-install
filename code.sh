#!/bin/bash
wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && sudo rpm --import repomd.xml.key
sudo dnf config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-rpm
sudo dnf install coolwsd CODE-brand -y
