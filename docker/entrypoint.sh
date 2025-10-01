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
    mkdir -p /var/www/html/storage/app/public
    mkdir -p /var/www/html/bootstrap/cache
    mkdir -p /var/www/html/vendor
    mkdir -p /var/www/html/node_modules

    # Set ownership to appuser:appuser for Laravel directories
    chown -R appuser:appuser /var/www/html/storage
    chown -R appuser:appuser /var/www/html/bootstrap/cache
    chown -R appuser:appuser /var/www/html/vendor 2>/dev/null || true
    chown -R appuser:appuser /var/www/html/node_modules 2>/dev/null || true

    # Set proper permissions for Laravel directories
    # Using 775 for directories and 664 for files to ensure group write access
    find /var/www/html/storage -type d -exec chmod 775 {} \; 2>/dev/null || true
    find /var/www/html/storage -type f -exec chmod 664 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type d -exec chmod 775 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type f -exec chmod 664 {} \; 2>/dev/null || true

    # Ensure writable permissions for storage and cache
    chmod -R 775 /var/www/html/storage 2>/dev/null || true
    chmod -R 775 /var/www/html/bootstrap/cache 2>/dev/null || true
    
    # Ensure node_modules is writable for Vite temp files
    if [ -d "/var/www/html/node_modules" ]; then
        chmod -R 775 /var/www/html/node_modules 2>/dev/null || true
    fi

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
    su-exec appuser php artisan key:generate --no-interaction
fi

# Clear Laravel caches to avoid permission issues
if [ -f "/var/www/html/artisan" ]; then
    echo "🧹 Clearing Laravel caches..."
    cd /var/www/html
    su-exec appuser php artisan config:clear 2>/dev/null || true
    su-exec appuser php artisan view:clear 2>/dev/null || true
    su-exec appuser php artisan cache:clear 2>/dev/null || true
fi

# Execute the original command
if [ "$1" = "supervisord" ]; then
    # Start Vite in the background as appuser
    echo "🎨 Starting Vite development server..."
    su-exec appuser sh -c "cd /var/www/html && npm run dev" &
    
    # Start PHP-FPM in the foreground as appuser
    echo "🚀 Starting PHP-FPM..."
    exec php-fpm -F
elif [ "$1" = "php-fpm" ]; then
    echo "🚀 Starting PHP-FPM..."
    # Run PHP-FPM as root, but it will spawn workers as appuser (configured in php-fpm.conf)
    # This allows proper access to file descriptors while workers run as appuser
    exec php-fpm -F
else
    # For other commands, run as appuser
    exec su-exec appuser "$@"
fi
