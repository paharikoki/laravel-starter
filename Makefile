# Laravel Docker Makefile
.PHONY: help build up down restart logs shell composer artisan npm test

# Default target
help: ## Show this help message
	@echo 'Laravel 12 Docker Development Environment'
	@echo '========================================='
	@echo ''
	@echo 'Quick Start:'
	@echo '  ./start-dev.sh                # One-command start (recommended)'
	@echo '  make setup                    # First time setup'
	@echo '  make start                    # Start development mode'
	@echo ''
	@echo 'Development Commands:'
	@echo '  make shell                    # Access container'
	@echo '  make logs                     # View logs'
	@echo '  make stop                     # Stop services'
	@echo '  make fresh                    # Fresh setup (reset everything)'
	@echo ''
	@echo 'All Available Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Docker commands
build: ## Build Docker containers
	docker-compose build

up: ## Start all services
	docker-compose up -d

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## Show logs for all services
	docker-compose logs -f

logs-app: ## Show logs for app service only
	docker-compose logs -f app

logs-nginx: ## Show logs for nginx service only
	docker-compose logs -f nginx

logs-mysql: ## Show logs for mysql service only
	docker-compose logs -f mysql

# Quick development aliases
start: dev ## Alias for 'make dev' - Start development mode
stop: dev-stop ## Alias for 'make dev-stop' - Stop development mode  
fresh: dev-fresh ## Alias for 'make dev-fresh' - Fresh setup
setup: dev-setup ## Alias for 'make dev-setup' - Initial setup
shell: dev-shell ## Alias for 'make dev-shell' - Access container
composer: dev-composer ## Alias for 'make dev-composer' - Install dependencies
artisan: dev-artisan ## Alias for 'make dev-artisan' - Run artisan commands
npm: dev-npm ## Alias for 'make dev-npm' - Install npm dependencies
test: dev-test ## Alias for 'make dev-test' - Run tests
logs: dev-logs ## Alias for 'make dev-logs' - View logs

# Development commands
setup: ## Initial setup (run after first clone)
	./docker-setup.sh

shell: ## Access app container shell
	docker-compose exec app bash

shell-root: ## Access app container as root
	docker-compose exec --user root app bash

mysql-shell: ## Access MySQL shell
	docker-compose exec mysql mysql -u laravel -p laravel

redis-shell: ## Access Redis CLI
	docker-compose exec redis redis-cli

# Laravel commands
composer: ## Run composer install
	docker-compose exec app composer install

composer-update: ## Run composer update
	docker-compose exec app composer update

artisan: ## Run artisan command (usage: make artisan cmd="migrate")
	docker-compose exec app php artisan $(cmd)

migrate: ## Run database migrations
	docker-compose exec app php artisan migrate

migrate-fresh: ## Fresh migrations with seeding
	docker-compose exec app php artisan migrate:fresh --seed

seed: ## Run database seeders
	docker-compose exec app php artisan db:seed

tinker: ## Start Laravel tinker
	docker-compose exec app php artisan tinker

# Frontend commands
npm: ## Run npm install
	docker-compose exec app npm install

npm-dev: ## Run npm dev
	docker-compose exec app npm run dev

npm-build: ## Build assets for production
	docker-compose exec app npm run build

npm-watch: ## Watch assets for changes
	docker-compose exec app npm run dev -- --watch

# Testing
test: ## Run PHPUnit tests
	docker-compose exec app php artisan test

test-coverage: ## Run tests with coverage
	docker-compose exec app php artisan test --coverage

# Cache commands
cache-clear: ## Clear all caches
	docker-compose exec app php artisan cache:clear
	docker-compose exec app php artisan config:clear
	docker-compose exec app php artisan route:clear
	docker-compose exec app php artisan view:clear

cache-optimize: ## Optimize caches for production
	docker-compose exec app php artisan config:cache
	docker-compose exec app php artisan route:cache
	docker-compose exec app php artisan view:cache

# Permissions
permissions: ## Fix storage and bootstrap permissions
	docker-compose exec --user root app chown -R www-data:www-data /var/www/html/storage
	docker-compose exec --user root app chown -R www-data:www-data /var/www/html/bootstrap/cache
	docker-compose exec --user root app chmod -R 755 /var/www/html/storage
	docker-compose exec --user root app chmod -R 755 /var/www/html/bootstrap/cache

