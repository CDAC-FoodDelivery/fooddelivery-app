# Food Delivery App - DigitalOcean Deployment Guide

Complete step-by-step guide to deploy the Food Delivery application on a DigitalOcean Droplet with SSL.

---

## 📋 Droplet Configuration

### Recommended Specifications

| Component | Minimum | Recommended | Production |
|-----------|---------|-------------|------------|
| **Plan** | Basic | Basic | General Purpose |
| **CPU** | 2 vCPUs | 4 vCPUs | 4 vCPUs |
| **RAM** | 4 GB | 8 GB | 16 GB |
| **Storage** | 80 GB SSD | 160 GB SSD | 320 GB SSD |
| **Monthly Cost** | ~$24/mo | ~$48/mo | ~$96/mo |

### Why These Specs?

- **MySQL**: Needs 512MB-1GB RAM minimum
- **5 Spring Boot Services**: ~300MB each = 1.5GB
- **1 .NET Service**: ~200MB
- **Nginx + Frontend**: ~100MB
- **OS Overhead**: ~500MB
- **Build Process**: Needs extra RAM during `docker compose build`

> 💡 **Tip**: Start with 4GB ($24/mo) for testing, upgrade to 8GB for production.

---

## 🚀 Step-by-Step Deployment

### Phase 1: Create DigitalOcean Droplet

