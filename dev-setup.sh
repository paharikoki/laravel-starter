#!/bin/bash

# Laravel Docker Development Setup
echo "🚀 Setting up Laravel Docker development environment..."

# Stop any existing containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.dev.yml down

# Build the development image
echo "🏗️  Building development containers..."
docker-compose -f docker-compose.dev.yml build

# Start the services
echo "▶️  Starting services..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for MySQL to be ready
echo "⏳ Waiting for MySQL to be ready..."
until docker-compose -f docker-compose.dev.yml exec mysql mysqladmin ping -h"localhost" --silent; do
    echo "Waiting for MySQL..."
    sleep 2
done

# Copy environment file if it doesn't exist
if [ ! -f .env ]; then
    echo "📄 Creating .env file from .env.docker..."
    cp .env.docker .env
fi

# Fix initial permissions
echo "🔧 Fixing initial permissions..."
make dev-fix-all-permissions

# Install composer dependencies
echo "📦 Installing Composer dependencies..."
docker-compose -f docker-compose.dev.yml exec app composer install --no-interaction

# Generate app key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating application key..."
    docker-compose -f docker-compose.dev.yml exec app php artisan key:generate
fi

# Install npm dependencies
echo "📦 Installing NPM dependencies..."
docker-compose -f docker-compose.dev.yml exec app npm install

# Run migrations
echo "🗄️  Running database migrations..."
docker-compose -f docker-compose.dev.yml exec app php artisan migrate --force

# Seed database (optional)
read -p "Do you want to run database seeders? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🌱 Running database seeders..."
    docker-compose -f docker-compose.dev.yml exec app php artisan db:seed
fi

# Build assets
echo "🎨 Building frontend assets..."
docker-compose -f docker-compose.dev.yml exec app npm run build

# Final permission fix
echo "🔧 Final permission adjustments..."
make dev-permissions

echo ""
echo "✅ Laravel Docker development setup complete!"
echo ""
echo "🌐 Your application is available at: http://localhost"
echo "📧 Mailhog (email testing) is available at: http://localhost:8025"
echo ""
echo "📝 Useful commands:"
echo "  make start                    # Start all services"
echo "  make stop                     # Stop all services"
echo "  make shell                    # Access app container"
echo "  make logs                     # View logs"
echo "  make dev-fix-all-permissions  # Fix permissions if needed"
echo "  make composer                 # Install composer dependencies"
echo "  make artisan cmd=\"migrate\"    # Run artisan commands"