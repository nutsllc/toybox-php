FROM php:7.0.8-fpm
MAINTAINER NutsProject, LLC <dev@nutsllc.jp>

ARG ARG_CALENDAR=yes
ARG ARG_EXIF=yes
ARG ARG_GD=yes
ARG ARG_GETTEXT=yes
ARG ARG_INTL=yes
ARG ARG_MCRYPT=yes
ARG ARG_MYSQLI=yes
ARG ARG_OPCACHE=yes
ARG ARG_PDO_MYSQL=yes
ARG ARG_PDO_PGSQL=yes
ARG ARG_PGSQL=yes
ARG ARG_BCMATH=yes
ARG ARG_SOCKETS=yes
ARG ARG_ZIP=yes
ARG ARG_APCU=yes
ARG ARG_MEMCACHED=yes
ARG ARG_REDIS=yes
ARG ARG_XDEBUG=yes

ENV PHP_VERSION=7.0.8 \
    APCU_VERSION=5.1.6 \
    MEMCACHED_VERSION=2.2.0 \
    REDIS_VERSION=3.0.0 \
    XDEBUG_VERSION=2.4.1 \
    INSTALL_CALENDAR=${ARG_CALENDAR} \
    INSTALL_EXIF=${ARG_EXIF} \
    INSTALL_GD=${ARG_GD} \
    INSTALL_GETTEXT=${ARG_GETTEXT} \
    INSTALL_INTL=${ARG_INTL} \
    INSTALL_MCRYPT=${ARG_MCRYPT} \
    INSTALL_MYSQLI=${ARG_MYSQLI} \
    INSTALL_OPCACHE=${ARG_OPCACHE} \
    INSTALL_PDO_MYSQL=${ARG_PDO_MYSQL} \
    INSTALL_PDO_PGSQL=${ARG_PDO_PGSQL} \
    INSTALL_PGSQL=${ARG_PGSQL} \
    INSTALL_BCMATH=${ARG_BCMATH} \
    INSTALL_SOCKETS=${ARG_SOCKETS} \
    INSTALL_ZIP=${ARG_ZIP} \
    INSTALL_APCU=${ARG_APCU} \
    INSTALL_MEMCACHED=${ARG_MEMCACHED} \
    INSTALL_REDIS=${ARG_REDIS} \
    INSTALL_XDEBUG=${ARG_XDEBUG} \
    PATH=${PATH}:${HOME}/.composer/vendor/bin

COPY php_extension_installer.sh /php_extension_installer.sh

RUN apt-get update && apt-get install -y yes git \
    && tar czf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
    && tar czf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./ \
    && /php_extension_installer.sh \
    && apt-get clean \
    && rm -rf /var/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=${HOME} --filename=composer \
    && mv ${HOME}/composer /usr/bin

WORKDIR /
EXPOSE 9000

COPY docker-entrypoint.sh /entrypoint-ex.sh
ENTRYPOINT ["/entrypoint-ex.sh"]

CMD ["php-fpm"]
