#!/bin/sh
set -e

export PATH="/usr/share/elasticsearch/bin:${PATH}"
export ES_TMPDIR="/usr/share/elasticsearch/tmp"

nohup su -p elasticsearch -c "export JAVA_HOME=/usr && elasticsearch" &

mysqld --bind-address=0.0.0.0 -u mysql -P 3306 --skip_networking=0 2> /dev/null >&2 &

while ! mysqladmin -h 127.0.0.1 ping --silent
do
    sleep 1
done

if [ ! -e "/var/www/html/magento2/bin/magento" ]
then
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www/html/magento2
  cd magento2/
 php -d memory_limit=-1 bin/magento setup:install \
 --base-url=http://"${MAGENTO_URL}":8082/ \
 --db-host=127.0.0.1 \
 --db-name=app_db \
 --db-user=app_user \
 --db-password=vic4593 \
 --admin-firstname=adminvictor \
 --admin-lastname=admingil \
 --admin-email=victor.gil@amasty.com \
 --admin-user=admin \
 --admin-password=Doc12345 \
 --backend-frontname=admin \
 --language=en_US \
 --currency=USD \
 --timezone=America/Chicago \
 --use-rewrites=1 \
 --search-engine=elasticsearch7 \
 --elasticsearch-host=127.0.0.1 \
 --elasticsearch-port=9200 \
 --elasticsearch-index-prefix=magento_db_user

 bin/magento module:disable Magento_TwoFactorAuth  --clear-static-content
 bin/magento indexer:reindex
 bin/magento deploy:mode:set production
fi

php-fpm -D -R
nginx -g 'daemon off;'


 exec "$@"
