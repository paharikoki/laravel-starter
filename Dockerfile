# Use PHP 8.3 FPM Alpine for Laravel 12
FROM php:8.3-fpm-alpine

# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    jpeg-dev \
    libc-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    make \
    mysql-client \
    nodejs \
    npm \
    oniguruma-dev \
    postgresql-dev \
    su-exec \
    supervisor \
    zip \
    unzip

# Install PHP extensions required for Laravel
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    exif \
    gd \
    intl \
    mbstring \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pcntl \
    xml \
    zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install Redis extension
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Copy custom PHP configuration
COPY docker/php/php.ini $PHP_INI_DIR/conf.d/laravel.ini

# Configure Composer for better network handling
RUN composer config --global process-timeout 2000 \
    && composer config --global repos.packagist composer https://packagist.org

# Copy composer files first for better Docker layer caching
COPY composer.json composer.lock* ./

# Install dependencies without dev packages for production
# Use --no-scripts to avoid errors if Laravel is not fully copied yet
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts \
    && composer clear-cache

# Copy package.json files for npm
COPY package*.json ./

# Install npm dependencies on production mode
# RUN npm ci --only=productions


# Install npm dependencies on dev mode
RUN npm install

# Create a user with dynamic UID/GID (will be overridden by entrypoint if needed)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup -g ${GROUP_ID} -S appuser && \
    adduser -u ${USER_ID} -S appuser -G appuser -s /bin/sh

# Copy existing application code
COPY . .

# Create entrypoint script for dynamic permission handling
COPY docker/entrypoint-prod.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set proper permissions before running composer scripts
RUN chown -R appuser:appuser /var/www/html \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache \
    && chmod 644 /var/www/html/composer.lock 2>/dev/null || true

# Run composer scripts now that the full application is copied (as appuser)
USER appuser
RUN composer run-script post-autoload-dump --no-interaction

# Build assets (as appuser)
RUN npm run build

# Switch back to root to create directories and set final permissions
USER root

# Create necessary directories and set proper ownership
RUN mkdir -p /var/www/html/storage/logs \
    && mkdir -p /var/www/html/storage/framework/cache \
    && mkdir -p /var/www/html/storage/framework/sessions \
    && mkdir -p /var/www/html/storage/framework/views \
    && chown -R appuser:appuser /var/www/html/storage \
    && chown -R appuser:appuser /var/www/html/bootstrap/cache \
    && chmod -R 755 /var/www/html/storage \
    && chmod -R 755 /var/www/html/bootstrap/cache

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Use entrypoint to handle permissions dynamically
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start PHP-FPM server
CMD ["php-fpm"]
