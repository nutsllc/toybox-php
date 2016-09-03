#!/bin/bash
set -e

user="www-data"
group="www-data"

if [ -n "${TOYBOX_GID}" ] && ! cat /etc/passwd | awk 'BEGIN{ FS= ":" }{ print $4 }' | grep ${TOYBOX_GID} > /dev/null 2>&1; then
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

exec "$@"
