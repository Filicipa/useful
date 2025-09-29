FROM php:8.2-fpm AS build
RUN apt-get update && apt-get install \
    --no-install-recommends -y \
    git \
    unzip \
    zip \
    libzip-dev \
    nodejs \
    npm && \
    docker-php-ext-install zip mysqli pdo pdo_mysql && \
    rm -rf /var/lib/apt/lists/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html/
COPY ./ ./ 
RUN composer install && \
    apt-get update  && \
    apt-get install --no-install-recommends -y nodejs npm unzip && \
    npm ci && npm run build && \
    php artisan cache:clear && \
    php artisan config:cache && \
    php artisan view:cache && \
    # php artisan route:cache && \
    rm -rf /var/lib/apt/lists/*

FROM php:8.2-fpm-alpine AS run
RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN apk update && \
    apk add --no-cache \
    nginx curl && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /var/www/html/

COPY --from=build /var/www/html/ /var/www/html/
COPY ./nginx/default.conf /etc/nginx/http.d/default.conf
RUN rm -R node_modules && \
    chown -R www-data:www-data /var/www/html

EXPOSE 80

RUN chmod +x start_nginx.sh
ENTRYPOINT ["/var/www/html/start_nginx.sh"]

###
#!/bin/sh
php artisan migrate --force
if [ $? -ne 0 ]; then
echo "Migration failed"
exit 1
fi
php-fpm &
nginx -g 'daemon off;'