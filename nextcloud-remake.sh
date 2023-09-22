#!/bin/bash

sudo systemctl stop php-fpm.service

admin_user=''
admin_pass=''
database_user='nextcloud'
database_pass=''
database_name='nextcloud'
data_dir='/home/nextcloud'

occ() {
    sudo -u nginx php /usr/share/nextcloud/occ "$@"
}

nextcloud() {
    sudo dnf install nextcloud-nginx -y
    sudo sed -i -e 's,user = apache,user = nginx,g' -e 's,group = apache,group = nginx,g' /etc/php-fpm.d/nextcloud.conf
    sudo touch /usr/share/nextcloud/config/CAN_INSTALL
    sudo setfacl -R -m u:nginx:rwx /usr/share/nextcloud/*
    sudo chown -R nginx:nginx /usr/share/nextcloud/
    sudo chown nginx:nginx /usr/share/nextcloud/config/config.php
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/config(/.*)?'
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/apps(/.*)?'
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nextcloud/3rdparty/aws/aws-sdk-php/src/data/logs(/.*)?'
    sudo sed -i -e "s/memory_limit = 128M/memory_limit = 512M/" -e "s/post_max_size = 8M/post_max_size = 100M/" -e "s/upload_max_filesize = 2M/upload_max_filesize = 100M/" /etc/php.ini
    sudo setfacl -R -m u:nginx:rwx /var/lib/php/opcache/
    sudo setfacl -R -m u:nginx:rwx /var/lib/php/session/
    sudo setfacl -R -m u:nginx:rwx /var/lib/php/wsdlcache/
    sudo mkdir $data_dir
    sudo chown -R nginx:nginx $data_dir
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/nextcloud(/.*)?'
    sudo restorecon -v $data_dir
}

db() {
    sudo dnf install mariadb-server -y
    sudo systemctl enable --now mariadb
    sudo mysql -uroot -proot -e "CREATE DATABASE $database_name;"
    sudo mysql -uroot -proot -e "CREATE USER '$database_user'@'localhost' IDENTIFIED BY '$database_pass';"
    sudo mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON $database_name.* TO '$database_user'@'localhost' IDENTIFIED BY '$database_pass';"
    sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;"
}

redis() {
    sudo dnf install redis -y
    sudo systemctl enable --now redis.service
    occ config:system:set memcache.distributed --value='\OC\Memcache\Redis'
    occ config:system:set memcache.local --value='\OC\Memcache\Redis'
    occ config:system:set memcache.locking --value='\OC\Memcache\Redis'
}
