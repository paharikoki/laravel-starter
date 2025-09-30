#!/bin/bash

# Laravel Docker Starter - One Command Setup
# This script sets up a complete Laravel development environment
echo "🚀 Starting Laravel Docker Environment..."
echo "📋 This will set up everything automatically - no configuration needed!"

# Function to detect host user ID
detect_user_id() {
    echo "🔍 Detecting host user information..."
    export USER_ID=$(id -u)
    export GROUP_ID=$(id -g)
    echo "   Host User ID: $USER_ID"
    echo "   Host Group ID: $GROUP_ID"
}

# Function to copy environment file
setup_env() {
    if [ ! -f .env ]; then
        echo "📄 Creating .env file..."
        cp .env.docker .env
        echo "✅ Environment file created"
    else
        echo "⚠️  .env file already exists, skipping copy"
    fi
}

# Function to start services
start_services() {
    echo "🏗️  Building and starting Docker containers..."
    echo "   This may take a few minutes on first run..."
    
    # Export user IDs for docker-compose
    export USER_ID GROUP_ID
    
    # Stop any existing containers
    docker-compose down 2>/dev/null || true
    
    # Build and start
    docker-compose up -d --build
    
    echo "✅ Docker containers started"
}

# Function to wait for services
wait_for_services() {
    echo "⏳ Waiting for services to be ready..."
    
    # Wait for MySQL
    until docker-compose exec mysql mysqladmin ping -h"localhost" --silent 2>/dev/null; do
        echo "   Waiting for MySQL..."
        sleep 2
    done
    
    echo "✅ All services are ready"
}

# Function to setup Laravel
setup_laravel() {
    echo "📦 Setting up Laravel application..."
    
    # Install composer dependencies
    echo "   Installing Composer dependencies..."
    docker-compose exec app composer install --no-interaction
    
    # Generate app key if not set
    if ! grep -q "APP_KEY=base64:" .env; then
        echo "   Generating application key..."
        docker-compose exec app php artisan key:generate --no-interaction
    fi
    
    # Run migrations
    echo "   Running database migrations..."
    docker-compose exec app php artisan migrate --force
    
    # Install npm dependencies and build assets
    echo "   Installing NPM dependencies and building assets..."
    docker-compose exec app npm install
    docker-compose exec app npm run build
    
    # Clear and optimize Laravel
    echo "   Optimizing Laravel..."
    docker-compose exec app php artisan config:cache
    docker-compose exec app php artisan route:cache
    docker-compose exec app php artisan view:cache
    
    echo "✅ Laravel setup complete"
}

# Function to fix permissions (final check)
fix_final_permissions() {
    echo "🔧 Final permission check..."
    docker-compose exec app chown -R appuser:appuser /var/www/html/storage
    docker-compose exec app chown -R appuser:appuser /var/www/html/bootstrap/cache
    docker-compose exec app chmod -R 755 /var/www/html/storage
    docker-compose exec app chmod -R 755 /var/www/html/bootstrap/cache
    echo "✅ Permissions verified"
}

# Function to show completion message
show_completion() {
    echo ""
    echo "🎉 Laravel Docker Environment Ready!"
    echo ""
    echo "📱 Your application is available at:"
    echo "   🌐 Laravel App: http://localhost"
    echo "   📧 Mailhog (email testing): http://localhost:8025"
    echo ""
    echo "📝 Useful commands:"
    echo "   docker-compose up -d              # Start services"
    echo "   docker-compose down               # Stop services"
    echo "   docker-compose exec app bash      # Access app container"
    echo "   docker-compose exec app php artisan tinker  # Laravel tinker"
    echo "   docker-compose logs app           # View app logs"
    echo ""
    echo "🛠️  Quick commands via Makefile:"
    echo "   make shell       # Access container"
    echo "   make logs        # View logs"
    echo "   make migrate     # Run migrations"
    echo "   make test        # Run tests"
    echo ""
    echo "🚀 Happy coding!"
}

# Main execution
main() {
    detect_user_id
    setup_env
    start_services
    wait_for_services
    setup_laravel
    fix_final_permissions
    show_completion
}

# Error handling
set -e
trap 'echo "❌ Setup failed. Check the error above and try again."' ERR

# Run main function
main