all: php

php:
	docker build -t test/fpm-alpine:7 .

run:
	docker run -itd test/fpm-alpine:7

shell:
	docker run -it test/fpm-alpine:7 /bin/bash
