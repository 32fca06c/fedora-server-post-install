#!/bin/bash
sudo dnf install mariadb-server -y
sudo systemctl enable --now mariadb
sudo mysql -uroot -proot -e "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';"
sudo mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -uroot -proot -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
sudo mysql -uroot -proot -e "DROP DATABASE IF EXISTS test;"
sudo mysql -uroot -proot -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;"
