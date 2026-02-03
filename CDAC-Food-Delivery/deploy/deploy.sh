#!/bin/bash

# ============================================
# Food Delivery Application - Deployment Script
# Production deployment with Docker Compose
# ============================================
# Usage:
#   ./deploy.sh              # Full deploy (build + start)
#   ./deploy.sh --no-build   # Deploy without rebuilding
#   ./deploy.sh --build-only # Only build images
#   ./deploy.sh --quick      # Skip health wait
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.prod.yml"

# Deployment settings
HEALTH_CHECK_TIMEOUT=${HEALTH_CHECK_TIMEOUT:-300}
HEALTH_CHECK_INTERVAL=10

# ============================================
# Logging Functions
# ============================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

print_banner() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Production Deploy"
    echo "============================================"
    echo "   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "============================================"
    echo ""
}

# ============================================
# Pre-flight Checks
# ============================================
preflight_checks() {
    log_step "Running pre-flight checks..."
    
    local errors=0
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        log_info "Run: sudo ./deploy/setup.sh to install Docker"
        errors=$((errors + 1))
    else
        log_success "Docker installed: $(docker --version | awk '{print $3}' | tr -d ',')"
    fi
    
    # Check Docker Compose V2
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose V2 is not available"
        errors=$((errors + 1))
    else
        log_success "Docker Compose: $(docker compose version --short 2>/dev/null || echo 'V2')"
    fi
    
    # Check Docker is running
    if ! docker info &> /dev/null 2>&1; then
        log_error "Docker daemon is not running"
        errors=$((errors + 1))
    else
        log_success "Docker daemon is running"
    fi
    
    # Check compose file exists
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "docker-compose.prod.yml not found"
        errors=$((errors + 1))
    fi
    
    # Check for .env file
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        log_error ".env file not found"
        log_info "Run: ./deploy/configure.sh to create one"
        errors=$((errors + 1))
    else
        log_success ".env file exists"
        
        # Validate required environment variables
        source "$PROJECT_ROOT/.env"
        
        local required_vars=("DOMAIN" "MYSQL_ROOT_PASSWORD" "MYSQL_USER" "MYSQL_PASSWORD" "JWT_SECRET")
        local missing_vars=()
        
        for var in "${required_vars[@]}"; do
            if [ -z "${!var}" ]; then
                missing_vars+=("$var")
            fi
        done
        
        if [ ${#missing_vars[@]} -ne 0 ]; then
            log_error "Missing environment variables:"
            for var in "${missing_vars[@]}"; do
                echo "  - $var"
            done
            errors=$((errors + 1))
        else
            log_success "Environment variables validated"
        fi
    fi
    
    # Check disk space
    local disk_available_gb=$(df "$PROJECT_ROOT" | tail -1 | awk '{print int($4/1024/1024)}')
    if [ "$disk_available_gb" -lt 5 ]; then
        log_warning "Low disk space: ${disk_available_gb}GB available"
        log_info "Consider running: docker system prune"
    fi
    
    # Exit if errors
    if [ $errors -gt 0 ]; then
        log_error "Pre-flight checks failed with $errors error(s)"
        exit 1
    fi
    
    log_success "Pre-flight checks passed!"
    echo ""
}

# ============================================
# Setup Nginx Configuration
# ============================================
setup_nginx() {
    log_step "Setting up Nginx configuration..."
    
    source "$PROJECT_ROOT/.env"
    
    # Create nginx directory if not exists
    mkdir -p "$PROJECT_ROOT/nginx"
    
    # Copy proxy params if not exists
    if [ -f "$PROJECT_ROOT/nginx/proxy_params_custom" ]; then
        log_info "Using existing proxy_params_custom"
    fi
    
    # Check if SSL certificates exist in Docker volume
    local ssl_exists=false
    if docker volume inspect fooddelivery-certbot-certs &> /dev/null 2>&1; then
        # Check if cert actually exists in volume
        if docker run --rm -v fooddelivery-certbot-certs:/certs:ro alpine test -f "/certs/live/$DOMAIN/fullchain.pem" 2>/dev/null; then
            ssl_exists=true
        fi
    fi
    
    if [ "$ssl_exists" = true ]; then
        log_info "SSL certificates found, using production config..."
        
        if [ -f "$PROJECT_ROOT/nginx/nginx.prod.conf.template" ]; then
            envsubst '${DOMAIN}' < "$PROJECT_ROOT/nginx/nginx.prod.conf.template" > "$PROJECT_ROOT/nginx/nginx.conf"
            log_success "Production Nginx configuration generated"
        else
            log_error "nginx.prod.conf.template not found"
            exit 1
        fi
    else
        log_warning "No SSL certificates found, using initial HTTP config..."
        log_info "Run ./deploy/setup-ssl.sh after deployment to enable HTTPS"
        
        if [ -f "$PROJECT_ROOT/nginx/nginx.initial.conf" ]; then
            cp "$PROJECT_ROOT/nginx/nginx.initial.conf" "$PROJECT_ROOT/nginx/nginx.conf"
            log_success "Initial Nginx configuration set"
        else
            log_error "nginx.initial.conf not found"
            exit 1
        fi
    fi
}

# ============================================
# Save State for Rollback
# ============================================
save_rollback_state() {
    log_info "Saving current state for rollback..."
    
    "$SCRIPT_DIR/rollback.sh" --save 2>/dev/null || true
}

# ============================================
# Build Docker Images
# ============================================
build_images() {
    log_step "Building Docker images..."
    log_info "This may take 5-15 minutes on first run..."
    echo ""
    
    local start_time=$(date +%s)
    
    cd "$PROJECT_ROOT"
    
    if docker compose -f "$COMPOSE_FILE" build --parallel; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        
        log_success "All Docker images built in ${minutes}m ${seconds}s"
    else
        log_error "Failed to build Docker images"
        log_info "Check build logs above for errors"
        exit 1
    fi
    
    echo ""
}

# ============================================
# Deploy Services
# ============================================
deploy_services() {
    log_step "Deploying services..."
    
    cd "$PROJECT_ROOT"
    
    # Stop existing containers if running
    log_info "Stopping existing containers (if any)..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
    # Start services
    log_info "Starting all services..."
    if docker compose -f "$COMPOSE_FILE" up -d; then
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
    log_step "Waiting for services to become healthy..."
    log_info "Timeout: ${HEALTH_CHECK_TIMEOUT}s"
    echo ""
    
    local services=("mysql" "discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend" "nginx")
    local max_wait=$HEALTH_CHECK_TIMEOUT
    local interval=$HEALTH_CHECK_INTERVAL
    local elapsed=0
    
    while [ $elapsed -lt $max_wait ]; do
        local all_healthy=true
        local healthy_count=0
        local total_count=${#services[@]}
        local status_line=""
        
        for service in "${services[@]}"; do
            local state=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "missing")
            local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "none")
            
            if [ "$state" = "running" ]; then
                if [ "$health" = "healthy" ] || [ "$health" = "none" ]; then
                    status_line+="${GREEN}✓${NC}"
                    healthy_count=$((healthy_count + 1))
                elif [ "$health" = "starting" ]; then
                    status_line+="${YELLOW}○${NC}"
                    all_healthy=false
                else
                    status_line+="${RED}✗${NC}"
                    all_healthy=false
                fi
            else
                status_line+="${RED}✗${NC}"
                all_healthy=false
            fi
        done
        
        printf "\r  Status: [%s] %d/%d services ready (%ds)" "$status_line" "$healthy_count" "$total_count" "$elapsed"
        
        if $all_healthy; then
            echo ""
            echo ""
            log_success "All services are healthy!"
            return 0
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    echo ""
    echo ""
    log_warning "Timeout reached after ${max_wait}s"
    log_info "Some services may still be starting..."
    
    # Show which services are not healthy
    echo ""
    echo "Service Status:"
    for service in "${services[@]}"; do
        local state=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "missing")
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "none")
        
        if [ "$state" = "running" ] && ([ "$health" = "healthy" ] || [ "$health" = "none" ]); then
            echo -e "  ${GREEN}✓${NC} $service"
        else
            echo -e "  ${RED}✗${NC} $service ($state/$health)"
        fi
    done
    
    echo ""
    log_info "Check logs with: ./deploy/logs.sh --errors"
    return 1
}

