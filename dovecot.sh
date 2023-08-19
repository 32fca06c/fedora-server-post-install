#!/bin/bash
sudo dnf install dovecot -y
# sudo nano /etc/dovecot/config
# sudo nano 10-ssh
sudo useradd -r -m vmail
