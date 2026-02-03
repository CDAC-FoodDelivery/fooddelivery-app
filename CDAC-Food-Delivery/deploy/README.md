# Food Delivery Application - Production Deployment Guide

Complete guide for deploying the Food Delivery microservices application to a VM with Docker Compose and SSL/TLS certificates.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [SSL Configuration](#ssl-configuration)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)
- [Architecture](#architecture)

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| OS | Ubuntu 20.04+ / Debian 11+ / RHEL 8+ | Ubuntu 22.04 LTS |
| RAM | 4 GB | 8 GB |
| CPU | 2 cores | 4 cores |
| Disk | 20 GB | 50 GB |
| Docker | 24.0+ | Latest |
| Docker Compose | v2.0+ | Latest |

### Domain & DNS

Before deployment, ensure you have:

1. A registered domain name (e.g., `fooddelivery.example.com`)
2. DNS A record pointing to your server's public IP
3. Ports 80 and 443 open in your firewall

```bash
# Verify DNS resolution
dig +short yourdomain.com

# Check ports are open (run from another machine)
nc -zv your-server-ip 80
nc -zv your-server-ip 443
```

### Firewall Configuration

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw reload

# RHEL/CentOS (firewalld)
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

---

## Quick Start

```bash
# 1. Clone the repository
git clone <repository-url>
cd CDAC-Food-Delivery

# 2. Configure environment
cp .env.example .env
nano .env  # Edit with your values

# 3. Deploy
./deploy/deploy.sh

# 4. Setup SSL (after deployment)
./deploy/setup-ssl.sh --production
```

---

## Detailed Setup

### Step 1: Install Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### Step 2: Configure Environment

```bash
# Copy example configuration
cp .env.example .env

# Edit with your values
nano .env
```

**Required Environment Variables:**

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `fooddelivery.example.com` |
| `SSL_EMAIL` | Email for Let's Encrypt | `admin@example.com` |
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `SecureRootPass123!` |
| `MYSQL_USER` | Application DB user | `fooddelivery_app` |
| `MYSQL_PASSWORD` | Application DB password | `SecureAppPass456!` |
| `JWT_SECRET` | JWT signing key (64 chars) | Run: `openssl rand -hex 32` |

### Step 3: Deploy Application

```bash
# Full deployment (build + deploy)
./deploy/deploy.sh

# Or build only (for CI/CD)
./deploy/deploy.sh --build-only

# Deploy without rebuilding
./deploy/deploy.sh --no-build
```

### Step 4: Configure SSL

```bash
# Test with staging certificate first
./deploy/setup-ssl.sh --staging

# If successful, get production certificate
./deploy/setup-ssl.sh --production
```

### Step 5: Verify Deployment

```bash
# Run health checks
./deploy/health-check.sh

# Check specific components
./deploy/health-check.sh --containers
./deploy/health-check.sh --ssl
```

---

## SSL Configuration

### Initial Setup

The SSL setup uses Let's Encrypt via Certbot. The process:

1. Starts with HTTP-only Nginx configuration
2. Obtains SSL certificate using HTTP-01 challenge
3. Switches to HTTPS Nginx configuration
4. Sets up automatic renewal

### Commands

```bash
# Interactive setup
./deploy/setup-ssl.sh

# Direct commands
./deploy/setup-ssl.sh --staging      # Test certificate (not trusted)
./deploy/setup-ssl.sh --production   # Production certificate
./deploy/setup-ssl.sh --status       # Check certificate status
./deploy/setup-ssl.sh --renew        # Force renewal
```

### Automatic Renewal

The production SSL setup automatically creates a cron job that runs twice daily:

```bash
# View renewal cron job
crontab -l | grep renew

# Manual renewal test
./deploy/deploy/renew-certs.sh
```

---

## Maintenance

### Backup & Restore

```bash
# Full backup (databases + configs)
./deploy/backup.sh

# Database only
./deploy/backup.sh --database

# List backups
./deploy/backup.sh --list

# Restore from backup
./deploy/backup.sh --restore /path/to/backup.sql.gz
```

**Backup location:** `./backups/` (configurable via `BACKUP_DIR` env var)

### Updating the Application

```bash
# Pull latest code
git pull origin main

# Rebuild and redeploy
./deploy/deploy.sh

# Or rebuild specific service
docker compose -f docker-compose.prod.yml build auth-service
docker compose -f docker-compose.prod.yml up -d auth-service
```

### Viewing Logs

```bash
# All services
docker compose -f docker-compose.prod.yml logs -f

# Specific service
docker compose -f docker-compose.prod.yml logs -f api-gateway

# Last 100 lines
docker compose -f docker-compose.prod.yml logs --tail 100 auth-service
```

### Restarting Services

```bash
# Restart all
docker compose -f docker-compose.prod.yml restart

# Restart specific service
docker compose -f docker-compose.prod.yml restart hotel-service

# Full stop and start
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d
```

---

## Troubleshooting

### Common Issues

#### Services Won't Start

```bash
# Check container status
docker compose -f docker-compose.prod.yml ps

# Check logs for errors
docker compose -f docker-compose.prod.yml logs --tail 50

# Verify .env file
cat .env | grep -v "^#" | grep -v "^$"
```

#### Database Connection Failed

```bash
# Check MySQL is running
docker exec fooddelivery-mysql mysqladmin ping -uroot -p

# Check databases exist
docker exec -it fooddelivery-mysql mysql -uroot -p -e "SHOW DATABASES;"

# View MySQL logs
docker logs fooddelivery-mysql
```

#### SSL Certificate Issues

```bash
# Check certificate status
./deploy/setup-ssl.sh --status

# Verify DNS points to this server
curl ifconfig.me  # Your server IP
dig +short yourdomain.com  # Should match

# Check Nginx config
docker exec nginx-proxy nginx -t

# Test HTTP challenge accessibility
curl http://yourdomain.com/.well-known/acme-challenge/test
```

#### Service Discovery Issues

```bash
# Check Eureka dashboard
curl http://localhost:8761

# Verify services are registered
curl http://localhost:8761/eureka/apps
```

#### Memory Issues

```bash
# Check resource usage
docker stats

# Increase limits in .env
MYSQL_MEMORY_LIMIT=1g
SERVICE_MEMORY_LIMIT=512m
```

### Health Check Commands

```bash
# Full health report
./deploy/health-check.sh --full

# Individual checks
./deploy/health-check.sh --containers
./deploy/health-check.sh --endpoints
./deploy/health-check.sh --database
./deploy/health-check.sh --ssl
./deploy/health-check.sh --resources
```

### Nuclear Option (Complete Reset)

```bash
# ⚠️ WARNING: This will delete ALL data!

# Stop and remove everything
docker compose -f docker-compose.prod.yml down -v

# Remove all images
docker compose -f docker-compose.prod.yml down --rmi all

# Clean Docker system
docker system prune -af

# Redeploy from scratch
./deploy/deploy.sh
```

---

## Architecture

### Services

| Service | Port | Technology | Database |
|---------|------|------------|----------|
| Nginx Proxy | 80, 443 | Nginx Alpine | - |
| Discovery Server | 8761 | Spring Cloud Eureka | - |
| API Gateway | 8080 | Spring Cloud Gateway | - |
| Auth Service | 9081 | Spring Boot | fooddelivery_auth |
| Hotel Service | 9082 | Spring Boot | fooddelivery_hotel |
| Menu Service | 9083 | Spring Boot | fooddelivery_menu |
| Admin/Rider Service | 9086 | ASP.NET Core 8 | fooddelivery_admin_rider |
| Frontend | 3000 | React + Nginx | - |
| MySQL | 3306 | MySQL 8.0 | - |

### Traffic Flow

```
Internet → Nginx (SSL) → Frontend (React)
                      → API Gateway → Microservices → MySQL
```

### Volumes

| Volume | Purpose |
|--------|---------|
| `fooddelivery-mysql-data` | MySQL database persistence |
| `fooddelivery-certbot-www` | Let's Encrypt challenge files |
| `fooddelivery-certbot-certs` | SSL certificates |

---

## File Structure

```
CDAC-Food-Delivery/
├── .env.example              # Environment template
├── .env                      # Your configuration (not in git)
├── docker-compose.prod.yml   # Production compose file
├── init-databases.sql        # Database initialization
├── nginx/
│   ├── nginx.initial.conf    # HTTP-only config (pre-SSL)
│   ├── nginx.prod.conf.template  # HTTPS config template
│   └── nginx.conf            # Active config (generated)
├── deploy/
│   ├── deploy.sh             # Main deployment script
│   ├── setup-ssl.sh          # SSL certificate setup
│   ├── backup.sh             # Backup utility
│   ├── health-check.sh       # Health monitoring
│   └── renew-certs.sh        # Certificate auto-renewal
└── backend/                  # Application source code
    ├── discovery-server/
    ├── api-gateway/
    ├── AuthService/
    ├── fooddelivery_backend/
    ├── Menu-backend/
    └── AdminRiderService/
```

---

## Support

For issues with this deployment:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review container logs: `docker compose -f docker-compose.prod.yml logs`
3. Run health check: `./deploy/health-check.sh`

---

**Last Updated:** February 2026
