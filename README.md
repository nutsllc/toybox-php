# PHP(5.6.x and 7.0.x) and Apache 2 on Docker

A Dockerfile for deploying a PHP using Docker container.

This image has been extended [the official PHP image](https://hub.docker.com/_/php/) which is maintained in the [docker-library/php](https://github.com/docker-library/php/) GitHub repository and also registered to the [Docker Hub](https://hub.docker.com/r/nutsllc/toybox-php/) that is the official docker image registory.

## Run container

### The simplest way to run container

for PHP 7.0:

``docker run -it -p 8080:80 -d nutsllc/toybox-php:7.0.8-apache``

for PHP 5.6:

``docker run -it -p 8080:80 -d nutsllc/toybox-php:5.6.23-apache``

### To correspond the main process user's gid/uid between inside and outside container

* To find a specific user's UID and GID, at the shell prompt, enter: ``id <username>``

``docker run -it -p 8080:80 -e TOYBOX_GID=1000 -e TOYBOX_UID=1000 -d nutsllc/toybox-php``

### Persistent the Apache2 document root contents

``docker run -it -p 8080:80 -v $(pwd)/.datas/docroot:/usr/local/apache2/htdocs -d nutsllc/toybox-php``

### Persistent the Apache2 config files

``docker run -it -p 8080:80 -v $(pwd)/.data/conf:/etc/apache2 -d nutsllc/toybox-php``

## Docker Compose example
```
toybox-php:
	image: nutsllc/toybox-php:latest
	volumes:
		- "./.data/htdocs:/usr/local/apache2/htdocs"
		- "./.data/conf:/etc/apache2"
	environment:
		- TOYBOX_UID=1000
		- TOYBOX_GID=1000
	ports:
		- "8080:80"
```

## Included modules

### PHP Modules

* apc
* apcu
* calendar
* Core
* ctype
* curl
* date
* dom
* ereg
* exif
* fileinfo
* filter
* gd
* gettext
* hash
* iconv
* intl
* json
* libxml
* mbstring
* mcrypt
* memcached
* mysqli
* mysqlnd
* openssl
* pcre
* PDO
* pdo_mysql
* pdo_pgsql
* pdo_sqlite
* pgsql
* Phar
* posix
* readline
* redis
* Reflection
* session
* SimpleXML
* sockets
* SPL
* sqlite3
* standard
* tokenizer
* xml
* xmlreader
* xmlwriter
* zip
* zlib

### Zend Modules

* Xdebug
* Zend OPcache



## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/nutsllc/toybox-apache2/issues), or submit a [pull request](https://github.com/nutsllc/toybox-apache2/pulls) with your contribution.