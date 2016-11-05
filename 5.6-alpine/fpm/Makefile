all: php

php:
	docker build -t test/fpm-alpine:5 .

run:
	docker run -itd test/fpm-alpine:5

shell:
	docker run -it test/fpm-alpine:5 /bin/bash
