#!/bin/bash
sudo systemctl disable --now php-fpm.service
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
sudo setfacl -R -m u:nginx:rwx /var/lib/php/opcache/
sudo setfacl -R -m u:nginx:rwx /var/lib/php/session/
sudo setfacl -R -m u:nginx:rwx /var/lib/php/wsdlcache/
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
sudo -u nginx php /usr/share/nextcloud/occ config:system:set memcache.distributed --value='\OC\Memcache\Redis'
sudo -u nginx php /usr/share/nextcloud/occ config:system:set memcache.local --value='\OC\Memcache\Redis'
sudo -u nginx php /usr/share/nextcloud/occ config:system:set memcache.locking --value='\OC\Memcache\Redis'
sudo -u nginx php /usr/share/nextcloud/occ config:system:set config:app:set redis host --value=localhost
sudo -u nginx php /usr/share/nextcloud/occ config:system:set config:app:set redis port --value=6379
sudo -u nginx php /usr/share/nextcloud/occ config:system:set config:app:set redis timeout --value=0.0
# Nextcloud Fixes
sudo sed -i 's,HP_VERSION_ID >= 80200,HP_VERSION_ID >= 80300,g' /usr/share/nextcloud/lib/versioncheck.php
sudo sed -i 's,'writable' => false,'writable' => true,g'/usr/share/nextcloud/config/config.php
sudo dnf install php-intl php-sodium php-opcache -y
sudo sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=32/" /etc/php.d/10-opcache.ini
sudo sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/" /etc/php.d/10-opcache.ini
# Nextcloud Apps Manage
sudo -u nginx php /usr/share/nextcloud/occ app:disable activity
sudo -u nginx php /usr/share/nextcloud/occ app:disable dashboard
sudo -u nginx php /usr/share/nextcloud/occ app:disable photos
sudo -u nginx php /usr/share/nextcloud/occ config:system:set simpleSignUpLink.shown --value=true
sudo -u nginx php /usr/share/nextcloud/occ config:system:set default_phone_region --value=RU
sudo -u nginx php /usr/share/nextcloud/occ config:system:set skeletondirectory
sudo -u nginx php /usr/share/nextcloud/occ config:system:set templatedirectory
