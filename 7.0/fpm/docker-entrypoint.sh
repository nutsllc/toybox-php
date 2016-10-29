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

docroot="/var/www/html"
mkdir -p ${docroot}
[ $(ls ${docroot} | wc -l) -eq 0 ] && {
    #tar xzf /usr/src/apache2-default-doc.tar.gz -C ${docroot}
    echo '<?php phpinfo(); ?>' > ${docroot}/index.php
}
chown -R ${user}:${group} ${docroot}

php_confdir="/usr/local/etc/php"
mkdir -p ${php_confdir}
[ $(ls ${php_confdir} | wc -l) -eq 0 ] && {
    tar xzf /usr/src/php-conf.tar.gz -C ${php_confdir}
}
chown -R ${user}:${group} ${php_confdir}

# -----------------------------------------------
# php module
# -----------------------------------------------
[ "enable" != "${ALL_PHP_MODULES}" ] && { 
    conf_dir=/usr/local/etc/php/conf.d
    modules=(
        calendar
        exif
        gd
        gettext
        intl
        mcrypt
        mysqli
        opcache
        pdo_mysql
        pdo_pgsql
        pgsql
        sockets
        zip
        apcu
        memcached
        redis
        xdebug
    )
    
    for m in ${modules[@]}; do
        M=$(echo ${m} | tr [a-z] [A-Z])
        r=$(echo ${m} | tr [a-z] [A-Z])
        [ "enable" != "$(eval echo \"\$${M}\")" ] && {
            [ ${M} = OPCACHE ] && [ -f ${conf_dir}/${m}-recommended.ini ] && {
                rm ${conf_dir}/${m}-recommended.ini
            }
            [ ${M} = MEMCACHED ] && [ ${PHP_VERSION:0:1} = "7" ] && [ -f ${conf_dir}/${m}.ini ] && {
                rm ${conf_dir}/${m}.ini
                echo "${m} is disabled." && continue
            }
            [ -f ${conf_dir}/docker-php-ext-${m}.ini ] && {
                rm ${conf_dir}/docker-php-ext-${m}.ini
                echo "${m} is disabled."
            }
        }
    done
}

# -----------------------------------------------
# php.ini
# -----------------------------------------------
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

rm /php_extension_installer.sh

exec "$@"