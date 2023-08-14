#!/bin/bash
sudo -u www-data php occ maintenance:mode --on
sudo mysql -uroot -proot -e "FLUSH TABLES WITH READ LOCK;"
sudo mysql -uroot -proot -e "UNLOCK TABLES;"
sudo -u www-data php occ maintenance:mode --off
