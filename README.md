# Toybox PHP

This is a collection of the Dockerfile for PHP. 

## Getting started

### Strp1: Clone repository
```bash
$ git clone https://github.com/nutsllc/toybox-php
```

### Step2: Running Container
- When you run some version of the container, you should change directory specified each version of the container you want run it.
- Then only you have to do is running ``docker-compose up -d`` command.

```bash
$ cd 7.3-fpm-alpine/docker-compose/
$ docker-compose up d
```

Enjoy :-)

## Edit Dockerfile or docker-compose.yml

- Seed files are in ``seed/`` directory. So you can edit them.
- After you edit some seed files, you are going to generate Dockerfile, docker-compose.yml and so on by running command bellow.

```bash
$ cd path/to/clon/directory
$ sh bin/init.sh
```

## Loading PHP extensions

PHP extensions can be enabled by environment variables with ``enable`` value.

For example:

``docker run -it -p 8080:80 -e GD=enable -e MEMCACHED=enable -e APCU=enable -e OPCACHE=enable -e XDEBUG=true -d nutsllc/toybox-php:7.0.8-apache``

### List of the PHP extensions that can be enabled

* ``-e CALENDAR=enable``
* ``-e EXIF=enable``
* ``-e GD=enable``
* ``-e GETTEXT=enable``
* ``-e INTL=enable``
* ``-e MCRYPT=enable``
* ``-e MEMCACHED=enable``
* ``-e MYSQLI=enable``
* ``-e OPCACHE=enable``
* ``-e PDO_MYSQL=enable``
* ``-e PDO_PGSQL=enable``
* ``-e BCMATH=enable``
* ``-e SOCKETS=enable``
* ``-e ZIP=enable``
* ``-e APCU=enable``
* ``-e REDIS=enable``
* ``-e XDEBUG=enable``

You would like to enable all of the modules, you could use ``-e ALL_PHP_MODULES=enable``, no more need other options.

If you do so, you can disable each PHP modules you don't need.

For example:

``docker run -it -p 8080:80 -e ALL_PHP_MODULE=enable -e OPCACHE=disable -d nutsllc/toybox-php:7.0.8-apache``


## Change php.ini parameter values

Parameter values in php.ini can be changed by environment variables with new value.

For example:

``docker run -it -p 8080:80 -e MEMORY_LIMIT=64M -e POST_MAX_SIZE=32M -e UPLOAD_MAX_FILESIZE=8M -d nutsllc/toybox-php:7.0.8-apache``

### List of the php.ini paramaters that you can change

Values list below are a default value.

* ``-e MEMORY_LIMIT="32M"``
* ``-e POST_MAX_SIZE="16M"``
* ``-e UPLOAD_MAX_FILESIZE="8M"``
* ``-e ERROR_REPORTING="E_ALL|E_STRICT"``
* ``-e DISPLAY_ERRORS="Off"``
* ``-e LOG_ERRORS="On"``
* ``-e ERROR_LOG="/var/log/php_error.log"``
* ``-e DEFAULT_CHARSET="'UTF-8'"``
* ``-e MBSTRING_LANGUAGE="Japanese"``
* ``-e MBSTRING_INTERNAL_ENCODING="UTF-8"``
* ``-e MBSTRING_ENCODING_TRANSLATION="Off"``
* ``-e MBSTRING_HTTP_INPUT="pass"``
* ``-e MBSTRING_HTTP_OUTPUT="pass"``
* ``-e MBSTRING_DETECT_ORDER="auto"``
* ``-e EXPOSE_PHP="Off"``
* ``-e SESSION_HASH_FUNCTION="0"``
* ``-e SESSION_SAVE_HANDLER="files"``
* ``-e SESSION_SAVE_PATH="'/var/lib/php/session'"``
* ``-e SHORT_OPEN_TAG="On"``
* ``-e MAX_EXECUTION_TIME="30"``
* ``-e DATE_TIMEZONE="UTC"``

## Docker Compose examples

### ex1. Apache2 + PHP:

