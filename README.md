# PHP(5.6.x and 7.0.x) on Docker

A Dockerfile for deploying a PHP using Docker container.

This ``toybox-php`` image has been extended [the official PHP image](https://hub.docker.com/_/php/) which is maintained in the [docker-library/php](https://github.com/docker-library/php/) GitHub repository.

This image is registered to the [Docker Hub](https://hub.docker.com/r/nutsllc/toybox-php/) which is the official docker image registory.

## Feature

* gid/uid inside container correspond with outside container gid/uid by ``TOYBOX_GID`` or ``TOYBOX_UID`` environment valiable.

## Usage

### The simplest way to run
``docker run -it -p 8080:80 -d nutsllc/toybox-php``

### To correspond the gid/uid between inside and outside container

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

## Contributing

We'd love for you to contribute to this container. You can request new features by creating an [issue](https://github.com/nutsllc/toybox-apache2/issues), or submit a [pull request](https://github.com/nutsllc/toybox-apache2/pulls) with your contribution.