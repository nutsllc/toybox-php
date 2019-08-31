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
    php_libs=("libfreetype6-dev" "libjpeg62-turbo-dev" "libgd-tools" "${php_libs[@]}")
    if [ ${PHP_VERSION} = "5.6.23" -o ${PHP_VERSION} = "7.0.8" ]; then
        php_libs=("libpng12-dev" "${php_libs[@]}")
    elif [ ${PHP_VERSION} = "7.1.25" -o ${PHP_VERSION} = "7.2.13" -o ${PHP_VERSION} = "7.3" ]; then
        php_libs=("libpng-dev" "${php_libs[@]}")
    fi

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
    if [ ${PHP_VERSION} = "5.6.23" -o ${PHP_VERSION} = "7.0.8" -o ${PHP_VERSION} = "7.1.25" ]; then
        php_libs=("libmcrypt-dev" "${php_libs[@]}")
        php_exts=("mcrypt" "${php_exts[@]}")
    elif [ ${PHP_VERSION} = "7.2.13" ]; then
        apt-get install -y libmcrypt-dev
        pecl install mcrypt-1.0.1
        docker-php-ext-enable mcrypt
    fi
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

[ yes = "${INSTALL_BCMATH}" ] && {
    php_exts=("bcmath" "${php_exts[@]}")
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
    if [ ${PHP_VERSION} = "7.0.8" -o ${PHP_VERSION} = "7.1.25" -o ${PHP_VERSION} = "7.2.13" -o ${PHP_VERSION} = "7.3" ]; then
        pecl install igbinary
        docker-php-ext-enable igbinary
    fi
    pecl_exts=("redis-${REDIS_VERSION}" "${pecl_exts[@]}")
}

[ yes = "${INSTALL_XDEBUG}" ] && {
    pecl_exts=("xdebug-${XDEBUG_VERSION}" "${pecl_exts[@]}")
    out=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
}

echo ""
echo "===================================================="
echo ""
echo "PHP_VERSION: ${PHP_VERSION}"
printf "php_libs="; echo ${php_libs[@]}
printf "php_exts="; echo ${php_exts[@]}
printf "pecl_exts="; echo ${pecl_exts[@]}
echo ""
echo "===================================================="
echo ""

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
        ( \
            pkg=$(echo ${module} | cut -d"-" -f1) \
            && yes /usr | pecl install ${module} \
            && docker-php-ext-enable $(echo ${pkg} | tr '[A-Z]' '[a-z]') \
        )
    done
fi

# -----------------------------------------------
# PHP Core Extensions
# -----------------------------------------------
[ yes = "${INSTALL_GD}" ] && {
    echo "----------- docker-php-ext-configure ------------"
    docker-php-ext-configure gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr
}

[ "${#php_exts[@]}" -ne 0 ] && {
    echo "----------- docker-php-ext-install ------------"
    docker-php-ext-install ${php_exts[@]}
    docker-php-ext-enable ${php_exts[@]}
}

# -----------------------------------------------
# memcached
# -----------------------------------------------
    if [ ${PHP_VERSION:0:1} = "7" ] && [ yes = "${INSTALL_MEMCACHED}" ]; then
        echo "----------- memcached install  ------------"
        curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz"
        mkdir -p memcached
        tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1
        (
            cd memcached
            phpize
            ./configure --enable-memcached-igbinary --enable-memcached-json
            make -j"$(nproc)"
            make install
        )
        rm -rf memcached
        rm /tmp/memcached.tar.gz
        docker-php-ext-enable memcached
    fi
