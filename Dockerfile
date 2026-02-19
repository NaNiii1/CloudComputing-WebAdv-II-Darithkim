FROM php:8.2-apache

RUN apt-get update && apt-get install -y \
    libpq-dev zip unzip git curl libzip-dev nodejs npm \
    && docker-php-ext-install pdo pdo_pgsql zip

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN npm install && npm run build

RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf \
    && a2enmod rewrite

RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf \
    && sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf

RUN chmod -R 775 storage bootstrap/cache

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

EXPOSE 8080

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

CMD ["apache2-foreground"]