fix-composer-permissions: ## Fix composer file permissions
	docker-compose exec --user root app chown www-data:www-data /var/www/html/composer.json
	docker-compose exec --user root app chown www-data:www-data /var/www/html/composer.lock 2>/dev/null || true
	docker-compose exec --user root app chown -R www-data:www-data /var/www/html/vendor 2>/dev/null || true

fix-npm-permissions: ## Fix npm file permissions
	docker-compose exec --user root app chown www-data:www-data /var/www/html/package.json
	docker-compose exec --user root app chown www-data:www-data /var/www/html/package-lock.json 2>/dev/null || true
	docker-compose exec --user root app chown -R www-data:www-data /var/www/html/node_modules 2>/dev/null || true

fix-all-permissions: ## Fix all file permissions
	make fix-composer-permissions
	make fix-npm-permissions
	make permissions

# Development profiles
dev: ## Start with development profile (includes Mailhog)
	docker-compose -f docker-compose.dev.yml up -d

dev-build: ## Build and start development environment
	docker-compose -f docker-compose.dev.yml build
	docker-compose -f docker-compose.dev.yml up -d

dev-setup: ## Complete development setup (first time)
	./dev-setup.sh

dev-logs: ## Show logs for development services
	docker-compose -f docker-compose.dev.yml logs -f

dev-restart: ## Restart development services
	docker-compose -f docker-compose.dev.yml restart

dev-stop: ## Stop development services
	docker-compose -f docker-compose.dev.yml down

dev-fresh: ## Fresh development setup (reset everything)
	docker-compose -f docker-compose.dev.yml down -v
	docker-compose -f docker-compose.dev.yml build --no-cache
	docker volume prune -f
	make dev-build
	make dev-setup

# Development tools
dev-watch: ## Watch for asset changes (runs in background)
	docker-compose -f docker-compose.dev.yml exec app npm run dev -- --watch &

dev-queue: ## Start queue worker for development
	docker-compose -f docker-compose.dev.yml exec app php artisan queue:work --verbose --tries=3 --timeout=90

dev-schedule: ## Run scheduler once (for testing)
	docker-compose -f docker-compose.dev.yml exec app php artisan schedule:run

dev-mailhog: ## Open Mailhog in browser
	@echo "Opening Mailhog at http://localhost:8025"
	@which xdg-open >/dev/null && xdg-open http://localhost:8025 || echo "Please open http://localhost:8025 in your browser"

# Development debugging
dev-xdebug-on: ## Enable Xdebug
	docker-compose -f docker-compose.dev.yml exec app bash -c "echo 'xdebug.mode=debug' >> /usr/local/etc/php/conf.d/xdebug.ini"
	docker-compose -f docker-compose.dev.yml restart app

dev-xdebug-off: ## Disable Xdebug
	docker-compose -f docker-compose.dev.yml exec app bash -c "sed -i '/xdebug.mode=debug/d' /usr/local/etc/php/conf.d/xdebug.ini"
	docker-compose -f docker-compose.dev.yml restart app

dev-php-info: ## Show PHP info
	docker-compose -f docker-compose.dev.yml exec app php -i

dev-php-modules: ## Show installed PHP modules
	docker-compose -f docker-compose.dev.yml exec app php -m

# Development database operations
dev-db-reset: ## Reset database for development
	docker-compose -f docker-compose.dev.yml exec app php artisan migrate:fresh --seed

dev-db-backup: ## Backup development database
	docker-compose -f docker-compose.dev.yml exec mysql mysqldump -u laravel -psecret laravel > backup-$(shell date +%Y%m%d_%H%M%S).sql

dev-db-restore: ## Restore database (usage: make dev-db-restore file=backup.sql)
	docker-compose -f docker-compose.dev.yml exec -T mysql mysql -u laravel -psecret laravel < $(file)

# Development testing
dev-test: ## Run tests in development mode
	docker-compose -f docker-compose.dev.yml exec app php artisan test

dev-test-watch: ## Watch and run tests on file changes
	docker-compose -f docker-compose.dev.yml exec app php artisan test --watch

dev-test-coverage: ## Run tests with coverage report
	docker-compose -f docker-compose.dev.yml exec app php artisan test --coverage --coverage-html=storage/app/coverage

