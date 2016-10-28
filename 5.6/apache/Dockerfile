FROM php:5.6.23-apache
MAINTAINER NutsProject, LLC <dev@nutsllc.jp>

ENV APCU_VERSION=4.0.11 \
    MEMCACHED_VERSION=2.2.0 \
    REDIS_VERSION=2.2.8 \
    XDEBUG_VERSION=2.4.1 \
    INSTALL_CALENDAR=yes \
    INSTALL_EXIF=yes \
    INSTALL_GD=yes \
    INSTALL_GETTEXT=yes \
    INSTALL_INTL=yes \
    INSTALL_MCRYPT=yes \
    INSTALL_MYSQLI=yes \
    INSTALL_OPCACHE=yes \
    INSTALL_PDO_MYSQL=yes \
    INSTALL_PDO_PGSQL=yes \
    INSTALL_PGSQL=yes \
    INSTALL_SOCKETS=yes \
    INSTALL_ZIP=yes \
    INSTALL_APCU=yes \
    INSTALL_MEMCACHED=yes \
    INSTALL_REDIS=yes \
    INSTALL_XDEBUG=yes

COPY php_extension_installer.sh /php_extension_installer.sh

RUN a2enmod rewrite expires \
    && apt-get update && apt-get install -y yes \
    && tar czf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
    && tar czf /usr/src/apache2-conf.tar.gz -C /etc/apache2 ./ \
    && tar czf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./ \
    && /php_extension_installer.sh \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

VOLUME /var/www/html

COPY docker-entrypoint.sh /entrypoint-ex.sh

ENTRYPOINT ["/entrypoint-ex.sh"]
CMD ["apache2-foreground"]
