#!/bin/bash

# Laravel Docker Setup Script
echo "🚀 Setting up Laravel Docker environment..."

# Copy environment file
if [ ! -f .env ]; then
    echo "📄 Copying .env.docker to .env..."
    cp .env.docker .env
else
    echo "⚠️  .env file already exists, skipping copy"
fi

# Generate application key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating application key..."
    docker-compose exec app php artisan key:generate
fi

# Install dependencies
echo "📦 Installing Composer dependencies..."
docker-compose exec app composer install

# Install NPM dependencies
echo "📦 Installing NPM dependencies..."
docker-compose exec app npm install

# Run migrations
echo "🗄️  Running database migrations..."
docker-compose exec app php artisan migrate --force

# Seed database (optional)
read -p "Do you want to run database seeders? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌱 Running database seeders..."
    docker-compose exec app php artisan db:seed
fi

# Build assets
echo "🎨 Building frontend assets..."
docker-compose exec app npm run build

# Set proper permissions
echo "🔧 Setting proper permissions..."
docker-compose exec app chown -R www-data:www-data /var/www/html/storage
docker-compose exec app chown -R www-data:www-data /var/www/html/bootstrap/cache
docker-compose exec app chmod -R 755 /var/www/html/storage
docker-compose exec app chmod -R 755 /var/www/html/bootstrap/cache

# Clear and cache config
echo "⚡ Optimizing Laravel..."
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

echo "✅ Laravel Docker setup complete!"
echo "🌐 Your application is available at: http://localhost"
echo "📧 Mailhog (email testing) is available at: http://localhost:8025"
echo ""
echo "📝 Useful commands:"
echo "  docker-compose up -d              # Start all services"
echo "  docker-compose down               # Stop all services"
echo "  docker-compose exec app bash      # Access app container"
echo "  docker-compose exec app php artisan tinker  # Laravel tinker"
echo "  docker-compose logs app           # View app logs"