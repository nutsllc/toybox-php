#!/bin/bash

self=$(cd $(dirname $0);pwd)
dist=${self}/..

dirs=(
    "${dist}/5.6/apache"
    "${dist}/5.6/fpm"
    "${dist}/7.0/apache"
    "${dist}/7.0/fpm"
    "${dist}/7.1/apache"
    "${dist}/7.1/fpm"
    "${dist}/7.2/apache"
    "${dist}/7.2/fpm"
)
for d in ${dirs[@]}; do
    src=${self}/../seed/ubuntu
    [ -d ${d} ] && rm -r ${d}
    php_ver=$(echo ${d} | awk -F "/" '{print $(NF - 1)}')
    if [ ${php_ver} = "5.6" ]; then
        php_ver=5.6.23
        apcu_ver=4.0.11
        redis_ver=2.2.8
        xdebug_ver=2.4.1
    elif [ ${php_ver} = "7.0" ]; then
        php_ver=7.0.8
        apcu_ver=5.1.6
        redis_ver=3.0.0
        xdebug_ver=2.4.1
    elif [ ${php_ver} = "7.1" ]; then
        php_ver=7.1.25
        apcu_ver=5.1.15
        redis_ver=3.1.6
        xdebug_ver=2.6.0
    elif [ ${php_ver} = "7.2" ]; then
        php_ver=7.2.13
        apcu_ver=5.1.15
        redis_ver=4.2.0
        xdebug_ver=2.6.0
    elif [ ${php_ver} = "7.3" ]; then
    # does not implemented yet
        php_ver=7.3
        apcu_ver=5.1.15
        redis_ver=4.2.0
        xdebug_ver=2.6.0
    fi
    php_type=$(echo ${d} | awk -F "/" '{print $NF}')
    dockerfile=${src}/${php_type}/Dockerfile-seed
    printf "Generate: Dockerfile for PHP ${php_ver}-${php_type} ..."
    mkdir -p ${d}
    cp ${dockerfile} ${d}/Dockerfile
    cp ${src}/docker-entrypoint.sh-seed ${d}/docker-entrypoint.sh
    cp ${src}/php_extension_installer.sh-seed ${d}/php_extension_installer.sh
    chmod 755 ${d}/docker-entrypoint.sh
    chmod 755 ${d}/php_extension_installer.sh
    sed -i -e "s/{{FROM_PHP_VERSION}}/${php_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{ENV_PHP_VERSION}}/${php_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{APCU_VERSION}}/${apcu_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{REDIS_VERSION}}/${redis_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{XDEBUG_VERSION}}/${xdebug_ver}/g" ${d}/Dockerfile
    echo "done."
    [ -f ${d}/Dockerfile-e ] && {
        rm ${d}/Dockerfile-e
    }
done

# -------------------------------------------------------------------
# for fpm-alpine
# -------------------------------------------------------------------
dirs=(
    "${dist}/5.6-alpine/fpm"
    "${dist}/7.0-alpine/fpm"
)
for d in ${dirs[@]}; do
    src=${self}/../seed/alpine
    [ -d ${d} ] && rm -r ${d}
    php_ver=$(echo ${d} | awk -F "/" '{print $(NF - 1)}')
    if [ ${php_ver} = "5.6-alpine" ]; then
        php_ver=5
    elif [ ${php_ver} = "7.0-alpine" ]; then
        php_ver=7
    fi
    php_type=$(echo ${d} | awk -F "/" '{print $NF}')
    printf "Generate: Dockerfile for PHP ${php_ver}-${php_type}-alpine ..."
    mkdir -p ${d}
    cp ${src}/${php_type}/Dockerfile-seed ${d}/Dockerfile
    cp -r ${src}/${php_type}/php-fpm-conf ${d}
    cp ${src}/${php_type}/Makefile-seed ${d}/Makefile
    cp ${src}/docker-entrypoint.sh-seed ${d}/docker-entrypoint.sh
    cp ${src}/php_extension_installer_alpine.sh-seed ${d}/php_extension_installer_alpine.sh
    chmod 755 ${d}/docker-entrypoint.sh
    chmod 755 ${d}/php_extension_installer_alpine.sh
    sed -i'' -e "s/{{ENV_PHP_VERSION}}/${php_ver}/" ${d}/Dockerfile
    sed -i'' -e "s/{{PHP_VERSION}}/${php_ver}/" ${d}/Makefile
    sed -i'' -e "s/{{PHP_VERSION}}/${php_ver}/" ${d}/php-fpm-conf/php-fpm.conf

    [ ${php_ver} = 7 ] && {
        sed -i -e "s/^\(CMD \[\)\"php-fpm\"\(\]\)/\1\"php-fpm7\",\"-F\"\2/" ${d}/Dockerfile
    }

    [ -f ${d}/Dockerfile-e ] && {
        rm ${d}/Dockerfile-e
    }

    [ -f ${d}/Makefile-e ] && {
        rm ${d}/Makefile-e
    }

    echo "done."
done

echo "complete!"

exit 0
