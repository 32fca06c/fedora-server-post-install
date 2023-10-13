#!/bin/bash
# Packages
sudo dnf install nginx php-fpm -y

sudo tee -a /etc/php-fpm.d/nextcloud.conf <<EOF
[nextcloud]
user = nginx
group = nginx
listen = /run/php-fpm/nextcloud.sock
listen.acl_users = apache,nginx
listen.allowed_clients = 127.0.0.1
pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35
slowlog = /var/log/php-fpm/nextcloud-slow.log
php_admin_value[error_log] = /var/log/php-fpm/nextcloud-error.log
php_admin_flag[log_errors] = on
php_value[session.save_handler] = files
php_value[session.save_path]    = /var/lib/php/session
php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache
php_value[memory_limit] = 512M
php_value[upload_max_filesize] = 10G
php_value[post_max_size] = 10G
php_value[output_buffering] = false
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF
