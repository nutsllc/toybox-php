FROM php:5.6.23-apache
MAINTAINER NutsProject, LLC <dev@nutsllc.jp>

ENV APCU_VERSION 4.0.11
ENV MEMCACHED_VERSION 2.2.0
ENV REDIS_VERSION 2.2.8
ENV XDEBUG_VERSION 2.4.1

RUN a2enmod rewrite expires

RUN apt-get update && apt-get install -y \
    yes \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

RUN tar czf /usr/src/apache2-default-doc.tar.gz -C /var/www/html ./ \
    && tar czf /usr/src/apache2-conf.tar.gz -C /etc/apache2 ./ \
    && tar czf /usr/src/php-conf.tar.gz -C /usr/local/etc/php ./

VOLUME /var/www/html

ADD docker-entrypoint.sh /entrypoint-ex.sh
ENTRYPOINT ["/entrypoint-ex.sh"]

CMD ["apache2-foreground"]
