FROM php:7.0-fpm
MAINTAINER XiaodongHuang <ddonng@qq.com>

RUN apt-get update && apt-get install -y git && apt-get install -y zlib1g-dev

RUN docker-php-ext-install pdo_mysql && docker-php-ext-install sockets

RUN apt-get install -y libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev
RUN git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git
RUN cd php-memcached && phpize && ./configure && make && make install \
    && echo "extension=memcached.so" >> /usr/local/etc/php/conf.d/memcached.ini

RUN pecl install redis-3.0.0 \
    && rm -rf /tmp/pear \
    && echo "extension=redis.so" >> /usr/local/etc/php/conf.d/redis.ini

RUN apt-get install -y pkg-config libssl-dev
RUN pecl install mongodb-1.5.3 && echo "extension=mongodb.so" >> /usr/local/etc/php/conf.d/mongodb.ini

# swoole extension
RUN pecl install swoole-1.9.19 && echo extension=swoole.so >> /usr/local/etc/php/conf.d/swoole.ini

# phalcon extension
RUN apt-get install -y libpcre3-dev openssl libssl-dev
RUN git clone -b 3.1.x --depth=1 http://github.com/phalcon/cphalcon
RUN cd cphalcon/build && ./install \
    && echo extension=phalcon.so >> /usr/local/etc/php/conf.d/phalcon.ini
RUN rm -rf cphalcon

RUN apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd
RUN docker-php-ext-install bcmath
RUN echo "Asia/Shanghai" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get update && \
     apt-get install -y \
         zlib1g-dev \
         && docker-php-ext-install zip
RUN echo "date.timezone = PRC\n"\
    "memory_limit = 256M\n" \
    "upload_max_filesize = 200M\n" \
    "post_max_size = 200M\n" \
    "max_execution_time = 60\n" \
    "log_errors = On\n" \
    "error_log = /dev/stderr\n" >> /usr/local/etc/php/php.ini
# clean
RUN apt-get remove -y build-essential libmemcached-dev libz-dev git \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

VOLUME ["/var/www/html"]