```
apache-php:
	image: nutsllc/toybox-php:latest
	volumes:
		- "./data/docroot:/var/www/html"
	environment:
		- ALL_PHP_MODULES=enable
	ports:
		- "8080:80"
```

### ex2. Apache2 + PHP + MySQL:

```
apache-php:
	image: nutsllc/toybox-php:latest
	volumes:
		- "./data/docroot:/var/www/html"
	links:
		- mysql
	environment:
		- ALL_PHP_MODULES=enable
	ports:
		- "8080:80"

mysql:
	image: mysql:5.7.13
	volumes:
    	- ./data/mysql:/var/lib/mysql
	environment:
    	- MYSQL_ROOT_PASSWORD=root
```

### ex3. Nginx + PHP-FPM + MySQL:

```bash
nginx:
    image: nutsllc/toybox-nginx
    links:
        - php70-fpm
        - mariadb
    ports:
        - 8080:80
    environment:
        - PHP_FPM_HOST=php70-fpm:9000
    volumes_from:
        - data

php70-fpm:
    image: nutsllc/toybox-php:7.0-fpm
    links:
        - mariadb
	environment:
		- ALL_PHP_MODULES=enable
    volumes_from:
        - data

mariadb:
    image: nutsllc/toybox-mariadb
    environment:
        - MYSQL_ROOT_PASSWORD=root

data:
    image: busybox
    volumes:
        - "./data/docroot:/usr/share/nginx/html"
        - "./data/mariadb-conf:/var/run/mysql"

```

## The common configuration files path in container

### Apache2 based container:

||File or Directory Path|
|:---|:---|
|Document root|``/var/www/html``|
|Apache2 conf files|``/etc/apache2``|
|php.ini|``/usr/local/etc/php/php.ini``|
|PHP modules conf files|``/usr/local/etc/php/conf.d/``|

### PHP-FPM based container:

||File or Directory Path|
|:---|:---|
|PHP-FPM conf files|``/usr/local/etc/php-fpm.d/``|
|php.ini|``/usr/local/etc/php/php.ini``|
|PHP modules conf files|``/usr/local/etc/php/conf.d/``|


## Included modules

### PHP Modules

It shuld be apply an enviroment variable like ``-e apcu=enable`` to use optional modules. More detail, see ``Add PHP Modules`` section above.

* apcu (Optional)
* calendar (Optional)
* Core
* ctype
* curl
* date
* dom
* ereg
* exif (Optional)
* fileinfo
* filter
* gd (Optional)
* gettext (Optional)
* hash
* iconv
* intl (Optional)
* json
* libxml
* mbstring
* mcrypt (Optional)
* memcached (Optional)
* mysqli (Optional)
* mysqlnd
* opcache (Optional)
* openssl
* pcre
* PDO
* pdo_mysql (Optional)
* pdo_pgsql (Optional)
* pdo_sqlite
* pgsql
* phar
* posix
* readline
* redis (Optional)
* Reflection
* session
* SimpleXML
* sockets (Optional)
* SPL
* sqlite3
* standard
* tokenizer
* xdebug (Optional)
* xml
* xmlreader
* xmlwriter
* zip(Optional)
* zlib

### PHP Zend Modules

* Xdebug (Option)
* Zend OPcache (Optional)

### Apache modules

* core_module (static)
* so_module (static)
* watchdog_module (static)
* http_module (static)
* log_config_module (static)
* logio_module (static)
* version_module (static)
* unixd_module (static)
* access_compat_module (shared)
* alias_module (shared)
* auth_basic_module (shared)
* authn_core_module (shared)
* authn_file_module (shared)
* authz_core_module (shared)
* authz_host_module (shared)
* authz_user_module (shared)
* autoindex_module (shared)
* deflate_module (shared)
* dir_module (shared)
* env_module (shared)
* expires_module (shared)
* filter_module (shared)
* mime_module (shared)
* mpm_prefork_module (shared)
* negotiation_module (shared)
* php5_module (shared)
* rewrite_module (shared)
* setenvif_module (shared)
* status_module (shared)

## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/nutsllc/toybox-php/issues), or submit a [pull request](https://github.com/nutsllc/toybox-php/pulls) with your contribution.
