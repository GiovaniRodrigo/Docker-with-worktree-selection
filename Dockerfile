FROM php:8.3-fpm

WORKDIR /var/www/html

ARG APP

# Dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Extensões PHP
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar aplicação
COPY ./${APP} /var/www/html

# Instala dependências
RUN composer install --ignore-platform-req=ext-intl --ignore-platform-req=ext-zip

# Permissões
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9001
CMD ["php-fpm"]
