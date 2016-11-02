#!/bin/sh
set -e

test_container="nuts-php-test"

php_version=5.6
#php_version=7.0

function _build() {
    printf ">>> build..."
    dir="$(cd $(dirname $0);pwd)/../${php_version}/apache/"
    #docker build -t ${test_container} $(cd $(dirname $0);pwd)/../ > /dev/null 2>&1
    #docker build -t ${test_container} ${dir} > /dev/null 2>&1
    docker build -t ${test_container} ${dir}
    echo "done"
}

function _run() {
    printf ">>> run..."
    id=$(docker run --name ${test_container} -p 9876:80 ${modules[@]} ${php_ini_values[@]} -itd ${test_container} > /dev/null 2>&1) || {
        id=$(docker start ${test_container})
    }; echo "done"

    printf ">>> wait.."
    until curl http://localhost:9876 > /dev/null 2>&1; do
        printf "."; sleep 1
    done; echo "done"

    set +e
    echo "---------------------------------------------"
    echo " PHP version: ${php_version}"
    echo "---------------------------------------------"
    for i in ${modules[@]}; do
        [ $i = '-e' ] && continue
        key=$(echo ${i} | cut -d"=" -f1)
        val=$(echo ${i} | cut -d"=" -f2)
        printf "test $i ..."
        if [ ${key} = "OPCACHE" ]; then
            if [ ${val} = 'enable' ]; then
                command="$(docker exec -it ${test_container} php -m | grep 'Zend OPcache')"
            else
                command="! $(docker exec -it ${test_container} php -m | grep 'Zend OPcache')"
            fi
        else
            if [ ${val} = 'enable' ]; then 
                command="$(docker exec -it ${test_container} php -m | grep $(echo ${key} | tr '[A-Z]' '[a-z]'))"
            else
                command="! $(docker exec -it ${test_container} php -m | grep $(echo ${key} | tr '[A-Z]' '[a-z]'))"
            fi
        fi

        if [ -n "${command}" ]; then
            printf "\033[1;32m%-10s\033[0m" "OK"
        else
            printf "\033[1;31m%-10s\033[0m" "NG"
        fi 
        printf "\n"
    done
    echo "---------------------------------------------"
    docker exec -it nuts-php-test cat /usr/local/etc/php/php.ini
    echo "---------------------------------------------"
}
    
function _stop() {
    printf ">>> stop..."
    docker stop ${test_container}
}
function _rm() {
    printf ">>> rm..."
    docker rm -f ${test_container}
}
function _down() {
    _stop && {
        _rm
    }
}
function _rmi() {
    printf ">>> rmi..."
    docker rmi -f ${test_container}
}

modules=(
    "-e CALENDAR=enable"
    "-e EXIF=enable"
    "-e GD=enable"
    "-e GETTEXT=enable"
    "-e INTL=enable"
    "-e MCRYPT=enable"
    "-e MEMCACHED=enable"
    "-e MYSQLI=enable"
    "-e OPCACHE=enable"
    "-e PDO_MYSQL=enable"
    "-e PDO_PGSQL=enable"
    "-e SOCKETS=enable"
    "-e ZIP=enable"
    "-e APCU=enable"
    "-e REDIS=enable"
    "-e XDEBUG=enable"
)

php_ini_values=(
    "-e MEMORY_LIMIT=32M"
    "-e POST_MAX_SIZE=16M"
    "-e UPLOAD_MAX_FILESIZE=8M"
    "" 
    "-e ERROR_REPORTING=E_ALL|E_STRICT"
    "-e DISPLAY_ERRORS=Off"
    "-e LOG_ERRORS=On"
    "-e ERROR_LOG=/var/log/php_error.log"
    "" 
    "-e DEFAULT_CHARSET='UTF-8'"
    "-e MBSTRING_LANGUAGE=Japanese"
    "-e MBSTRING_INTERNAL_ENCODING=UTF-8"
    "-e MBSTRING_ENCODING_TRANSLATION=Off"
    "-e MBSTRING_HTTP_INPUT=pass"
    "-e MBSTRING_HTTP_OUTPUT=pass"
    "-e MBSTRING_DETECT_ORDER=auto"
    "" 
    "-e EXPOSE_PHP=Off"
    "-e SESSION_HASH_FUNCTION=0"
    "-e SESSION_SAVE_HANDLER=files"
    "-e SESSION_SAVE_PATH='/var/lib/php/session'"
    "" 
    "-e SHORT_OPEN_TAG=On"
    "-e MAX_EXECUTION_TIME=30"
    "" 
    "-e DATE_TIMEZONE=UTC"
)

if [ $# -eq 0 ]; then
    _build 
    _run 
    _down
else
    _$1
fi

exit 0