#!/bin/bash
# NGINX
sudo dnf install nginx -y
# PHP-FPM
sudo dnf install php-fpm -y
sudo sed -i -e 's,user = apache,user = nginx,g' -e 's,group = apache,group = nginx,g' /etc/php-fpm.d/www.conf
# Ending
sudo systemctl enable --now php-fpm.service
sudo systemctl enable --now nginx.service
