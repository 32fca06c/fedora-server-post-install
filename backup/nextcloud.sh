#!/bin/bash
sudo -u nginx php /usr/share/nextcloud/occ maintenance:mode --on
sudo mysql -uroot -proot -e "FLUSH TABLES WITH READ LOCK;"
mysqldump --single-transaction -uroot -proot --databases nextcloud > nextcloud-sqlbkp_`date +"%Y%m%d"`.bak
sudo mysql -uroot -proot -e "UNLOCK TABLES;"
sudo -u nginx php /usr/share/nextcloud/occ maintenance:mode --off