# ============================================
# Show Status
# ============================================
show_status() {
    source "$PROJECT_ROOT/.env"
    
    echo ""
    echo "============================================"
    echo "   Deployment Complete!"
    echo "============================================"
    echo ""
    
    echo "Container Status:"
    echo "─────────────────"
    docker compose -f "$COMPOSE_FILE" ps --format "table {{.Name}}\t{{.Status}}" 2>/dev/null || docker compose -f "$COMPOSE_FILE" ps
    
    echo ""
    echo "============================================"
    echo "   Access Points"
    echo "============================================"
    echo ""
    
    # Check if HTTPS is configured
    if grep -q "ssl_certificate" "$PROJECT_ROOT/nginx/nginx.conf" 2>/dev/null; then
        echo "  🌐 Website:  https://$DOMAIN"
        echo ""
    else
        echo "  🌐 Website:  http://$DOMAIN  (HTTPS not configured)"
        echo ""
        echo "  To enable HTTPS, run:"
        echo "    ./deploy/setup-ssl.sh --production"
        echo ""
    fi
    
    echo "============================================"
    echo "   Next Steps"
    echo "============================================"
    echo ""
    echo "  Verify deployment:  ./deploy/verify.sh"
    echo "  View logs:          ./deploy/logs.sh"
    echo "  Health check:       ./deploy/health-check.sh"
    echo "  Setup SSL:          ./deploy/setup-ssl.sh"
    echo ""
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  (none)          Full deployment (build + deploy)"
    echo "  --no-build      Deploy using existing images"
    echo "  --build-only    Only build images, don't deploy"
    echo "  --quick         Deploy without waiting for health checks"
    echo "  --force         Force deployment even if checks fail"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0              # Full deployment"
    echo "  $0 --no-build   # Quick redeploy with existing images"
    echo "  $0 --build-only # Just rebuild images"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    
    # Parse arguments
    local DO_BUILD=true
    local DO_DEPLOY=true
    local WAIT_HEALTH=true
    local FORCE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --build-only)
                DO_DEPLOY=false
                shift
                ;;
            --no-build)
                DO_BUILD=false
                shift
                ;;
            --quick)
                WAIT_HEALTH=false
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Run pre-flight checks
    if ! $FORCE; then
        preflight_checks
    else
        log_warning "Skipping pre-flight checks (--force)"
    fi
    
    # Setup Nginx
    if $DO_DEPLOY; then
        setup_nginx
    fi
    
    # Save state for rollback (if deploying)
    if $DO_DEPLOY; then
        save_rollback_state
    fi
    
    # Build images
    if $DO_BUILD; then
        build_images
        if ! $DO_DEPLOY; then
            log_success "Build completed. Run without --build-only to deploy."
            exit 0
        fi
    fi
    
    # Deploy services
    if $DO_DEPLOY; then
        deploy_services
        
        # Wait for health
        if $WAIT_HEALTH; then
            wait_for_health || true  # Don't exit on health check failure
        fi
        
        # Show status
        show_status
    fi
}

# Run main function
main "$@"