#### Step 1.1: Log into DigitalOcean
1. Go to [cloud.digitalocean.com](https://cloud.digitalocean.com)
2. Click **Create** → **Droplets**

#### Step 1.2: Configure Droplet

| Setting | Value |
|---------|-------|
| **Region** | Choose closest to your users (e.g., `BLR1` for India) |
| **Image** | **Ubuntu 22.04 (LTS) x64** |
| **Droplet Type** | Basic (Shared CPU) |
| **CPU Options** | Regular SSD |
| **Size** | **4 GB / 2 CPUs / 80 GB SSD** (or 8 GB for production) |
| **Authentication** | SSH Key (recommended) or Password |
| **Hostname** | `fooddelivery-prod` |

#### Step 1.3: Add SSH Key (Recommended)

```bash
# On your local machine, generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy the public key
cat ~/.ssh/id_ed25519.pub
```

Paste this in DigitalOcean when creating the droplet.

#### Step 1.4: Create Droplet
Click **Create Droplet** and wait ~60 seconds for it to be ready.

---

### Phase 2: Initial Server Setup

#### Step 2.1: Connect to Your Droplet

```bash
# Connect via SSH (replace with your droplet IP)
ssh root@YOUR_DROPLET_IP
```

#### Step 2.2: Update System

```bash
# Update package lists and upgrade
apt update && apt upgrade -y

# Install essential packages
apt install -y curl wget git nano ufw
```

#### Step 2.3: Configure Firewall

```bash
# Allow SSH, HTTP, and HTTPS
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable

# Verify
ufw status
```

#### Step 2.4: Create Non-Root User (Best Practice)

```bash
# Create a new user
adduser deploy

# Add to sudo group
usermod -aG sudo deploy

# Copy SSH keys to new user
rsync --archive --chown=deploy:deploy ~/.ssh /home/deploy

# Test login in a new terminal
ssh deploy@YOUR_DROPLET_IP
```

---

### Phase 3: Install Docker

#### Step 3.1: Install Docker Engine

```bash
# Run as deploy user
sudo -i

# Install Docker
curl -fsSL https://get.docker.com | sh

# Add deploy user to docker group
usermod -aG docker deploy

# Exit and reconnect to apply group changes
exit
```

Reconnect as the deploy user:
```bash
ssh deploy@YOUR_DROPLET_IP
```

#### Step 3.2: Verify Docker Installation

```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker compose version

# Test Docker works without sudo
docker run hello-world
```

---

### Phase 4: Deploy Application

#### Step 4.1: Clone Repository

```bash
# Create app directory
mkdir -p ~/apps
cd ~/apps

# Clone your repository
git clone https://github.com/YOUR_USERNAME/CDAC-Food-Delivery.git
cd CDAC-Food-Delivery
```

Or upload the code:
```bash
# From your local machine
scp -r ./CDAC-Food-Delivery deploy@YOUR_DROPLET_IP:~/apps/
```

#### Step 4.2: Configure Environment

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

**Required Changes in `.env`:**

```bash
# Your domain (must match DNS later)
DOMAIN=fooddelivery.yourdomain.com
SSL_EMAIL=your_email@example.com

# Generate secure passwords
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)
MYSQL_PASSWORD=$(openssl rand -base64 24)

# Generate JWT secret
JWT_SECRET=$(openssl rand -hex 32)
```

**Quick way to generate secure values:**
```bash
# Generate and show secure passwords
echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 24)"
echo "MYSQL_PASSWORD=$(openssl rand -base64 24)"
echo "JWT_SECRET=$(openssl rand -hex 32)"
echo "ADMIN_JWT_KEY=$(openssl rand -base64 32)"
```

Copy these values into your `.env` file.

#### Step 4.3: Run Deployment

```bash
# Make scripts executable (if not already)
chmod +x deploy/*.sh

# Run deployment
./deploy/deploy.sh
```

This will:
1. Check prerequisites
2. Build all Docker images (~10-15 minutes first time)
3. Start all services
4. Wait for health checks

#### Step 4.4: Verify Services Running

```bash
# Check container status
docker compose -f docker-compose.prod.yml ps

# Run health check
./deploy/health-check.sh
```

---

### Phase 5: Configure Domain & DNS

#### Step 5.1: Get Droplet IP

```bash
# On the droplet
curl ifconfig.me
```

#### Step 5.2: Configure DNS (in your domain registrar)

Add these DNS records:

| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | `@` | `YOUR_DROPLET_IP` | 300 |
| A | `www` | `YOUR_DROPLET_IP` | 300 |

Or if using subdomain:
| Type | Host | Value | TTL |
|------|------|-------|-----|
| A | `fooddelivery` | `YOUR_DROPLET_IP` | 300 |

#### Step 5.3: Verify DNS Propagation

```bash
# Check DNS resolution
dig +short fooddelivery.yourdomain.com

# Should return your droplet IP
```

Wait 5-30 minutes for DNS to propagate.

---

### Phase 6: Configure SSL Certificate

#### Step 6.1: Test SSL Setup (Staging)

```bash
# First, test with staging certificate
./deploy/setup-ssl.sh --staging
```

If successful, you'll see certificate files created.

#### Step 6.2: Get Production Certificate

```bash
# Get real (trusted) certificate
./deploy/setup-ssl.sh --production
```

#### Step 6.3: Verify HTTPS

```bash
# Check SSL is working
./deploy/health-check.sh --ssl

# Or open in browser
echo "Open: https://$DOMAIN"
```

---

## 📊 Post-Deployment Checklist

```bash
# Run full health check
./deploy/health-check.sh --full
```

- [ ] All containers running: `docker compose -f docker-compose.prod.yml ps`
- [ ] Website loads: `https://yourdomain.com`
- [ ] API responds: `https://yourdomain.com/api/hotels`
- [ ] SSL valid: Check browser padlock icon
- [ ] Database connected: Check auth/registration works

---

## 🔧 Useful Commands

```bash
# View all logs
docker compose -f docker-compose.prod.yml logs -f

# View specific service logs
docker compose -f docker-compose.prod.yml logs -f api-gateway

# Restart all services
docker compose -f docker-compose.prod.yml restart

# Restart specific service
docker compose -f docker-compose.prod.yml restart auth-service

# Stop everything
docker compose -f docker-compose.prod.yml down

# Backup database
./deploy/backup.sh

# Check disk space
df -h

# Check memory usage
free -h

# Check Docker resource usage
docker stats
```

---

## 🔒 Security Checklist

After deployment, ensure:

- [x] Firewall enabled (only 22, 80, 443 open)
- [x] SSH key authentication (disable password auth)
- [x] Non-root user for operations
- [x] Strong database passwords
- [x] SSL/HTTPS enabled
- [ ] **Optional**: Set up fail2ban for brute-force protection
- [ ] **Optional**: Enable DigitalOcean Backups ($1-4/month)

### Disable Password SSH Login (Recommended)

```bash
sudo nano /etc/ssh/sshd_config
```

Set these values:
```
PasswordAuthentication no
PubkeyAuthentication yes
```

Then restart SSH:
```bash
sudo systemctl restart sshd
```

---

## 💰 Cost Summary

| Item | Monthly Cost |
|------|-------------|
| Droplet (4GB/2CPU) | $24 |
| Droplet Backups | $4.80 (optional) |
| Domain | ~$1-2 |
| SSL Certificate | **Free** (Let's Encrypt) |
| **Total** | ~$26-30/month |

---

## 🆘 Troubleshooting

### Build fails with "out of memory"
```bash
# Increase swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Certificate fails to generate
1. Verify DNS points to server: `dig +short yourdomain.com`
2. Verify port 80 is open: `sudo ufw status`
3. Wait for DNS propagation (up to 24h for some registrars)

### Services keep restarting
```bash
# Check logs for specific service
docker logs auth-service --tail 100

# Common causes:
# - Database not ready (wait longer)
# - Wrong passwords in .env
# - Port conflicts
```

### Out of disk space
```bash
# Clean Docker resources
docker system prune -a --volumes

# Check what's using space
du -sh /* | sort -h
```

---

## 📧 Questions?

If you encounter issues:
1. Run `./deploy/health-check.sh --full`
2. Check logs: `docker compose -f docker-compose.prod.yml logs --tail 100`
3. Verify `.env` configuration
