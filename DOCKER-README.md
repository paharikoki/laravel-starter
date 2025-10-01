# Laravel 12 Docker Setup

A complete Docker environment for Laravel 12 with PHP-FPM on Alpine, Nginx Alpine, and MySQL.

## 🚀 Quick Start

### Development Mode
```bash
./dev
```

### Production Mode
```bash
./prod
```

### Vite Hot Reload (after starting dev)
```bash
make vite
```

## 📦 Services

- **app**: PHP 8.3-FPM on Alpine with Laravel 12 + Vite (Port 5173)
- **nginx**: Nginx on Alpine (Port 80)
- **mysql**: MySQL 8.0 (Port 3306)
- **redis**: Redis on Alpine (Port 6379)
- **mailhog**: Email testing (Ports 1025/8025) - Development only

## 🛠️ Available Commands

```bash
make dev       # Start development environment
make prod      # Start production environment
make stop      # Stop all services
make shell     # Access app container
make logs      # View all logs
make vite      # Start Vite hot reload

# Laravel commands
make artisan cmd="migrate"  # Run artisan commands
make migrate               # Run migrations
make cache-clear          # Clear all caches
```

## 🔧 URLs

- **Laravel App**: http://localhost
- **Mailhog (Email testing)**: http://localhost:8025
- **Vite Dev Server**: http://localhost:5173 (when running `make vite`)

## 📁 Project Structure

```
├── docker/
│   ├── nginx/
│   │   └── default.conf      # Nginx configuration
│   ├── php/
│   │   ├── php.ini           # PHP configuration
│   │   └── xdebug.ini        # Xdebug configuration
│   └── mysql/
│       └── my.cnf            # MySQL configuration
├── .env.docker               # Docker environment template
├── docker-compose.yml        # Main Docker compose file
├── Dockerfile                # Production Dockerfile
├── Dockerfile.dev            # Development Dockerfile
├── docker-setup.sh           # Initial setup script
└── Makefile                  # Convenient commands
```

## ⚙️ Configuration

### Environment Variables
Copy `.env.docker` to `.env` and adjust as needed:

```bash
# Database
DB_HOST=mysql
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=secret

# Cache & Sessions
CACHE_STORE=redis
SESSION_DRIVER=redis
REDIS_HOST=redis

# Mail (Development)
MAIL_HOST=mailhog
MAIL_PORT=1025
```

### PHP Configuration
Located in `docker/php/php.ini`:
- Memory limit: 512M
- Upload limit: 100M
- OPcache enabled
- Redis session storage

### MySQL Configuration
Located in `docker/mysql/my.cnf`:
- UTF8MB4 character set
- Optimized for Laravel
- InnoDB optimizations

### Nginx Configuration
Located in `docker/nginx/default.conf`:
- Optimized for Laravel
- Gzip compression
- Security headers
- Static asset caching

## 🔍 Debugging

### Xdebug Setup (Development)
1. Use `Dockerfile.dev` for development
2. Configure your IDE to listen on port 9003
3. Set breakpoints and debug!

### Logs
```bash
make logs-app         # Application logs
make logs-nginx       # Nginx logs
make logs-mysql       # MySQL logs
```

### Container Access
```bash
make shell            # App container
make mysql-shell      # MySQL CLI
make redis-shell      # Redis CLI
```

## 🧪 Testing

```bash
make test             # Run PHPUnit tests
make test-coverage    # Run with coverage
```

## 📧 Email Testing

Mailhog is included for development:
- SMTP: localhost:1025
- Web UI: http://localhost:8025

## 🔒 Security

### Production Considerations
- Change default passwords
- Use environment-specific `.env` files
- Enable HTTPS with SSL certificates
- Configure firewall rules
- Regular security updates

### File Permissions
```bash
make permissions      # Fix storage permissions
```

## 🚨 Troubleshooting

### Common Issues

1. **Permission denied on storage**:
   ```bash
   make permissions
   ```

2. **MySQL connection refused**:
   ```bash
   make logs-mysql
   # Wait for MySQL to fully start
   ```

3. **Composer dependencies issues**:
   ```bash
   make shell
   composer install --no-cache
   ```

4. **Asset compilation failures**:
   ```bash
   make npm
   make npm-build
   ```

### Reset Everything
```bash
make reset            # ⚠️  WARNING: Destroys all data!
```

## 📝 Notes

- First startup may take a few minutes to download images
- MySQL data persists in Docker volumes
- Redis data persists in Docker volumes
- For production, use proper SSL certificates
- Monitor resource usage in production environments

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is open-sourced software licensed under the [MIT license](LICENSE).