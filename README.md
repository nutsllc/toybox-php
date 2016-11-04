# PHP (5.6 and 7.0) on Docker (with Apache or PHP-FPM)

A Dockerfile for deploying a PHP running environment using Docker container.

This image is extended [the official PHP image](https://hub.docker.com/_/php/) which is maintained in the [docker-library/php](https://github.com/docker-library/php/) GitHub repository and also registered to the [Docker Hub](https://hub.docker.com/r/nutsllc/toybox-php/) that is the official docker image registory.

## Main Feautures

With this Docker image...

* You can choose PHP running version and environment freely by Docker image tags.
* By setting the GID and UID of the main process user in the container, it is possible to avoid the permission trouble.
* You can enable extra PHP extension modules you need by environment variables.
* You can change php.ini value by environment variables.

## Running Container

### The simplest way to run container

**for PHP 7.0 (with Apache2):**

``docker run -p 8080:80 -itd nutsllc/toybox-php:7.0-apache``

**for PHP 5.6 (with Apache2):**

``docker run -p 8080:80 -itd nutsllc/toybox-php:5.6-apache``

**for PHP-FPM 7.0:**

``docker run --name fpm70 -itd nutsllc/toybox-php:7.0-fpm``

**for PHP-FPM 5.6:**

``docker run --name fpm56 -idd nutsllc/toybox-php:5.6-fpm``

## To correspond the main process user's gid/uid between inside and outside container

* To find a specific user's UID and GID in Local machine, in the shell prompt at the local machine, enter: ``id <username>``

``docker run -it -p 8080:80 -e TOYBOX_GID=<your gid> -e TOYBOX_UID=<your uid> -d nutsllc/toybox-php``

## Persistent the container data

Add ``-v`` option to docker run command to persistent the container data.


**Apache2 document root**

``-v "$(pwd)"/data/docroot:/var/www/html"``

**Apache2 config files**

``-v "$(pwd)"/data/conf:/etc/apache2``

**PHP config files**

``-v "$(pwd)"/data/conf:/usr/local/etc/php``

## Loading PHP extensions

PHP extensions can be enabled by environment variables with ``enable`` value.

For example:

``docker run -it -p 8080:80 -e GD=enable -e MEMCACHED=enable -e APCU=enable -e OPCACHE=enable -e XDEBUG=true -d nutsllc/toybox-php:7.0.8-apache``

### List of the PHP extensions that you can enable to container

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
* ``-e SOCKETS=enable``
* ``-e ZIP=enable``
* ``-e APCU=enable``
* ``-e REDIS=enable``
* ``-e XDEBUG=enable``

If you want to enable all of the modules, you could use ``-e ALL_PHP_MODULES=enable``, no more need other options.

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

## Docker Compose example

### PHP (with Apache2)

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

### LAMP: PHP with Apache2 and database (MySQL)

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

### PHP-FPM with Nginx and database

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

## The main configuration file path in container

### PHP (w/Apache2) image: ``nutsllc/toybox-php:x.x-apache``

||File or Directory Path|
|:---|:---|
|Document root|``/var/www/html``|
|Apache2 Configuration files|``/etc/apache2``|
|php.ini|``/usr/local/etc/php/php.ini``|
|PHP modules conf files|``/usr/local/etc/php/conf.d/``|

### PHP-FPM image: ``nutsllc/toybox-php:x.x-fpm``

||File or Directory Path|
|:---|:---|
|PHP-FPM configuration files|``/usr/local/etc/php-fpm.d/``|
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
