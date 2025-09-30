#!/bin/bash

echo "🔧 Setting up Laravel permissions for Docker development..."

# Ensure Laravel directories exist
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions  
mkdir -p storage/framework/views
mkdir -p storage/app/public
mkdir -p bootstrap/cache

# Set proper permissions (775 for directories, 664 for files)
echo "📁 Setting directory permissions..."
find storage -type d -exec chmod 775 {} \;
find storage -type f -exec chmod 664 {} \;
find bootstrap/cache -type d -exec chmod 775 {} \;
find bootstrap/cache -type f -exec chmod 664 {} \;

# Make sure storage and bootstrap/cache are fully writable
chmod -R 775 storage
chmod -R 775 bootstrap/cache

echo "✅ Permissions setup complete!"
echo "ℹ️  You can now run: docker-compose -f docker-compose.dev.yml up -d"