# Development optimization
dev-clear-all: ## Clear all caches for development
	docker-compose -f docker-compose.dev.yml exec app php artisan cache:clear
	docker-compose -f docker-compose.dev.yml exec app php artisan config:clear
	docker-compose -f docker-compose.dev.yml exec app php artisan route:clear
	docker-compose -f docker-compose.dev.yml exec app php artisan view:clear
	docker-compose -f docker-compose.dev.yml exec app composer dump-autoload

dev-optimize: ## Optimize for development (clear caches)
	make dev-clear-all
	docker-compose -f docker-compose.dev.yml exec app php artisan config:cache
	docker-compose -f docker-compose.dev.yml exec app composer dump-autoload -o

# Development shell access
dev-shell: ## Access development app container shell
	docker-compose -f docker-compose.dev.yml exec app bash

dev-shell-root: ## Access development app container as root
	docker-compose -f docker-compose.dev.yml exec --user root app bash

# Development permissions (using dev compose file)
dev-permissions: ## Fix storage and bootstrap permissions in dev
	docker-compose -f docker-compose.dev.yml exec --user root app chown -R www-data:www-data /var/www/html/storage
	docker-compose -f docker-compose.dev.yml exec --user root app chown -R www-data:www-data /var/www/html/bootstrap/cache
	docker-compose -f docker-compose.dev.yml exec --user root app chmod -R 755 /var/www/html/storage
	docker-compose -f docker-compose.dev.yml exec --user root app chmod -R 755 /var/www/html/bootstrap/cache

dev-fix-composer-permissions: ## Fix composer file permissions in dev
	docker-compose -f docker-compose.dev.yml exec --user root app chown www-data:www-data /var/www/html/composer.json
	docker-compose -f docker-compose.dev.yml exec --user root app chown www-data:www-data /var/www/html/composer.lock 2>/dev/null || true
	docker-compose -f docker-compose.dev.yml exec --user root app chown -R www-data:www-data /var/www/html/vendor 2>/dev/null || true

dev-fix-npm-permissions: ## Fix npm file permissions in dev
	docker-compose -f docker-compose.dev.yml exec --user root app chown www-data:www-data /var/www/html/package.json
	docker-compose -f docker-compose.dev.yml exec --user root app chown www-data:www-data /var/www/html/package-lock.json 2>/dev/null || true
	docker-compose -f docker-compose.dev.yml exec --user root app chown -R www-data:www-data /var/www/html/node_modules 2>/dev/null || true

dev-fix-all-permissions: ## Fix all file permissions in dev
	make dev-fix-composer-permissions
	make dev-fix-npm-permissions
	make dev-permissions

# Development Laravel commands
dev-composer: ## Run composer install in development
	docker-compose -f docker-compose.dev.yml exec app composer install --no-interaction

dev-composer-update: ## Run composer update in development
	docker-compose -f docker-compose.dev.yml exec app composer update

dev-artisan: ## Run artisan command in dev (usage: make dev-artisan cmd="migrate")
	docker-compose -f docker-compose.dev.yml exec app php artisan $(cmd)

dev-migrate: ## Run database migrations in dev
	docker-compose -f docker-compose.dev.yml exec app php artisan migrate

dev-migrate-fresh: ## Fresh migrations with seeding in dev
	docker-compose -f docker-compose.dev.yml exec app php artisan migrate:fresh --seed

dev-seed: ## Run database seeders in dev
	docker-compose -f docker-compose.dev.yml exec app php artisan db:seed

dev-tinker: ## Start Laravel tinker in dev
	docker-compose -f docker-compose.dev.yml exec app php artisan tinker

# Development frontend commands
dev-npm: ## Run npm install in development
	docker-compose -f docker-compose.dev.yml exec app npm install

dev-npm-dev: ## Run npm dev in development
	docker-compose -f docker-compose.dev.yml exec app npm run dev

dev-npm-build: ## Build assets for development
	docker-compose -f docker-compose.dev.yml exec app npm run build

dev-npm-watch: ## Watch assets for changes in development
	docker-compose -f docker-compose.dev.yml exec app npm run dev -- --watch

prod: ## Start with production profile (includes queue worker and scheduler)
	docker-compose --profile production up -d

# Cleanup
clean: ## Clean up Docker resources
	docker-compose down -v
	docker system prune -f

reset: ## Reset everything (WARNING: destroys all data)
	docker-compose down -v
	docker-compose build --no-cache
	docker volume prune -f