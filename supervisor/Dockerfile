FROM php:8.4-fpm AS build

RUN apt-get update && apt-get install \
    --no-install-recommends -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    nodejs \
    npm && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install zip mysqli pdo pdo_mysql gd && \
    rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html/

COPY composer.json composer.lock package.json package-lock.json ./
RUN composer install --no-dev --no-scripts --no-autoloader && npm ci
COPY ./ ./ 
RUN composer dump-autoload --optimize && \
    npm run build

FROM php:8.4-fpm-alpine AS run
# COPY ./nginx/php.ini /usr/local/etc/php/php.ini
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    supervisor \
    nginx curl tzdata && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install mysqli pdo pdo_mysql gd

WORKDIR /var/www/html/

COPY --from=build /var/www/html/ /var/www/html/
COPY ./entrypoint.sh /entrypoint.sh
COPY ./nginx/default.conf /etc/nginx/http.d/default.conf
COPY ./nginx/supervisord.conf /supervisor/supervisord.conf
RUN chown -R www-data:www-data /var/www/html

RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]