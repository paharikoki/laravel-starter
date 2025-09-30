#!/bin/bash
set -e

# Function to fix permissions dynamically
fix_permissions() {
    echo "🔧 Fixing permissions for Laravel application..."
    
    # Ensure Laravel directories exist
    mkdir -p /var/www/html/storage/logs
    mkdir -p /var/www/html/storage/framework/cache
    mkdir -p /var/www/html/storage/framework/sessions
    mkdir -p /var/www/html/storage/framework/views
    mkdir -p /var/www/html/bootstrap/cache
    
    # Set proper ownership and permissions for Laravel directories
    chown -R appuser:appuser /var/www/html/storage
    chown -R appuser:appuser /var/www/html/bootstrap/cache
    
    # Set permissions for directories (755) and files (644)
    find /var/www/html/storage -type d -exec chmod 755 {} \; 2>/dev/null || true
    find /var/www/html/storage -type f -exec chmod 644 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type d -exec chmod 755 {} \; 2>/dev/null || true
    find /var/www/html/bootstrap/cache -type f -exec chmod 644 {} \; 2>/dev/null || true
    
    # Ensure writable permissions for storage and cache
    chmod -R 755 /var/www/html/storage
    chmod -R 755 /var/www/html/bootstrap/cache
    
    echo "✅ Permissions fixed!"
}

# Fix permissions on startup
fix_permissions

# Switch to appuser and execute the command
if [ "$1" = "php-fpm" ]; then
    echo "🚀 Starting PHP-FPM as appuser..."
    exec su-exec appuser php-fpm -F
else
    exec su-exec appuser "$@"
fi