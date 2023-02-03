FROM php:8.1-fpm-buster

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils \
    && apt-get autoremove -y \
    && apt-get autoclean -y

RUN apt-get install -y build-essential autoconf

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod uga+x /usr/local/bin/install-php-extensions && sync \
    && install-php-extensions \
    bcmath \
    redis \
    pcntl \
    pdo_mysql mysqli \
    xdebug \
    igbinary \
    zip \
    grpc \
    intl \
    gd

# tideway && xhgui
RUN apt-get update \
    && apt-get install $PHPIZE_DEPS git -y \
    && git clone "https://github.com/tideways/php-xhprof-extension.git" \
    && cd php-xhprof-extension \
    && phpize && ./configure  && make && make install \
    && docker-php-ext-enable tideways_xhprof \
    && cd /tmp && rm -rf php-xhprof-extension \
    && apt-get purge $PHPIZE_DEPS git -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y

COPY --from=composer:latest /usr/bin/composer /usr/bin/

COPY ./php.ini $PHP_INI_DIR/conf.d/
RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN apt-get update \
    && apt-get install zip -y \
    && apt-get install unzip -y \
    && apt-get autoremove -y \
    && apt-get autoclean -y
