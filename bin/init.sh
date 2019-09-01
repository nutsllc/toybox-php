#!/bin/bash

self=$(cd $(dirname $0);pwd)
dist=${self}/..

dirs=(
    "${dist}/5.6"
    #"${dist}/5.6-fpm"
    "${dist}/7.0"
    #"${dist}/7.0-fpm"
    "${dist}/7.1"
    #"${dist}/7.1-fpm"
    "${dist}/7.2"
    #"${dist}/7.2-fpm"
)

src=${self}/../seed/ubuntu
for d in ${dirs[@]}; do
    [ -d ${d} ] && rm -r ${d}
    label=$(echo ${d} | awk -F "/" '{print $(NF - 0)}')
    php_ver=${label:0:3}
    if [ ${#label} -gt 3 ]; then
        php_type=fpm
    else
        php_type=apache
    fi
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

    dockerfile=${src}/${php_type}/Dockerfile.seed
    printf "Generate: Dockerfile for PHP ${php_type} ..."
    mkdir -p ${d}
    cp ${dockerfile} ${d}/Dockerfile
    cp -r ${src}/docker-compose ${d}/docker-compose
    cp ${src}/docker-entrypoint.sh.seed ${d}/docker-entrypoint.sh
    cp ${src}/php_extension_installer.sh.seed ${d}/php_extension_installer.sh
    chmod 755 ${d}/docker-entrypoint.sh
    chmod 755 ${d}/php_extension_installer.sh
    sed -i -e "s/{{LABEL}}/${label}/g" ${d}/Dockerfile
    sed -i -e "s/{{LABEL}}/${label}/g" ${d}/docker-compose/docker-compose.yml
    sed -i -e "s/{{FROM_PHP_VERSION}}/${php_ver:0:3}/g" ${d}/Dockerfile
    sed -i -e "s/{{ENV_PHP_VERSION}}/${php_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{APCU_VERSION}}/${apcu_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{REDIS_VERSION}}/${redis_ver}/g" ${d}/Dockerfile
    sed -i -e "s/{{XDEBUG_VERSION}}/${xdebug_ver}/g" ${d}/Dockerfile
    echo "done."

    find ${d} -name *-e | xargs rm
done

# -------------------------------------------------------------------
# for fpm-alpine
# -------------------------------------------------------------------
dirs=(
#    "${dist}/5.6-fpm-alpine"
#    "${dist}/7.0-fpm-alpine"
#    "${dist}/7.1-fpm-alpine"
    "${dist}/7.2-fpm-alpine"
    "${dist}/7.3-fpm-alpine"
)

function _generate_for_php_fpm_alpine() {
    src=${self}/../seed/alpine

    for d in ${dirs[@]}; do
        [ -d ${d} ] && rm -r ${d}
        dirname=$(echo ${d} | awk -F "/" '{print $(NF - 0)}')
        php_ver=${dirname:0:3}

        if [ ${php_ver} = 7.3 ]; then
            alpine_ver=3.10
        elif [ ${php_ver} = 7.2 ]; then
            alpine_ver=3.9
        elif [ ${php_ver} = 7.1 ]; then
            alpine_ver=3.7
        elif [ ${php_ver} = 7.0 ]; then
            alpine_ver=3.5
        else
            alpine_ver=3.10
        fi

        printf "Generate: Dockerfile for PHP-FPM-${php_ver}-alpine ..."
        mkdir -p ${d}/docker-compose

        files=(
            Dockerfile.seed
            docker-entrypoint.sh.seed
            php_extension_installer.sh.seed
            php-fpm-conf
            docker-compose/docker-compose.yml.seed
            docker-compose/data.seed
        )

        for file in ${files[@]}; do
            cp -r ${src}/${file} ${d}/${file%.*}
        done

        chmod 755 ${d}/docker-entrypoint.sh
        chmod 755 ${d}/php_extension_installer.sh
        sed -i'' -e "s/{{PHP_VERSION}}/${php_ver}/" ${d}/Dockerfile
        sed -i'' -e "s/{{ALPINE_VERSION}}/${alpine_ver}/" ${d}/Dockerfile
        sed -i'' -e "s/{{PHP_VERSION}}/${php_ver:0:1}/" ${d}/php-fpm-conf/php-fpm.conf
        sed -i'' -e "s/{{PHP_VERSION}}/${php_ver}/" ${d}/docker-compose/docker-compose.yml

        [ ${php_ver:0:1} = 7 ] && {
            sed -i -e "s/^\(CMD \[\)\"php-fpm\"\(\]\)/\1\"php-fpm7\",\"-F\"\2/" ${d}/Dockerfile
        }

        find ${d} -name *-e | xargs rm
        echo "done."
    done
}
_generate_for_php_fpm_alpine

echo "complete!"
exit 0
