FROM php:7.0.8-apache
MAINTAINER NutsProject, LLC <dev@nutsllc.jp>

ENV APCU_VERSION 5.1.6
#ENV MEMCACHED_VERSION 2.2.0
ENV REDIS_VERSION 3.0.0
ENV XDEBUG_VERSION 2.4.1

RUN a2enmod rewrite expires

#GD "libpng12-dev" "libjpeg-dev" "libgd-tools"
#INTL "libicu-dev"
#MCRYPT "libmcrypt-dev"
#PDO_PGSQL "libpq-dev"
#ZIP "libzip-dev"
#MEMCACHED "libmemcached-dev" "libz-dev"

RUN apt-get update && apt-get install -y \
    yes \
    git \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

#RUN apt-get update && apt-get install -y \
#    libpng12-dev libjpeg-dev libgd-tools \
#    libicu-dev \
#    libmcrypt-dev \
#    libpq-dev \
#    libzip-dev \
#    libmemcached-dev libz-dev

RUN tar czf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
    && tar czf /usr/src/apache2-conf.tar.gz -C /etc/apache2 ./ \
    && tar czf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./

VOLUME /var/www/html

COPY docker-entrypoint.sh /entrypoint-ex.sh
ENTRYPOINT ["/entrypoint-ex.sh"]

CMD ["apache2-foreground"]
