FROM debian:jessie

MAINTAINER Ala Eddine Khefifi "alakhefifi@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://ftp.fr.debian.org/debian jessie-backports main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --no-install-recommends gzip apt-utils ant rsyslog libpcre3 libluajit-5.1-dev tar python-software-properties software-properties-common sqlite3 locales curl apt-transport-https ca-certificates wget vim ffmpeg supervisor git zip unzip

# Fix bug: invoke-rc.d: policy-rc.d denied execution of start.
RUN sed -i -e "s/exit 101/exit 0/g" /usr/sbin/policy-rc.d

RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen

# Install nginx + rtmp module
RUN groupmod -g 1000 www-data && usermod -u 1000 -g www-data www-data && echo "www-data:www-data"
RUN mkdir /run/php && chown -R www-data:www-data /run/php

RUN wget -O - https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php jessie main" > /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get install -y php7.1-fpm \
    php7.1-dev \
    php7.1-common \
    php7.1-cli \
    php7.1-mcrypt \
    php7.1-mysql \
    php7.1-sqlite3 \
    php7.1-apcu \
    php7.1-gd \
    php7.1-curl \
    php7.1-intl \
    php7.1-xdebug \
    php7.1-memcache \
    php7.1-memcached \
    php7.1-xml \
    php7.1-bcmath \
    php7.1-mbstring

RUN sed -i \
    -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
    -e "/listen = .*/c\listen = 127.0.0.1:9000"  \
    -e "s/^;clear_env = no$/clear_env = no/" \
    -e "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g" \
    -e "s/user = www-data/user = www-data/g" \
    -e "s/group /run/php/php7.1-fpm.sock= www-data/group = www-data/g" \
    -e "s/;listen.mode = 0660/listen.mode = 0666/g" \
    -e "s/;listen.owner = www-data/listen.owner = www-data/g" \
    -e "s/listen.owner = www-data/listen.owner = www-data/g" \
    -e "s/;listen.group = www-data/listen.group = www-data/g" \
    /etc/php/7.1/fpm/pool.d/www.conf

RUN sed -i "s/;date.timezone =/date.timezone = Europe\/Paris/" /etc/php/7.1/cli/php.ini

RUN sed -i "s/;date.timezone =/date.timezone = Europe\/Paris/" /etc/php/7.1/fpm/php.ini

RUN chown -R www-data:www-data /run/php

RUN usermod -aG www-data root

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install rabbitmq
RUN groupadd -r rabbitmq && useradd -r -d /var/lib/rabbitmq -m -g rabbitmq rabbitmq
ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-
RUN echo 'deb http://www.rabbitmq.com/debian/ testing main' > /etc/apt/sources.list.d/rabbitmq.list
RUN wget -O- https://www.rabbitmq.com/rabbitmq-release-signing-key.asc | apt-key add -
RUN apt-get update && apt-get install -y --no-install-recommends rabbitmq-server
RUN rabbitmq-plugins enable rabbitmq_management && \
    echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config && \
    chmod 600 /var/lib/rabbitmq/.erlang.cookie


RUN sed -i \
    -e "s/daemon\.\*;mail\.\*;/#daemon.*;mail.*;/g" \
    -e "s/\tnews\.err;/\t#news.err;/g" \
    -e "s/\t\*\.=debug;\*\.=info;/\t#*.=debug;*.=info;/g" \
    -e "s/\t\*\.=notice;\*\.=warn/\t#*.=notice;*.=warn/g" \
    /etc/rsyslog.conf


# Install nginx
RUN touch /etc/apt/sources.list.d/nginx.list
RUN echo 'deb http://nginx.org/packages/debian/ jessie nginx' > /etc/apt/sources.list.d/nginx.list
RUN echo 'deb-src http://nginx.org/packages/debian/ jessie nginx' >> /etc/apt/sources.list.d/nginx.list
RUN curl http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt-get update && apt-get install -y nginx

RUN chown -R www-data:www-data /var/run/nginx.pid && \
  chown -R www-data:www-data /var/cache/nginx

RUN rm /etc/nginx/nginx.conf
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx
COPY nginx/restrict.conf /etc/nginx
COPY nginx/conf.d /etc/nginx/conf.d/

VOLUME ["/var/www"]

EXPOSE 80 5672 15672

RUN apt-get autoclean && apt-get autoremove && apt-get clean

# Add script
COPY script.sh /usr/bin/script.sh
RUN chmod +x /usr/bin/script.sh

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

#USER www-data
