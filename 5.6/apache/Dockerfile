FROM php:5.6.23-apache
MAINTAINER NutsProject, LLC <dev@nutsllc.jp>

ENV APCU_VERSION 4.0.11
ENV MEMCACHED_VERSION 2.2.0
ENV REDIS_VERSION 2.2.8
ENV XDEBUG_VERSION 2.4.1

RUN a2enmod rewrite expires

RUN apt-get update && apt-get install -y \
    yes \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

#RUN apt-get update && apt-get install -y git unzip wget \
#    libmcrypt-dev mcrypt libpng12-dev libjpeg-dev libgd-tools && rm -rf /var/lib/apt/lists/* \
#	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#    && docker-php-ext-install exif gd json mbstring mcrypt mysqli opcache zip
#
## PHP extensions
#RUN apt-get update && apt-get install -y \
#    bzip2 \
#    libcurl4-openssl-dev \
#    libfreetype6-dev \
#    libicu-dev \
#    libjpeg-dev \
#    libmcrypt-dev \
#    libmemcached-dev \
#    libpng12-dev \
#    libpq-dev \
#    libxml2-dev \
#    && rm -rf /var/lib/apt/lists/* \
#	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#    && docker-php-ext-install calendar exif gd intl gettext json mbstring mcrypt mysqli opcache pdo_mysql pdo_pgsql pgsql sockets zip
#
## PECL extensions
#RUN set -ex \
#    && pecl install APCu-4.0.10 \
#    && pecl install memcached-2.2.0 \
#    && pecl install redis-2.2.8 \
#    && pecl install xdebug \
#    && docker-php-ext-enable apcu redis memcached xdebug \ 
#    && rm -rf /tmp/pear \
#    #&& echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini

## set php.ini
#RUN { \
#        echo 'max_execution_time = 200'; \
#        echo 'post_max_size = 100M'; \
#        echo 'upload_max_size = 100M'; \
#        echo 'upload_max_filesize = 20M'; \
#        echo 'memory_limit = 256M'; \
#        echo ''; \
#        echo '[Date]'; \
#        echo 'date.timezone = Asia/Tokyo'; \
#	} > /usr/local/etc/php/php.ini
#
## set conf.d/opcache.ini
## see https://secure.php.net/manual/en/opcache.installation.php
#RUN { \
#		echo 'opcache.memory_consumption=128'; \
#		echo 'opcache.interned_strings_buffer=8'; \
#		echo 'opcache.max_accelerated_files=4000'; \
#		echo 'opcache.revalidate_freq=60'; \
#		echo 'opcache.fast_shutdown=1'; \
#		echo 'opcache.enable_cli=1'; \
#	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

#RUN echo '<?php phpinfo(); ?>' > /var/www/html/index.php \
#    && tar cvzf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
#    && tar cvzf /usr/src/apache2-conf.tar.gz -C /etc/apache2 ./ \
#    && tar cvzf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./

#RUN apt-get update && apt-get install -y git
RUN tar czf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
    && tar czf /usr/src/apache2-conf.tar.gz -C /etc/apache2 ./ \
    && tar czf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./

VOLUME /var/www/html

COPY docker-entrypoint.sh /entrypoint-ex.sh
ENTRYPOINT ["/entrypoint-ex.sh"]

CMD ["apache2-foreground"]
