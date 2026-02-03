# Food Delivery Application - Deployment Guide

Complete step-by-step guide for deploying the Food Delivery microservices application to production.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Detailed Deployment Steps](#detailed-deployment-steps)
- [SSL/HTTPS Configuration](#sslhttps-configuration)
- [Post-Deployment Verification](#post-deployment-verification)
- [Maintenance Operations](#maintenance-operations)
- [Troubleshooting](#troubleshooting)
- [Security Considerations](#security-considerations)

---

## Prerequisites

### System Requirements

| Requirement | Minimum | Recommended |
|-------------|---------|-------------|
| **OS** | Ubuntu 20.04+ / Debian 11+ | Ubuntu 22.04 LTS |
| **RAM** | 4 GB | 8 GB |
| **CPU** | 2 cores | 4 cores |
| **Disk** | 20 GB | 50 GB |
| **Docker** | 24.0+ | Latest |
| **Docker Compose** | v2.0+ | Latest |

### Domain & DNS Setup

Before deployment, you need:

1. ✅ A registered domain name (e.g., `fooddelivery.ghagevaibhav.xyz`)
2. ✅ DNS A record pointing to your server's public IP
3. ✅ Ports 80 and 443 open in your firewall

```bash
# Verify DNS resolution
dig +short fooddelivery.ghagevaibhav.xyz

# Check your server's public IP
curl ifconfig.me
```

> [!IMPORTANT]
> DNS must be configured BEFORE running SSL setup. SSL certificate generation will fail if the domain doesn't point to your server.

---

## Quick Start

For experienced users, here's the complete deployment in 6 commands:

```bash
# 1. Clone and navigate to project
cd /path/to/CDAC-Food-Delivery

# 2. System setup (run as root/sudo)
sudo ./deploy/setup.sh

# 3. Configure environment
./deploy/configure.sh --interactive

# 4. Build Docker images
./deploy/build.sh

# 5. Deploy services
./deploy/deploy.sh

# 6. Setup SSL (after DNS is configured)
./deploy/setup-ssl.sh --production

# 7. Verify deployment
./deploy/verify.sh
```

---

## Detailed Deployment Steps

### Step 1: System Setup

Run the setup script to prepare your server:

```bash
sudo ./deploy/setup.sh
```

This script will:
- ✅ Detect your operating system
- ✅ Check system resources (RAM, disk, CPU)
- ✅ Install Docker and Docker Compose
- ✅ Configure firewall (ports 80, 443)
- ✅ Create swap space if needed (for low-memory servers)
- ✅ Set up directory structure

**Options:**
```bash
sudo ./deploy/setup.sh --check-only    # Only check, don't install
sudo ./deploy/setup.sh --skip-docker   # Skip Docker installation
sudo ./deploy/setup.sh --skip-firewall # Skip firewall configuration
```

### Step 2: Configure Environment

Configure your deployment settings:

```bash
./deploy/configure.sh --interactive
```

You'll be prompted for:
- **Domain name**: Your website domain (e.g., `fooddelivery.ghagevaibhav.xyz`)
- **SSL email**: Email for Let's Encrypt notifications
- **Passwords**: Auto-generated secure passwords

**Non-interactive mode** (uses defaults or existing .env):
```bash
./deploy/configure.sh
```

**Manual configuration:**
```bash
cp .env.example .env
nano .env
```

Key environment variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `fooddelivery.ghagevaibhav.xyz` |
| `SSL_EMAIL` | Email for SSL certs | `admin@example.com` |
| `MYSQL_ROOT_PASSWORD` | MySQL root password | Auto-generated |
| `JWT_SECRET` | JWT signing secret | Auto-generated |

### Step 3: Build Docker Images

Build all service images:

```bash
./deploy/build.sh
```

**Options:**
```bash
./deploy/build.sh --parallel      # Build all in parallel (default)
./deploy/build.sh --sequential    # Build one at a time
./deploy/build.sh --no-cache      # Rebuild without cache
./deploy/build.sh --service NAME  # Build specific service
./deploy/build.sh --list          # List built images
```

> [!TIP]
> First build takes 10-15 minutes. Subsequent builds are much faster due to caching.

### Step 4: Deploy Services

Deploy all containers:

```bash
./deploy/deploy.sh
```

**Options:**
```bash
./deploy/deploy.sh --build-only  # Only build, don't deploy
./deploy/deploy.sh --no-build    # Deploy without rebuilding
```

The deploy script will:
1. Run pre-flight checks
2. Configure Nginx
3. Build images (if not using --no-build)
4. Start all containers
5. Wait for health checks
6. Display status

### Step 5: Setup SSL (HTTPS)

After services are running and DNS is configured:

```bash
# Test with staging certificate first
./deploy/setup-ssl.sh --staging

# If successful, get production certificate
./deploy/setup-ssl.sh --production
```

**Options:**
```bash
./deploy/setup-ssl.sh --staging     # Test certificate (not trusted)
./deploy/setup-ssl.sh --production  # Real certificate (trusted)
./deploy/setup-ssl.sh --status      # Check certificate status
./deploy/setup-ssl.sh --renew       # Force renewal
```

> [!CAUTION]
> Let's Encrypt has rate limits. You can only request ~5 certificates per week per domain. Always test with `--staging` first!

### Step 6: Verify Deployment

Run comprehensive verification:

```bash
./deploy/verify.sh
```

This checks:
- ✅ All containers are running
- ✅ Frontend is accessible
- ✅ API Gateway is working
- ✅ Internal services are NOT exposed externally
- ✅ SSL certificate is valid
- ✅ Database is connected

---

## Post-Deployment Verification

### Access Your Application

| URL | Description |
|-----|-------------|
| `https://fooddelivery.ghagevaibhav.xyz` | Main website |
| `https://fooddelivery.ghagevaibhav.xyz/api/hotels` | API endpoint |

### Check Container Status

```bash
docker compose -f docker-compose.prod.yml ps
```

### View Logs

```bash
# All services
./deploy/logs.sh

# Specific service
./deploy/logs.sh api-gateway

# Follow logs
./deploy/logs.sh -f auth-service

# View errors only
./deploy/logs.sh --errors
```

### Health Check

```bash
./deploy/health-check.sh --full
```

---

## Maintenance Operations

### Backup Database

```bash
# Full backup
./deploy/backup.sh

# Database only
./deploy/backup.sh --database

# List backups
./deploy/backup.sh --list
```

### Restore Database

```bash
./deploy/backup.sh --restore /path/to/backup.sql.gz
```

### Update Application

```bash
# Pull latest code
git pull origin main

# Rebuild and redeploy
./deploy/build.sh
./deploy/deploy.sh --no-build  # If already built
```

### Restart Services

```bash
# Restart all
docker compose -f docker-compose.prod.yml restart

# Restart specific service
docker compose -f docker-compose.prod.yml restart auth-service
```

### View Resource Usage

```bash
docker stats
```

### Rollback

```bash
# Save state before deployment
./deploy/rollback.sh --save

# Quick rollback if something breaks
./deploy/rollback.sh --quick

# Full restore from saved state
./deploy/rollback.sh --restore

# Restore database from backup
./deploy/rollback.sh --restore-db /path/to/backup.sql.gz
```

---

## Troubleshooting

### Services Won't Start

```bash
# Check container status
docker compose -f docker-compose.prod.yml ps

# Check logs
./deploy/logs.sh --errors

# Check specific service
docker logs auth-service --tail 100
```

### Database Connection Issues

```bash
# Check MySQL is running
docker exec mysql mysqladmin ping -u root -p

# Check databases exist
docker exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### SSL Certificate Issues

```bash
# Check certificate status
./deploy/setup-ssl.sh --status

# Verify DNS
dig +short yourdomain.com

# Test HTTP challenge
curl http://yourdomain.com/.well-known/acme-challenge/test
```

### Memory Issues

```bash
# Check memory usage
free -h
docker stats --no-stream

# Add swap space
sudo ./deploy/setup.sh  # Will add swap if needed
```

### Port Conflicts

```bash
# Check what's using ports
sudo ss -tuln | grep -E ':(80|443) '

# Stop conflicting services
sudo systemctl stop apache2  # Example
```

### Complete Reset

```bash
# ⚠️ WARNING: This deletes ALL data!

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

## Security Considerations

### Network Security

The production configuration ensures:

- ✅ **Only ports 80 and 443 are exposed** to the internet
- ✅ All microservices communicate via internal Docker network
- ✅ Database is NOT accessible from outside the server
- ✅ API Gateway is the only entry point for API requests

### Firewall Rules

```bash
# Verify firewall status
sudo ufw status

# Expected output:
# 22/tcp   ALLOW  (SSH)
# 80/tcp   ALLOW  (HTTP)
# 443/tcp  ALLOW  (HTTPS)
```

### Secret Management

- ✅ Passwords are auto-generated during configuration
- ✅ Secrets are stored in `.env` file (not in git)
- ✅ JWT tokens are used for authentication

> [!WARNING]
> Never commit the `.env` file to version control. It contains sensitive credentials.

### SSL/TLS

- ✅ TLS 1.2 and 1.3 only (older protocols disabled)
- ✅ Strong cipher suites configured
- ✅ HSTS (HTTP Strict Transport Security) enabled
- ✅ Auto-renewal via cron job

---

## File Reference

| File | Purpose |
|------|---------|
| `docker-compose.prod.yml` | Production container orchestration |
| `.env` | Environment variables (secrets) |
| `.env.example` | Environment template |
| `nginx/nginx.conf` | Active Nginx configuration |
| `nginx/nginx.prod.conf.template` | HTTPS Nginx template |
| `nginx/nginx.initial.conf` | HTTP-only config (pre-SSL) |
| `deploy/setup.sh` | System preparation |
| `deploy/configure.sh` | Environment configuration |
| `deploy/build.sh` | Image building |
| `deploy/deploy.sh` | Service deployment |
| `deploy/setup-ssl.sh` | SSL certificate setup |
| `deploy/verify.sh` | Deployment verification |
| `deploy/health-check.sh` | Health monitoring |
| `deploy/backup.sh` | Backup utility |
| `deploy/rollback.sh` | Rollback procedures |
| `deploy/logs.sh` | Log viewer |

---

## Support

For deployment issues:

1. Run `./deploy/verify.sh` for diagnostics
2. Check logs: `./deploy/logs.sh --errors`
3. Review this guide's troubleshooting section
4. Check `ARCHITECTURE.md` for system understanding

---

**Last Updated:** February 2026
