#!/bin/bash
sudo dnf install mariadb-server -y
sudo systemctl enable --now mariadb
sudo mysql_secure_installation
