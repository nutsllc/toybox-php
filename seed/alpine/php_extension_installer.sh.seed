#!/bin/bash
set -e

php_exts=()
php_ver=${PHP_VERSION:0:1}

[ yes = "${INSTALL_CALENDAR}" ] && {
    php_exts=("php${php_ver}-calendar" "${php_exts[@]}")
}

[ yes = "${INSTALL_EXIF}" ] && {
    php_exts=("php${php_ver}-exif" "${php_exts[@]}")
}

[ yes = "${INSTALL_GD}" ] && {
    php_exts=("php${php_ver}-gd" "${php_exts[@]}")
}

[ yes = "${INSTALL_GETTEXT}" ] && {
    php_exts=("php${php_ver}-gettext" "${php_exts[@]}")
}

[ yes = "${INSTALL_INTL}" ] && {
    php_exts=("php${php_ver}-intl" "${php_exts[@]}")
}

[ yes = "${INSTALL_MCRYPT}" ] && {
    php_exts=("php${php_ver}-mcrypt" "${php_exts[@]}")
}

[ yes = "${INSTALL_MYSQLI}" ] && {
    php_exts=("php${php_ver}-mysqli" "${php_exts[@]}")
}

[ yes = "${INSTALL_OPCACHE}" ] && {
    php_exts=("php${php_ver}-opcache" "${php_exts[@]}")
    { 
		echo 'opcache.memory_consumption=128'
		echo 'opcache.interned_strings_buffer=8'
		echo 'opcache.max_accelerated_files=4000'
		echo 'opcache.revalidate_freq=60'
		echo 'opcache.fast_shutdown=1'
		echo 'opcache.enable_cli=1'
	} > /etc/php${php_ver}/conf.d/opcache-recommended.ini
}

[ yes = "${INSTALL_PDO_MYSQL}" ] && {
    php_exts=("php${php_ver}-pdo_mysql" "${php_exts[@]}")
}

[ yes = "${INSTALL_PDO_PGSQL}" ] && {
    php_exts=("php${php_ver}-pdo_pgsql" "${php_exts[@]}")
}

[ yes = "${INSTALL_PGSQL}" ] && {
    php_exts=("php${php_ver}-pgsql" "${php_exts[@]}")
}

[ yes = "${INSTALL_SOCKETS}" ] && {
    php_exts=("php${php_ver}-sockets" "${php_exts[@]}")
}

[ yes = "${INSTALL_ZIP}" ] && {
    php_exts=("php${php_ver}-zip" "${php_exts[@]}")
}

# -----------------------------------------------

[ yes = "${INSTALL_APCU}" ] && {
    php_exts=("php${php_ver}-apcu" "${php_exts[@]}")
}

[ yes = "${INSTALL_MEMCACHED}" ] && {
    php_exts=("php${php_ver}-memcached" "${php_exts[@]}")
}

[ yes = "${INSTALL_REDIS}" ] && {
    php_exts=("php${php_ver}-redis" "${php_exts[@]}")
}

[ yes = "${INSTALL_XDEBUG}" ] && {
    php_exts=("php${php_ver}-xdebug" "${php_exts[@]}")
}

echo "PHP_VERSION: ${PHP_VERSION}"
printf "php_exts="; echo ${php_exts[@]}

[ "${#php_exts[@]}" -ne 0 ] && {
    echo "----------- docker-php-ext-install ------------"
    echo "http://dl-3.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
    echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    apk add --update --no-cache ${php_exts[@]}
}
