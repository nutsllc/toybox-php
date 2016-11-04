FROM alpine:3.4
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
ARG ARG_SOCKETS=yes
ARG ARG_ZIP=yes
ARG ARG_APCU=yes
ARG ARG_MEMCACHED=yes
ARG ARG_REDIS=yes
ARG ARG_XDEBUG=yes

ENV PHP_VERSION=7.0.8 \
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
    INSTALL_SOCKETS=${ARG_SOCKETS} \
    INSTALL_ZIP=${ARG_ZIP} \
    INSTALL_APCU=${ARG_APCU} \
    INSTALL_MEMCACHED=${ARG_MEMCACHED} \
    INSTALL_REDIS=${ARG_REDIS} \
    INSTALL_XDEBUG=${ARG_XDEBUG} \
    PATH=${PATH}:${HOME}/.composer/vendor/bin

COPY php_extension_installer_alpine.sh /php_extension_installer.sh

RUN [ ${PHP_VERSION:0:1} = 7 ] && { \
        echo "http://dl-3.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories; \
        echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories; \
        apk add --update --no-cache \
            libressl; \
    }; \
    apk add --update --no-cache \
        bash \
        tar \
        curl \
        php${PHP_VERSION:0:1}-fpm \
        php${PHP_VERSION:0:1}-ctype \
        php${PHP_VERSION:0:1}-curl \
        php${PHP_VERSION:0:1}-json \
        php${PHP_VERSION:0:1}-openssl \
        php${PHP_VERSION:0:1}-pdo_sqlite \
        php${PHP_VERSION:0:1}-phar \
        php${PHP_VERSION:0:1}-posix \
        php${PHP_VERSION:0:1}-sqlite3 \
        php${PHP_VERSION:0:1}-xml \
        php${PHP_VERSION:0:1}-xmlreader \
        php${PHP_VERSION:0:1}-zlib \
    && [ ${PHP_VERSION:0:1} = 7 ] && { \
        apk add --no-cache \
            php7-iconv \
            php7-mbstring \
            php7-mysqlnd \
            php7-readline; \
        mv /usr/bin/php7 /usr/bin/php; \
    }; \
    /php_extension_installer.sh \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=${HOME} --filename=composer \
    && mv ${HOME}/composer /usr/bin

COPY php-fpm.d/ /usr/local/etc/php-fpm.d/
EXPOSE 9000

COPY docker-entrypoint.sh /entrypoint-ex.sh
ENTRYPOINT ["/entrypoint-ex.sh"]

CMD ["php-fpm"]
