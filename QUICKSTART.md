# Laravel Docker Starter 🚀

A ready-to-use Laravel starter project with Docker that works seamlessly across different machines and projects without any configuration.

## 🎯 One Command Setup

```bash
./start.sh
```

That's it! This single command will:
- ✅ Detect your system's user permissions automatically
- ✅ Set up all Docker containers (Laravel, MySQL, Redis, Nginx, Mailhog)
- ✅ Install all dependencies (Composer & NPM)
- ✅ Configure Laravel (generate keys, run migrations)
- ✅ Build frontend assets
- ✅ Fix all permissions automatically
- ✅ Start your application

## 🌐 Access Your Application

After running `./start.sh`, your application will be available at:
- **Laravel App**: http://localhost
- **Mailhog (email testing)**: http://localhost:8025

## 📋 Requirements

- Docker
- Docker Compose
- Git

## 🔧 For New Projects

1. **Clone this repository**:
   ```bash
   git clone <this-repo-url> my-new-project
   cd my-new-project
   ```

2. **Start developing**:
   ```bash
   ./start.sh
   ```

3. **That's it!** Start coding your Laravel application.

## 📝 Useful Commands

### Quick Commands
```bash
./start.sh              # Complete setup (run once)
docker-compose up -d     # Start services
docker-compose down      # Stop services
```

### Development Commands (via Makefile)
```bash
make shell              # Access app container
make logs               # View all logs  
make migrate            # Run migrations
make test               # Run tests
make npm-watch          # Watch frontend assets
make cache-clear        # Clear all caches
```

### Direct Docker Commands
```bash
docker-compose exec app bash                    # Access container
docker-compose exec app php artisan tinker      # Laravel tinker
docker-compose exec app php artisan migrate     # Run migrations
docker-compose logs app                         # View app logs
```

## 🛠️ Project Structure

```
├── app/                    # Laravel application
├── docker/                 # Docker configuration files
│   ├── nginx/             # Nginx configuration
│   ├── php/               # PHP-FPM configuration
│   ├── mysql/             # MySQL configuration
│   └── entrypoint*.sh     # Startup scripts
├── docker-compose.yml     # Docker services
├── Dockerfile             # Production container
├── Dockerfile.dev         # Development container
├── start.sh              # One-command setup script
└── .env.docker           # Environment template
```

## 🔄 For Different Machines

This starter is designed to work across different machines without any configuration:

1. **Copy your project** to a new machine
2. **Run** `./start.sh`
3. **Start coding** - all permissions and configurations are handled automatically

## 🐛 Troubleshooting

### Permission Issues
The starter automatically handles permissions, but if you encounter issues:
```bash
docker-compose exec app chown -R appuser:appuser /var/www/html/storage
docker-compose exec app chmod -R 755 /var/www/html/storage
```

### Reset Everything
```bash
docker-compose down -v
docker system prune -f
./start.sh
```

### View Logs
```bash
docker-compose logs app     # Application logs
docker-compose logs nginx   # Web server logs
docker-compose logs mysql   # Database logs
```

## 🎨 Customization

### Change Project Name
1. Update `APP_NAME` in `.env`
2. Update container names in `docker-compose.yml` if needed

### Add Dependencies
```bash
# PHP dependencies
docker-compose exec app composer require package-name

# NPM dependencies  
docker-compose exec app npm install package-name
```

### Environment Variables
Edit `.env` file for your specific configuration needs.

## 📦 What's Included

- **Laravel 12** with PHP 8.3
- **MySQL 8.0** database
- **Redis** for caching and sessions
- **Nginx** web server
- **Mailhog** for email testing
- **Node.js** for asset compilation
- **Xdebug** ready for debugging
- **Automatic permission handling**
- **One-command setup**

## 🚀 Happy Coding!

This starter is designed to get you coding immediately without any Docker or permission headaches. Focus on building your amazing Laravel application!

---

**Need help?** Check the logs with `docker-compose logs app` or open an issue in this repository.