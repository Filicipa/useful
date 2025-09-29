FROM php:7.4-fpm

# Install necessary packages, extensions
RUN apt-get update \
    && curl -sL https://deb.nodesource.com/setup_15.x | bash - \
    && apt-get install -y unzip libxslt1-dev nodejs supervisor nginx \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo_mysql exif xsl bcmath intl mbstring pcntl bcmath gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Set working directory
WORKDIR /var/www/backend
RUN chown -R www-data:www-data /var/www/backend
COPY ./supervisord.conf /supervisor/supervisord.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf
RUN composer install
# Expose port
EXPOSE 80

# Start PHP-FPM
CMD ["supervisord", "-c", "/supervisor/supervisord.conf"]