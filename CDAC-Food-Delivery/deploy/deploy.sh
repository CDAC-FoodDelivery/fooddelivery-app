#!/bin/bash

# ============================================
# Food Delivery Application - Deployment Script
# Production deployment with Docker Compose
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================
# Pre-flight Checks
# ============================================
preflight_checks() {
    log_info "Running pre-flight checks..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        log_info "Visit: https://docs.docker.com/engine/install/"
        exit 1
    fi
    log_success "Docker is installed: $(docker --version)"
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose (v2) is not installed."
        log_info "Docker Compose V2 comes with Docker Desktop or can be installed separately."
        exit 1
    fi
    log_success "Docker Compose is installed: $(docker compose version)"
    
    # Check Docker is running
    if ! docker info &> /dev/null 2>&1; then
        log_error "Docker daemon is not running. Please start Docker."
        exit 1
    fi
    log_success "Docker daemon is running"
    
    # Check for .env file
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        log_error ".env file not found!"
        log_info "Please copy .env.example to .env and configure it:"
        log_info "  cp $PROJECT_ROOT/.env.example $PROJECT_ROOT/.env"
        log_info "  nano $PROJECT_ROOT/.env"
        exit 1
    fi
    log_success ".env file exists"
    
    # Validate required environment variables
    source "$PROJECT_ROOT/.env"
    
    local required_vars=("DOMAIN" "SSL_EMAIL" "MYSQL_ROOT_PASSWORD" "MYSQL_USER" "MYSQL_PASSWORD" "JWT_SECRET")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        log_error "Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "  - $var"
        done
        exit 1
    fi
    log_success "All required environment variables are set"
    
    # Check if ports are available
    local ports=("80" "443")
    for port in "${ports[@]}"; do
        if ss -tuln | grep -q ":$port "; then
            log_warning "Port $port is already in use. This may cause conflicts."
        fi
    done
    
    log_success "Pre-flight checks passed!"
    echo ""
}

# ============================================
# Setup Nginx Configuration
# ============================================
setup_nginx() {
    log_info "Setting up Nginx configuration..."
    
    source "$PROJECT_ROOT/.env"
    
    # Create nginx directory if not exists
    mkdir -p "$PROJECT_ROOT/nginx"
    
    # Check if SSL certificates exist
    if [ -d "/etc/letsencrypt/live/$DOMAIN" ] || docker volume inspect fooddelivery-certbot-certs &> /dev/null 2>&1; then
        log_info "SSL certificates found, using production config..."
        
        # Generate production nginx config from template
        envsubst '${DOMAIN}' < "$PROJECT_ROOT/nginx/nginx.prod.conf.template" > "$PROJECT_ROOT/nginx/nginx.conf"
        log_success "Production Nginx configuration generated"
    else
        log_warning "No SSL certificates found, using initial config (HTTP only)..."
        log_info "Run setup-ssl.sh after deployment to enable HTTPS"
        
        cp "$PROJECT_ROOT/nginx/nginx.initial.conf" "$PROJECT_ROOT/nginx/nginx.conf"
        log_success "Initial Nginx configuration set"
    fi
}

# ============================================
# Build Docker Images
# ============================================
build_images() {
    log_info "Building Docker images..."
    log_info "This may take 5-15 minutes on first run..."
    echo ""
    
    cd "$PROJECT_ROOT"
    
    if docker compose -f docker-compose.prod.yml build --parallel; then
        log_success "All Docker images built successfully"
    else
        log_error "Failed to build Docker images"
        exit 1
    fi
    
    echo ""
}

# ============================================
# Deploy Services
# ============================================
deploy_services() {
    log_info "Deploying services..."
    
    cd "$PROJECT_ROOT"
    
    # Stop existing containers if running
    log_info "Stopping existing containers (if any)..."
    docker compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
    
    # Start services
    log_info "Starting all services..."
    if docker compose -f docker-compose.prod.yml up -d; then
        log_success "Services started successfully"
    else
        log_error "Failed to start services"
        exit 1
    fi
    
    echo ""
}

# ============================================
# Wait for Services to be Healthy
# ============================================
wait_for_health() {
    log_info "Waiting for services to become healthy..."
    log_info "This may take 2-5 minutes..."
    
    local services=("mysql" "discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend")
    local max_wait=300  # 5 minutes
    local interval=10
    local elapsed=0
    
    while [ $elapsed -lt $max_wait ]; do
        local all_healthy=true
        local status_line=""
        
        for service in "${services[@]}"; do
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "unknown")
            
            case $health in
                "healthy")
                    status_line+="${GREEN}✓${NC} "
                    ;;
                "unhealthy")
                    status_line+="${RED}✗${NC} "
                    all_healthy=false
                    ;;
                *)
                    status_line+="${YELLOW}○${NC} "
                    all_healthy=false
                    ;;
            esac
        done
        
        echo -ne "\r  Services: $status_line (${elapsed}s / ${max_wait}s)"
        
        if $all_healthy; then
            echo ""
            log_success "All services are healthy!"
            return 0
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo ""
    log_warning "Some services may not be fully healthy after ${max_wait}s"
    log_info "Check logs with: docker compose -f docker-compose.prod.yml logs -f"
    return 1
}

# ============================================
# Show Status
# ============================================
show_status() {
    echo ""
    echo "============================================"
    echo "   Deployment Complete!"
    echo "============================================"
    echo ""
    
    source "$PROJECT_ROOT/.env"
    
    echo "Container Status:"
    docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    echo "============================================"
    echo "   Access Points"
    echo "============================================"
    echo ""
    
    if [ -f "$PROJECT_ROOT/nginx/nginx.conf" ] && grep -q "ssl_certificate" "$PROJECT_ROOT/nginx/nginx.conf" 2>/dev/null; then
        echo "  Website:     https://$DOMAIN"
    else
        echo "  Website:     http://$DOMAIN (HTTPS not configured yet)"
        echo ""
        echo "  To enable HTTPS, run:"
        echo "    ./deploy/setup-ssl.sh"
    fi
    
    echo ""
    echo "  Eureka (internal):  http://localhost:8761"
    echo "  MySQL (internal):   localhost:3307"
    echo ""
    echo "============================================"
    echo "   Useful Commands"
    echo "============================================"
    echo ""
    echo "  View logs:      docker compose -f docker-compose.prod.yml logs -f"
    echo "  View service:   docker compose -f docker-compose.prod.yml logs -f [service]"
    echo "  Stop all:       docker compose -f docker-compose.prod.yml down"
    echo "  Restart:        docker compose -f docker-compose.prod.yml restart"
    echo "  Health check:   ./deploy/health-check.sh"
    echo "  Backup:         ./deploy/backup.sh"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Production Deploy"
    echo "============================================"
    echo ""
    
    # Parse arguments
    case "${1:-}" in
        --build-only)
            preflight_checks
            build_images
            log_success "Build completed. Run without --build-only to deploy."
            exit 0
            ;;
        --no-build)
            preflight_checks
            setup_nginx
            deploy_services
            wait_for_health
            show_status
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --build-only   Only build images, don't deploy"
            echo "  --no-build     Deploy without rebuilding images"
            echo "  --help, -h     Show this help message"
            echo ""
            exit 0
            ;;
        *)
            preflight_checks
            setup_nginx
            build_images
            deploy_services
            wait_for_health
            show_status
            ;;
    esac
}

# Run main function
main "$@"
