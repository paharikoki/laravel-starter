#!/bin/bash

# Quick Laravel Development Start Script
echo "🚀 Starting Laravel development environment..."

# Check if we need to do initial setup
if [ ! -f .env ] || [ ! -d vendor ] || [ ! -d node_modules ]; then
    echo "📋 First time setup detected. Running full setup..."
    make setup
else
    echo "📋 Environment exists. Starting services..."
    make start
fi

echo ""
echo "✅ Development environment is ready!"
echo ""
echo "🌐 Application: http://localhost"
echo "📧 Mailhog: http://localhost:8025"
echo ""
echo "🔧 Quick commands:"
echo "  make shell      # Access container"
echo "  make logs       # View logs"
echo "  make stop       # Stop services"
echo "  make restart    # Restart services"