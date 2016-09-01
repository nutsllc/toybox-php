#!/bin/bash
set -e

user="www-data"
group="www-data"

if [ -n "${TOYBOX_GID+x}" ]; then
    groupmod -g ${TOYBOX_GID} ${group}
fi

if [ -n "${TOYBOX_UID+x}" ]; then
    usermod -u ${TOYBOX_UID} ${user}
fi

docroot="/var/www/html"
mkdir -p ${docroot}
tar xvzf /usr/src/apache2-default-doc.tar.gz -C ${docroot}
chown -R ${user}:${group} ${docroot}

apache2_confdir="/etc/apache2"
mkdir -p ${apache2_confdir}
tar xvzf /usr/src/apache2-conf.tar.gz -C ${apache2_confdir}
chown -R ${user}:${group} ${apache2_confdir}

php_confdir="/usr/local/etc/php"
mkdir -p ${php_confdir}
tar xvzf /usr/src/php-conf.tar.gz -C ${php_confdir}
chown -R ${user}:${group} ${php_confdir}

exec "$@"
