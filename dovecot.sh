#!/bin/bash
sudo dnf install dovecot -y
sudo nano /etc/dovecot/dovecot.conf 
sudo nano /etc/dovecot/conf.d/10-ssl.conf 
sudo useradd -r -m vmail
