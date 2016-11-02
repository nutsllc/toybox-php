#!/bin/bash

self=$(cd $(dirname $0);pwd)
src=${self}/../seed
dist=${self}/..

dirs=(
    "${dist}/5.6/apache"
    "${dist}/5.6/fpm"
    "${dist}/7.0/apache"
    "${dist}/7.0/fpm"
)

for d in ${dirs[@]}; do
    [ -d ${d} ] && rm -r ${d}
    php_ver=$(echo ${d} | awk -F "/" '{print $(NF - 1)}')
    if [ ${php_ver} = "5.6" ]; then
        php_ver=5.6.23
        apcu_ver=4.0.11
        redis_ver=2.2.8
    elif [ ${php_ver} = "7.0" ]; then
        php_ver=7.0.8
        apcu_ver=5.1.6
        redis_ver=3.0.0
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
    sed -i -e "s/{{FROM_PHP_VERSION}}/${php_ver}/" ${d}/Dockerfile
    sed -i -e "s/{{ENV_PHP_VERSION}}/${php_ver}/" ${d}/Dockerfile
    sed -i -e "s/{{APCU_VERSION}}/${apcu_ver}/" ${d}/Dockerfile
    sed -i -e "s/{{REDIS_VERSION}}/${redis_ver}/" ${d}/Dockerfile
    echo "done."
done
echo "complete!"

exit 0