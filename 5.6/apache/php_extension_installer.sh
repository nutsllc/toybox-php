#!/bin/bash
set -e

php_exts=()
php_libs=()
pecl_exts=()

[ yes = "${INSTALL_CALENDAR}" ] && {
    php_exts=("calendar" "${php_exts[@]}")
}

[ yes = "${INSTALL_EXIF}" ] && {
    php_exts=("exif" "${php_exts[@]}")
}

[ yes = "${INSTALL_GD}" ] && {
    php_libs=("libfreetype6-dev" "libpng12-dev" "libjpeg62-turbo-dev" "libgd-tools" "${php_libs[@]}")
    php_exts=("gd" "${php_exts[@]}")
}

[ yes = "${INSTALL_GETTEXT}" ] && {
    php_exts=("gettext" "${php_exts[@]}")
}

[ yes = "${INSTALL_INTL}" ] && {
    php_libs=("libicu-dev" "${php_libs[@]}")
    php_exts=("intl" "${php_exts[@]}")
}

[ yes = "${INSTALL_MCRYPT}" ] && {
    php_libs=("libmcrypt-dev" "${php_libs[@]}")
    php_exts=("mcrypt" "${php_exts[@]}")
}

[ yes = "${INSTALL_MYSQLI}" ] && {
    php_exts=("mysqli" "${php_exts[@]}")
}

[ yes = "${INSTALL_OPCACHE}" ] && {
    php_exts=("opcache" "${php_exts[@]}")
    { 
		echo 'opcache.memory_consumption=128'
		echo 'opcache.interned_strings_buffer=8'
		echo 'opcache.max_accelerated_files=4000'
		echo 'opcache.revalidate_freq=60'
		echo 'opcache.fast_shutdown=1'
		echo 'opcache.enable_cli=1'
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
}

[ yes = "${INSTALL_PDO_MYSQL}" ] && {
    php_exts=("pdo_mysql" "${php_exts[@]}")
}

[ yes = "${INSTALL_PDO_PGSQL}" ] && {
    php_libs=("libpq-dev" "${php_libs[@]}")
    php_exts=("pdo_pgsql" "${php_exts[@]}")
}

[ yes = "${INSTALL_PGSQL}" ] && {
    php_exts=("pgsql" "${php_exts[@]}")
}

[ yes = "${INSTALL_SOCKETS}" ] && {
    php_exts=("sockets" "${php_exts[@]}")
}

[ yes = "${INSTALL_ZIP}" ] && {
    php_libs=("libzip-dev" "${php_libs[@]}")
    php_exts=("zip" "${php_exts[@]}")
}

# -----------------------------------------------

[ yes = "${INSTALL_APCU}" ] && {
    pecl_exts=("APCu-${APCU_VERSION}" "${pecl_exts[@]}")
}

[ yes = "${INSTALL_MEMCACHED}" ] && {
    php_libs=("libmemcached-dev" "libz-dev" "${php_libs[@]}")
    if [ ${PHP_VERSION:0:1} = "5" ]; then
        pecl_exts=("memcached-${MEMCACHED_VERSION}" "${pecl_exts[@]}")
    fi
}

[ yes = "${INSTALL_REDIS}" ] && {
    pecl_exts=("redis-${REDIS_VERSION}" "${pecl_exts[@]}")
}

[ yes = "${INSTALL_XDEBUG}" ] && {
    pecl_exts=("xdebug-${XDEBUG_VERSION}" "${pecl_exts[@]}")
    echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini
}

echo "PHP_VERSION: ${PHP_VERSION}"
printf "php_libs="; echo ${php_libs[@]}
printf "php_exts="; echo ${php_exts[@]}
printf "pecl_exts="; echo ${pecl_exts[@]}

#docker-php-source extract
# -----------------------------------------------
# Libraries(apt-get)
# -----------------------------------------------
if [ ${#php_libs[@]} -ne 0 ]; then
    echo "----------- apt-get install  ------------"
    apt-get update
    apt-get install -y ${php_libs[@]} --no-install-recommends
    rm -rf /var/lib/apt/lists/*
fi

# -----------------------------------------------
# PECL extensions
# -----------------------------------------------
echo $(pwd)
if [ "${#pecl_exts[@]}" -ne 0 ]; then
    echo "----------- pecl install  ------------"
    for module in ${pecl_exts[@]}; do
        pkg=$(echo ${module} | cut -d"-" -f1)
        yes /usr | pecl install ${module}
        docker-php-ext-enable $(echo ${pkg} | tr '[A-Z]' '[a-z]')
    done
fi

# -----------------------------------------------
# PHP Core Extensions
# -----------------------------------------------
[ yes ="${INSTALL_GD}" ] && {
    echo "----------- docker-php-ext-configure ------------"
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr
}

[ "${#php_exts[@]}" -ne 0 ] && {
    echo "----------- docker-php-ext-install ------------"
    docker-php-ext-install ${php_exts[@]}
}

# -----------------------------------------------
# memcached
# -----------------------------------------------
if [ ${PHP_VERSION:0:1} = "7" ] && [ yes = "${INSTALL_MEMCACHED}" ]; then
    echo "----------- memcached install  ------------"
    src="https://github.com/php-memcached-dev/php-memcached"
    install_dir="/usr/local/lib/php/extensions/no-debug-non-zts-20151012/memcached.so"

    git clone --branch php7 ${src} /usr/src/php/ext/memcached/
    cd /usr/src/php/ext/memcached
    phpize && ./configure && make -j"$(nproc)" && make install
    echo "extension=${install_dir}" > /usr/local/etc/php/conf.d/memcached.ini
fi

# -----------------------------------------------
# postprocessing
# -----------------------------------------------

rm /php_extension_installer.sh
