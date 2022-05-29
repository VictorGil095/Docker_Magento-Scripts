#!/bin/sh
set -e

mysqld --bind-address=0.0.0.0 -u mysql -P 3306 --skip_networking=0 2> /dev/null >&2 &

while ! mysqladmin -h 127.0.0.1 ping --silent
do
    sleep 1
done

mysql -e "CREATE DATABASE app_db;"
mysql -e "CREATE USER 'app_user'@'127.0.0.1' IDENTIFIED BY 'vic4593';"
mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'app_user'@'127.0.0.1';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown