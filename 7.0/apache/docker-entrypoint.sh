#!/bin/bash
set -e

user="www-data"
group="www-data"

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/group | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
    groupmod -g ${TOYBOX_GID} ${group}
    echo "GID of ${group} has been changed."
fi

if [ -n "${TOYBOX_UID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_UID} > /dev/null 2>&1; then
    usermod -u ${TOYBOX_UID} ${user}
    echo "UID of ${user} has been changed."
fi

docroot="/usr/local/apache2/htdocs"
mkdir -p ${docroot}
tar xzf /usr/src/apache2-default-doc.tar.gz -C ${docroot}
chown -R ${user}:${group} ${docroot}

apache2_confdir="/etc/apache2"
mkdir -p ${apache2_confdir}
tar xzf /usr/src/apache2-conf.tar.gz -C ${apache2_confdir}
chown -R ${user}:${group} ${apache2_confdir}

php_confdir="/usr/local/etc/php"
mkdir -p ${php_confdir}
tar xzf /usr/src/php-conf.tar.gz -C ${php_confdir}
chown -R ${user}:${group} ${php_confdir}

#RUN apt-get update && apt-get install -y git unzip wget \
#    libmcrypt-dev mcrypt libpng12-dev libjpeg-dev libgd-tools && rm -rf /var/lib/apt/lists/* \
#	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
#    && docker-php-ext-install exif gd json mbstring mcrypt mysqli opcache zip

# ---------------------------------------------------------------------------

php_exts=()
php_libs=()
pecl_exts=()

[ enable = "${CALENDAR}" ] && {
    php_exts=("calendar" "${php_exts[@]}")
}

[ enable = "${EXIF}" ] && {
    php_exts=("exif" "${php_exts[@]}")
}

[ enable = "${GD}" ] && {
    php_libs=("libfreetype6-dev" "libpng12-dev" "libjpeg62-turbo-dev" "libgd-tools" "${php_libs[@]}")
    php_exts=("gd" "${php_exts[@]}")
}

[ enable = "${GETTEXT}" ] && {
    php_exts=("gettext" "${php_exts[@]}")
}

[ enable = "${INTL}" ] && {
    php_libs=("libicu-dev" "${php_libs[@]}")
    php_exts=("intl" "${php_exts[@]}")
}

[ enable = "${MCRYPT}" ] && {
    php_libs=("libmcrypt-dev" "${php_libs[@]}")
    php_exts=("mcrypt" "${php_exts[@]}")
}

[ enable = "${MYSQLI}" ] && {
    php_exts=("mysqli" "${php_exts[@]}")
}

[ enable = "${OPCACHE}" ] && {
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

[ enable = "${PDO_MYSQL}" ] && {
    php_exts=("pdo_mysql" "${php_exts[@]}")
}

[ enable = "${PDO_PGSQL}" ] && {
    php_libs=("libpq-dev" "${php_libs[@]}")
    php_exts=("pdo_pgsql" "${php_exts[@]}")
}

[ enable = "${PGSQL}" ] && {
    php_exts=("pgsql" "${php_exts[@]}")
}

[ enable = "${SOCKETS}" ] && {
    php_exts=("sockets" "${php_exts[@]}")
}

[ enable = "${ZIP}" ] && {
    php_libs=("libzip-dev" "${php_libs[@]}")
    php_exts=("zip" "${php_exts[@]}")
}

# -----------------------------------------------

[ enable = "${APCU}" ] && {
    pecl_exts=("APCu-${APCU_VERSION}" "${pecl_exts[@]}")
}

[ enable = "${MEMCACHED}" ] && {
    php_libs=("libmemcached-dev" "libz-dev" "${php_libs[@]}")
    if [ ${PHP_VERSION:0:1} = "5" ]; then
        pecl_exts=("memcached-${MEMCACHED_VERSION}" "${pecl_exts[@]}")
    fi
}

[ enable = "${REDIS}" ] && {
    pecl_exts=("redis-${REDIS_VERSION}" "${pecl_exts[@]}")
}

[ enable = "${XDEBUG}" ] && {
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
[ "${GD}" = enable ] && {
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
if [ ${PHP_VERSION:0:1} = "7" ] && [ enable = "${MEMCACHED}" ]; then
    echo "----------- memcached install  ------------"
    src="https://github.com/php-memcached-dev/php-memcached"
    install_dir="/usr/local/lib/php/extensions/no-debug-non-zts-20151012/memcached.so"

    git clone --branch php7 ${src} /usr/src/php/ext/memcached/
    cd /usr/src/php/ext/memcached
    phpize && ./configure && make -j"$(nproc)" && make install
    echo "extension=${install_dir}" > /usr/local/etc/php/conf.d/memcached.ini
fi

# set php.ini
echo "----------- setup php.ini ------------"
: ${MEMORY_LIMIT:=32M}
: ${POST_MAX_SIZE:=16M}
: ${UPLOAD_MAX_FILESIZE:=8M}

: ${ERROR_REPORTING:=E_ALL|E_STRICT}
: ${DISPLAY_ERRORS:=Off}
: ${LOG_ERRORS:=On}
: ${ERROR_LOG:=/var/log/php_error.log}

: ${DEFAULT_CHARSET:="UTF-8"}
: ${MBSTRING_LANGUAGE:=Japanese}
: ${MBSTRING_INTERNAL_ENCODING:=UTF-8}
: ${MBSTRING_ENCODING_TRANSLATION:=Off}
: ${MBSTRING_HTTP_INPUT:=pass}
: ${MBSTRING_HTTP_OUTPUT:=pass}
: ${MBSTRING_DETECT_ORDER:=auto}

: ${EXPOSE_PHP:=Off}
: ${SESSION_HASH_FUNCTION:=0}
: ${SESSION_SAVE_HANDLER:=files}
: ${SESSION_SAVE_PATH:='/var/lib/php/session'}

: ${SHORT_OPEN_TAG:=On}
: ${MAX_EXECUTION_TIME:=30}

: ${DATE_TIMEZONE:=UTC}

if [ ! -f /usr/local/etc/php/php.ini ]; then
    {
        echo "memory_limit = ${MEMORY_LIMIT}"
        echo "post_max_size = ${POST_MAX_SIZE}"
        echo "upload_max_filesize = ${UPLOAD_MAX_FILESIZE}"
        echo ""
        echo "error_reporting = ${ERROR_REPORTING}"
        echo "display_errors = ${DISPLAY_ERRORS}"
        echo "log_errors = ${LOG_ERRORS}"
        echo "error_log = ${ERROR_LOG}"
        echo ""
        echo "default_charset = ${DEFAULT_CHARSET}"
        echo "mbstring.language = ${MBSTRING_LANGUAGE}"
        echo "mbstring.internal_encoding = ${MBSTRING_INTERNAL_ENCODING}"
        echo "mbstring.encoding_translation = ${MBSTRING_ENCODING_TRANSLATION}"
        echo "mbstring.http_input = ${MBSTRING_HTTP_INPUT}"
        echo "mbstring.http_output = ${MBSTRING_HTTP_OUTPUT}"
        echo "mbstring.detect_order = ${MBSTRING_DETECT_ORDER}"
        echo ""
        echo "expose_php = ${EXPOSE_PHP}"
        echo "session.hash_function = ${SESSION_HASH_FUNCTION}"
        echo "session.save_handler = ${SESSION_SAVE_HANDLER}"
        echo "session.save_path = ${SESSION_SAVE_PATH}"
        echo ""
        echo "short_open_tag = ${SHORT_OPEN_TAG}"
        echo "max_execution_time = ${MAX_EXECUTION_TIME}"
        echo ""
        echo "[Date]"
        echo "date.timezone = ${DATE_TIMEZONE}"
    } > /usr/local/etc/php/php.ini
fi

echo '<?php phpinfo(); ?>' > /var/www/html/index.php

exec "$@"
