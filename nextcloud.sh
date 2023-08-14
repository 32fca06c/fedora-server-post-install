#!/bin/bash
# Variables
DB_USERNAME=user
DB_PASSWORD=password
# Nextcloud
sudo dnf install nextcloud-nginx -y
sudo touch /usr/share/nextcloud/config/CAN_INSTALL
sudo setfacl -R -m u:nginx:rwx /usr/share/nextcloud/*
sudo chown -R nginx:nginx /usr/share/nextcloud/
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/config(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/apps(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/3rdparty/aws/aws-sdk-php/src/data/logs(/.*)?'
# Nextcloud Storage
sudo mkdir /home/nextcloud
sudo chown -R nginx:nginx /home/nextcloud
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/nextcloud(/.*)?'
sudo restorecon -v '/home/nextcloud'
# Nextcloud Database
wget -O - https://raw.githubusercontent.com/32fca06c/fedora-server-post-install/main/mariadb.sh | sudo bash
sudo mysql -uroot -proot -e "CREATE DATABASE nextcloud;"
sudo mysql -uroot -proot -e "CREATE USER '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON nextcloud.* TO '$DB_USERNAME'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"
sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;"
# Nextcloud Cache
sudo dnf install redis -y
sudo systemctl enable --now redis.service
# Nextcloud Fixes
# Nextcloud Apps Manage
sudo -u nginx php occ app:disable
