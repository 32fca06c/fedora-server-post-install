#!/bin/bash
sudo dnf install nextcloud-nginx -y
sudo touch /usr/share/nextcloud/config/CAN_INSTALL

sudo mkdir /home/nextcloud
sudo chown -R nginx:nginx /home/nextcloud
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/nextcloud(/.*)?'
sudo restorecon -v '/home/nextcloud'
