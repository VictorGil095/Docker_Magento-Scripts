ARG PHP_BASEIMAGE_VERSION=7.4
FROM php:${PHP_BASEIMAGE_VERSION}-fpm-alpine

LABEL maintainer="Victor Gil <victor.gil@amasty.com>"
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories

# Setup some env
ENV \
	COMPOSER_HOME="/usr/local/composer" \
	MAGENTO_URL='magento.docker'

ARG PHP_EXTENSIONS="bcmath dom exif gd iconv intl mysqli opcache pdo_mysql pdo_sqlite soap sockets xsl zip"

# Install dependencies
RUN apk add --update \
		acl \
		apk-cron \
		augeas-dev \
		autoconf \
		bash \
		curl \
		ca-certificates \
		dialog \
		freetype-dev \
		gomplate \
		git \
		gcc \
		icu-dev \
		libcurl \
		libffi-dev \
		libgcrypt-dev \
		libjpeg-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libpq \
		libressl-dev \
		libxslt-dev \
		libzip-dev \
		linux-headers \
		make \
		musl-dev \
		mysql-client \
		nginx \
		openssh-client \
		ssmtp \
		sqlite-dev \
		supervisor \
		su-exec \
		wget \
		gnu-libiconv \
        'mariadb<10.5' 'mariadb-client<10.5' \
		&& \
	docker-php-ext-configure gd \
		--with-gd \
		--with-freetype-dir \
		--with-png-dir \
		--with-jpeg-dir \
		--enable-option-checking \
		--with-freetype \
		--with-jpeg && \
	docker-php-ext-install $PHP_EXTENSIONS && \
	docker-php-source delete && \
	apk del gcc musl-dev linux-headers libffi-dev augeas-dev make autoconf

RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN echo "memory_limit = -1" > /usr/local/etc/php/conf.d/memory-limit-php.ini

COPY conf/php/php-fpm.upstream.conf /usr/local/etc/php-fpm.d/www.conf
COPY install.sh entrypoint.sh elastic.sh /tools/

COPY auth.json "$COMPOSER_HOME/auth.json"

RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld

RUN chmod -R +x /tools/*.sh

RUN /tools/elastic.sh
COPY conf/elastic/ /usr/share/elasticsearch/config/

RUN /tools/install.sh
RUN rm -rf /var/cache/apk/*
COPY conf/nginx/magento.conf /etc/nginx/http.d/magento.conf
ENTRYPOINT ["/tools/entrypoint.sh"]
EXPOSE 8082