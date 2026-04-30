# PHP image for the dev stack — mirrors appliceo-php/docker/php/Dockerfile but
# deliberately skips composer. Vendor packages live committed in
# appliceo-php/bin/vendor/, so running composer install would fight (or
# overwrite) that committed tree.
#
# Build context (set by docker-compose) is ./appliceo-php so `COPY .` brings in
# the PHP source plus its docker/ assets (php.ini, entrypoint).

FROM php:8.2-fpm

# System deps
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libgd-dev \
    libicu-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        mysqli \
        mbstring \
        exif \
        pcntl \
        bcmath \
        gd \
        zip \
        intl

WORKDIR /var/www/html

# App source (committed bin/vendor/ comes along — no composer needed).
COPY . /var/www/html

# Permissions
RUN mkdir -p /var/www/html/gestion/uploads \
    && mkdir -p /var/www/html/gestion/logs \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/gestion/uploads \
    && chmod -R 777 /var/www/html/gestion/logs

# Reuse appliceo-php's php.ini + entrypoint (paths relative to build context).
COPY docker/php/php.ini /usr/local/etc/php/conf.d/custom.ini
COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
