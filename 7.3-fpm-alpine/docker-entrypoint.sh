#!/bin/bash
set -e

# -----------------------------------------------
# GID & UID
# -----------------------------------------------

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/group | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
    if [ type groupmod ]; then
        groupmod -g ${TOYBOX_GID} ${GROUP_NAME}
        echo "GID of ${USER_NAME} has been changed."
    else
        sed -i -e "s/^\(${USER_NAME}:x:[0-9]*:\)[0-9]*\(:.*\)$/\1${TOYBOX_GID}\2/" /etc/passwd
        sed -i -e "s/^\(${GROUP_NAME}:x:\)[0-9]*\(:.*\)$/\1${TOYBOX_GID}\2/" /etc/group
        echo "GID of ${GROUP_NAME} has been changed."
    fi
fi

if [ -n "${TOYBOX_UID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $3 }' | grep ${TOYBOX_UID} > /dev/null 2>&1; then
    if [ type usermod ]; then
        usermod -u ${TOYBOX_UID} ${USER_NAME}
        echo "GID of ${GROUP_NAME} has been changed."
    else
        sed -i -e "s/^\(${USER_NAME}:x:\)[0-9]*\(:[0-9]*:.*\)$/\1${TOYBOX_UID}\2/" /etc/passwd
        echo "UID of ${USER_NAME} has been changed."
    fi
fi

# -----------------------------------------------
# conf files & HTML contents
# -----------------------------------------------

[ -d /php-fpm-conf ] && {
    if [ ${PHP_VERSION:0:1} = "5" ]; then
        php_fpm_conf_dir=/etc/php5
    elif [ ${PHP_VERSION:0:1} = "7" ]; then
        php_fpm_conf_dir=/etc/php7
    fi
    mkdir -p ${php_fpm_conf_dir}/fpm.d
    mv /php-fpm-conf/php-fpm.conf ${php_fpm_conf_dir}
    mv /php-fpm-conf/fpm.d/* ${php_fpm_conf_dir}/fpm.d
    rm -rf /php-fpm-conf
}

#php_confdir="/usr/local/etc/php"
#mkdir -p ${php_confdir}
#[ $(ls ${php_confdir} | wc -l) -eq 0 ] && {
#    tar xzf /usr/src/php-conf.tar.gz -C ${php_confdir}
#}
#chown -R ${USER_NAME}:${GROUP_NAME} ${php_confdir}

# -----------------------------------------------
# for Apache2
# -----------------------------------------------

apache2_confdir="/etc/apache2"
[ -d ${apache2_confdir} ] && {
    [ $(ls ${apache2_confdir} | wc -l) -eq 0 ] && {
        tar xzf /usr/src/apache2-conf.tar.gz -C ${apache2_confdir}
    }
    chown -R ${USER_NAME}:${GROUP_NAME} ${apache2_confdir}

    : ${DOCUMENT_ROOT:=/var/www/html}

    site_confdir=${apache2_confdir}/sites-available
    sed -i -e "s:^\(.*DocumentRoot \)/var/www/html$:\1${DOCUMENT_ROOT}:" ${site_confdir}/000-default.conf
    sed -i -e "s:^\(.*DocumentRoot \)/var/www/html$:\1${DOCUMENT_ROOT}:" ${site_confdir}/default-ssl.conf

    [ ! -d ${DOCUMENT_ROOT} ] && {
        mkdir -p ${DOCUMENT_ROOT}
    }

    [ $(ls ${DOCUMENT_ROOT} | wc -l) -eq 0 ] && {
        echo '<?php phpinfo(); ?>' > ${DOCUMENT_ROOT}/index.php
    }
    chown -R ${USER_NAME}:${GROUP_NAME} ${DOCUMENT_ROOT}
}

# -----------------------------------------------
# php module
# -----------------------------------------------

[ "enable" != "${ALL_PHP_MODULES}" ] && {
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

    conf_dir=/etc/php${PHP_VERSION:0:1}/conf.d
    php_ver=${PHP_VERSION:0:1}
    for m in ${modules[@]}; do
        M=$(echo ${m} | tr [a-z] [A-Z])
        [ "enable" != "$(eval echo \"\$${M}\")" ] && {
            [ ${M} = OPCACHE ] && [ -f ${conf_dir}/${m}-recommended.ini ] && {
                rm ${conf_dir}/${m}-recommended.ini
            }
            if [ ${php_ver} = 5 ]; then
                [ -f ${conf_dir}/${m}.ini ] && {
                    rm ${conf_dir}/${m}.ini
                    echo "${m} is disabled."
                }
            elif [ ${php_ver} = 7 ]; then
                [ -f ${conf_dir}/*_${m}.ini ] && {
                    rm ${conf_dir}/*_${m}.ini
                    echo "${m} is disabled."
                }
                [ -f ${conf_dir}/${m}.ini ] && {
                    rm ${conf_dir}/${m}.ini
                    echo "${m} is disabled."
                }
            fi
        }
    done
}

# -----------------------------------------------
# php.ini
# -----------------------------------------------

: ${MAX_EXECUTION_TIME:=30}
: ${MAX_INPUT_TIME:=-1}
: ${MAX_INPUT_VARS:=1000}
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
: ${DATE_TIMEZONE:=UTC}

if [ ! -f ${php_confdir}/php.ini ]; then
    {
        echo "max_execution_time = ${MAX_EXECUTION_TIME}"
        echo "max_input_time = ${MAX_INPUT_TIME}"
        echo "max_input_vars = ${MAX_INPUT_VARS}"
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
    } > /etc/php${PHP_VERSION:0:1}/php.ini
fi

[ -f /php_extension_installer.sh ] && {
    rm /php_extension_installer.sh
}

exec "$@"
