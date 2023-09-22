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

occ maintenance:install --database mysql --database-name $database_name --database-host localhost --database-user $database_user --database-pass $database_pass --admin-user $admin_user --admin-pass $admin_pass --data-dir $data_dir

occ config:system:set memcache.distributed --value='\OC\Memcache\Redis'
occ config:system:set memcache.local --value='\OC\Memcache\Redis'
occ config:system:set memcache.locking --value='\OC\Memcache\Redis'
occ app:disable activity
occ app:disable dashboard
occ app:disable photos
occ config:system:set simpleSignUpLink.shown --value=false
occ config:system:set default_phone_region --value=RU
occ config:system:set skeletondirectory
occ config:system:set templatedirectory
occ config:system:set force_language --value=ru
occ config:system:set force_locale --value=ru_RU
