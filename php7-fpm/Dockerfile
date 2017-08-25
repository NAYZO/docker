FROM debian:jessie

MAINTAINER Ala Eddine Khefifi <alakhefifi@gmail.com>

RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  curl \
  wget \
  software-properties-common \
  libicu-dev \
  git \
  apt-transport-https \
  ca-certificates \
  vim \
  zsh

# Permission fix
RUN usermod -u 1000 www-data

#RUN groupmod -g 1000 www-data && usermod -u 1000 -g www-data www-data && echo "www-data:www-data"

RUN echo en_US.UTF-8 UTF-8 >> /etc/locale.gen && locale-gen

# Set timezone
RUN rm /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
RUN "date"

RUN wget -O - https://packages.sury.org/php/apt.gpg | apt-key add -
RUN echo "deb https://packages.sury.org/php jessie main" > /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get install -y --force-yes \
  php7.1-fpm \
  php7.1-bcmath \
  php7.1-cli \
  php7.1-common \
  php7.1-curl \
  php7.1-dev \
  php7.1-gd \
  php7.1-intl \
  php7.1-json \
  php7.1-mbstring \
  php7.1-mcrypt \
  php7.1-mysql \
  php7.1-sqlite3 \
  php7.1-opcache \
  php7.1-xdebug \
  php7.1-soap \
  php7.1-xml \
  php7.1-xmlrpc \
  php7.1-xsl \
  php7.1-zip \
  php7.1-memcache \
  php7.1-memcached \
  php7.1-apcu

RUN sed -i "s/;date.timezone =/date.timezone = Europe\/Paris/" /etc/php/7.1/fpm/php.ini

RUN sed -i "s/memory_limit = .*/memory_limit = 1024M/" /etc/php/7.1/fpm/php.ini

RUN sed -i "s/opcache.max_accelerated_files = .*/opcache.max_accelerated_files = 20000/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/realpath_cache_size = .*/realpath_cache_size = 4096K/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/realpath_cache_ttl = .*/realpath_cache_ttl = 600/" /etc/php/7.1/fpm/php.ini

RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/short_open_tag = On/short_open_tag = Off/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1024M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 1024M/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/max_execution_time = .*/max_execution_time = 500/" /etc/php/7.1/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini

RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php7.1-fpm.pid/" /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.1/fpm/php-fpm.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.1/fpm/php-fpm.conf

RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/7.1/fpm/pool.d/www.conf
RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.1/fpm/pool.d/www.conf

RUN mv /etc/php/7.1/cli/php.ini /etc/php/7.1/cli/php.ini.back
RUN ln -s /etc/php/7.1/fpm/php.ini /etc/php/7.1/cli/php.ini

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

# Install zsh
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
RUN sed -i "s/plugins=(/plugins=(github history symfony2 docker docker-compose /g" ~/.zshrc

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#WORKDIR /var/www/html

EXPOSE 9000

CMD ["php-fpm7.1"]
