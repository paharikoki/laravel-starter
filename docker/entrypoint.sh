#!/bin/bash
set -e

# Function to fix permissions
fix_permissions() {
    echo "🔧 Fixing permissions for Laravel development..."
    
    # Ensure Laravel directories exist
    mkdir -p /var/www/html/storage/logs
    mkdir -p /var/www/html/storage/framework/cache
    mkdir -p /var/www/html/storage/framework/sessions
    mkdir -p /var/www/html/storage/framework/views
    mkdir -p /var/www/html/bootstrap/cache
    mkdir -p /var/www/html/vendor
    mkdir -p /var/www/html/node_modules
    
    # Set proper permissions for Laravel directories
    # Since we're running as the host user (1000:1000), the files will have the correct ownership
    find /var/www/html/storage -type d -exec chmod 755 {} \; 2>/dev/null || true
    find /var/www/html/storage -type f -exec chmod 644 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type d -exec chmod 755 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    # Make sure the working directory is accessible
    chmod 755 /var/www/html 2>/dev/null || true
    
    echo "✅ Permissions fixed!"
}

# Fix permissions on startup
fix_permissions

# Wait for services to be ready (if in development)
if [ -n "$WAIT_FOR_MYSQL" ]; then
    echo "⏳ Waiting for MySQL to be ready..."
    while ! nc -z mysql 3306; do
        sleep 1
    done
    echo "✅ MySQL is ready!"
fi

# Install composer dependencies if composer.json exists and vendor directory is missing or empty
if [ -f "/var/www/html/composer.json" ] && [ ! -d "/var/www/html/vendor" ]; then
    echo "📦 Installing Composer dependencies..."
    cd /var/www/html
    composer install --no-interaction --optimize-autoloader
fi

# Install npm dependencies if package.json exists and node_modules is missing or empty
if [ -f "/var/www/html/package.json" ] && [ ! -d "/var/www/html/node_modules" ]; then
    echo "📦 Installing NPM dependencies..."
    cd /var/www/html
    npm install
fi

# Generate Laravel app key if .env exists but no key is set
if [ -f "/var/www/html/.env" ] && ! grep -q "APP_KEY=base64:" /var/www/html/.env; then
    echo "🔑 Generating Laravel application key..."
    cd /var/www/html
    php artisan key:generate --no-interaction
fi

# Execute the original command
if [ "$1" = "php-fpm" ]; then
    echo "🚀 Starting PHP-FPM..."
    exec php-fpm -F
else
    exec "$@"
fi