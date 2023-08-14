#!/bin/bash
# Variables
DB_USERNAME=user
DB_PASSWORD=password
# Nextcloud
sudo dnf install nextcloud-nginx -y
sudo sed -i -e 's,user = apache,user = nginx,g' -e 's,group = apache,group = nginx,g' /etc/php-fpm.d/nextcloud.conf
sudo touch /usr/share/nextcloud/config/CAN_INSTALL
sudo setfacl -R -m u:nginx:rwx /usr/share/nextcloud/*
sudo chown -R nginx:nginx /usr/share/nextcloud/
sudo chown nginx:nginx /usr/share/nextcloud/config/config.php
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/config(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/apps(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/3rdparty/aws/aws-sdk-php/src/data/logs(/.*)?'
sudo sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 100M/" /etc/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php.ini
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
sudo sed -i 's,HP_VERSION_ID >= 80200,HP_VERSION_ID >= 80300,g' /usr/share/nextcloud/lib/versioncheck.php
sudo sed -i 's,'writable' => false,'writable' => true,g'/usr/share/nextcloud/config/config.php
# Nextcloud Apps Manage
sudo -u nginx php occ app:disable
