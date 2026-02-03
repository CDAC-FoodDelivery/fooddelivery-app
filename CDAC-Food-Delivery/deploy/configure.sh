#!/bin/bash

# ============================================
# Food Delivery Application - Configure Script
# Environment and Configuration Setup
# ============================================
# This script handles:
# - Environment variable configuration
# - Secret generation
# - DNS validation
# - Pre-deployment checks
# - Nginx configuration setup
# ============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ============================================
# Logging Functions
# ============================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }
log_input() { echo -e "${MAGENTA}[INPUT]${NC} $1"; }

print_banner() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Configuration"
    echo "============================================"
    echo ""
}

# ============================================
# Check Prerequisites
# ============================================
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Run setup.sh first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not available. Run setup.sh first."
        exit 1
    fi
    
    # Check if running in project directory
    if [ ! -f "$PROJECT_ROOT/docker-compose.prod.yml" ]; then
        log_error "docker-compose.prod.yml not found in $PROJECT_ROOT"
        exit 1
    fi
    
    log_success "Prerequisites checked"
}

# ============================================
# Generate Random Secrets
# ============================================
generate_secret() {
    local length=${1:-32}
    openssl rand -hex "$length" 2>/dev/null || cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

generate_password() {
    local length=${1:-24}
    openssl rand -base64 "$length" 2>/dev/null | tr -d '/+=' | head -c "$length" || cat /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%' | fold -w "$length" | head -n 1
}

# ============================================
# Setup Environment File
# ============================================
setup_env_file() {
    log_step "Setting up environment configuration..."
    
    ENV_FILE="$PROJECT_ROOT/.env"
    ENV_EXAMPLE="$PROJECT_ROOT/.env.example"
    
    # Check if .env exists
    if [ -f "$ENV_FILE" ]; then
        log_info ".env file already exists"
        
        if [ "$INTERACTIVE" = true ]; then
            read -p "Do you want to reconfigure? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                log_info "Keeping existing configuration"
                return 0
            fi
            # Backup existing
            cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
            log_info "Backed up existing .env file"
        else
            log_info "Using existing .env file (non-interactive mode)"
            return 0
        fi
    else
        # Copy from example
        if [ -f "$ENV_EXAMPLE" ]; then
            cp "$ENV_EXAMPLE" "$ENV_FILE"
            log_info "Created .env from .env.example"
        else
            log_error ".env.example not found"
            exit 1
        fi
    fi
    
    # Interactive configuration
    if [ "$INTERACTIVE" = true ]; then
        configure_interactive
    else
        configure_defaults
    fi
}

# ============================================
# Interactive Configuration
# ============================================
configure_interactive() {
    echo ""
    echo "============================================"
    echo "   Interactive Configuration"
    echo "============================================"
    echo ""
    
    # Domain
    log_input "Enter your domain name (e.g., fooddelivery.example.com):"
    read -r DOMAIN_INPUT
    if [ -n "$DOMAIN_INPUT" ]; then
        sed -i "s/^DOMAIN=.*/DOMAIN=$DOMAIN_INPUT/" "$ENV_FILE"
    fi
    
    # SSL Email
    log_input "Enter email for SSL certificates:"
    read -r EMAIL_INPUT
    if [ -n "$EMAIL_INPUT" ]; then
        sed -i "s/^SSL_EMAIL=.*/SSL_EMAIL=$EMAIL_INPUT/" "$ENV_FILE"
    fi
    
    # Generate secure passwords
    log_info "Generating secure passwords..."
    
    MYSQL_ROOT_PASS=$(generate_password 24)
    MYSQL_USER_PASS=$(generate_password 24)
    JWT_SECRET=$(generate_secret 32)
    ADMIN_JWT_KEY=$(generate_password 32)
    
    # Update .env file
    sed -i "s/^MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASS/" "$ENV_FILE"
    sed -i "s/^MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$MYSQL_USER_PASS/" "$ENV_FILE"
    sed -i "s/^JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" "$ENV_FILE"
    sed -i "s/^ADMIN_JWT_KEY=.*/ADMIN_JWT_KEY=$ADMIN_JWT_KEY/" "$ENV_FILE"
    
    log_success "Configuration updated with secure passwords"
    
    echo ""
    log_warning "IMPORTANT: Save these credentials securely!"
    echo ""
    echo "  MySQL Root Password: $MYSQL_ROOT_PASS"
    echo "  MySQL User Password: $MYSQL_USER_PASS"
    echo ""
}

# ============================================
# Default Configuration (Non-Interactive)
# ============================================
configure_defaults() {
    log_info "Applying default configuration..."
    
    # Source current env to check values
    source "$ENV_FILE" 2>/dev/null || true
    
    # Generate new secrets if defaults are present
    if [ "$MYSQL_ROOT_PASSWORD" = "ChangeMeToStrongPassword123!" ] || [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        NEW_ROOT_PASS=$(generate_password 24)
        sed -i "s/^MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=$NEW_ROOT_PASS/" "$ENV_FILE"
        log_info "Generated new MySQL root password"
    fi
    
    if [ "$MYSQL_PASSWORD" = "ChangeMeToAnotherStrongPassword456!" ] || [ -z "$MYSQL_PASSWORD" ]; then
        NEW_USER_PASS=$(generate_password 24)
        sed -i "s/^MYSQL_PASSWORD=.*/MYSQL_PASSWORD=$NEW_USER_PASS/" "$ENV_FILE"
        log_info "Generated new MySQL user password"
    fi
    
    log_success "Default configuration applied"
}

# ============================================
# Validate Domain DNS
# ============================================
validate_dns() {
    log_step "Validating DNS configuration..."
    
    source "$PROJECT_ROOT/.env"
    
    if [ -z "$DOMAIN" ] || [ "$DOMAIN" = "fooddelivery.example.com" ]; then
        log_warning "Domain is not configured properly in .env"
        log_info "Set DOMAIN=your.domain.com in .env file"
        return 1
    fi
    
    # Get server's public IP
    SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "unknown")
    
    # Get domain's IP
    DOMAIN_IP=$(dig +short "$DOMAIN" 2>/dev/null | tail -n1 || nslookup "$DOMAIN" 2>/dev/null | grep "Address:" | tail -1 | awk '{print $2}' || echo "unknown")
    
    echo ""
    echo "  Server IP: $SERVER_IP"
    echo "  Domain IP: $DOMAIN_IP"
    echo ""
    
    if [ "$SERVER_IP" = "unknown" ]; then
        log_warning "Could not determine server's public IP"
    elif [ "$DOMAIN_IP" = "unknown" ] || [ -z "$DOMAIN_IP" ]; then
        log_warning "Could not resolve domain $DOMAIN"
        log_info "Make sure DNS A record points to your server"
    elif [ "$SERVER_IP" = "$DOMAIN_IP" ]; then
        log_success "DNS is correctly configured!"
    else
        log_warning "Domain $DOMAIN resolves to $DOMAIN_IP"
        log_warning "But this server's IP is $SERVER_IP"
        log_info "SSL certificate generation may fail if DNS is incorrect"
    fi
}

# ============================================
# Setup Nginx Configuration
# ============================================
setup_nginx_config() {
    log_step "Setting up Nginx configuration..."
    
    source "$PROJECT_ROOT/.env"
    
    # Ensure nginx directory exists
    mkdir -p "$PROJECT_ROOT/nginx"
    
    # Check if SSL certificates exist
    SSL_EXISTS=false
    if docker volume inspect fooddelivery-certbot-certs &> /dev/null 2>&1; then
        # Check if cert actually exists in volume
        if docker run --rm -v fooddelivery-certbot-certs:/certs alpine test -f "/certs/live/$DOMAIN/fullchain.pem" 2>/dev/null; then
            SSL_EXISTS=true
        fi
    fi
    
    if [ "$SSL_EXISTS" = true ]; then
        log_info "SSL certificates found, using production config..."
        
        # Generate production nginx config from template
        if [ -f "$PROJECT_ROOT/nginx/nginx.prod.conf.template" ]; then
            envsubst '${DOMAIN}' < "$PROJECT_ROOT/nginx/nginx.prod.conf.template" > "$PROJECT_ROOT/nginx/nginx.conf"
            log_success "Production Nginx configuration generated"
        else
            log_error "nginx.prod.conf.template not found"
            exit 1
        fi
    else
        log_info "No SSL certificates found, using initial HTTP config..."
        log_info "Run setup-ssl.sh after deployment to enable HTTPS"
        
        # Use initial config
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
# Validate Environment Variables
# ============================================
validate_env() {
    log_step "Validating environment variables..."
    
    source "$PROJECT_ROOT/.env"
    
    local errors=0
    
    # Check required variables
    local required_vars=("DOMAIN" "SSL_EMAIL" "MYSQL_ROOT_PASSWORD" "MYSQL_USER" "MYSQL_PASSWORD" "JWT_SECRET")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            log_error "Missing required variable: $var"
            errors=$((errors + 1))
        fi
    done
    
    # Check for default/placeholder values
    if [ "$DOMAIN" = "fooddelivery.example.com" ]; then
        log_warning "DOMAIN is still set to example value"
        errors=$((errors + 1))
    fi
    
    if [ "$SSL_EMAIL" = "admin@example.com" ]; then
        log_warning "SSL_EMAIL is still set to example value"
    fi
    
    if [ $errors -gt 0 ]; then
        log_error "Found $errors configuration issues"
        log_info "Please update .env file and run configure.sh again"
        return 1
    fi
    
    log_success "Environment variables validated"
    return 0
}

# ============================================
# Pre-deployment Checks
# ============================================
predeployment_checks() {
    log_step "Running pre-deployment checks..."
    
    local warnings=0
    
    # Check if ports are available
    for port in 80 443; do
        if ss -tuln 2>/dev/null | grep -q ":$port " || netstat -tuln 2>/dev/null | grep -q ":$port "; then
            log_warning "Port $port is already in use"
            warnings=$((warnings + 1))
        fi
    done
    
    # Check Docker daemon
    if ! docker info &> /dev/null 2>&1; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check disk space
    DISK_AVAILABLE_GB=$(df "$PROJECT_ROOT" | tail -1 | awk '{print int($4/1024/1024)}')
    if [ "$DISK_AVAILABLE_GB" -lt 10 ]; then
        log_warning "Low disk space: ${DISK_AVAILABLE_GB}GB available"
        warnings=$((warnings + 1))
    fi
    
    if [ $warnings -eq 0 ]; then
        log_success "All pre-deployment checks passed"
    else
        log_warning "$warnings warning(s) found, but you may continue"
    fi
}

# ============================================
# Print Configuration Summary
# ============================================
print_summary() {
    source "$PROJECT_ROOT/.env"
    
    echo ""
    echo "============================================"
    echo "   Configuration Complete!"
    echo "============================================"
    echo ""
    echo "  Current Configuration:"
    echo "  ----------------------"
    echo "  Domain:     $DOMAIN"
    echo "  SSL Email:  $SSL_EMAIL"
    echo "  MySQL User: $MYSQL_USER"
    echo "  Environment: ${ENVIRONMENT:-production}"
    echo ""
    echo "  Next Steps:"
    echo "  -----------"
    echo "  1. Review .env file if needed"
    echo "  2. Run: ./deploy/build.sh"
    echo "  3. Run: ./deploy/deploy.sh"
    echo ""
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --interactive, -i   Interactive configuration mode"
    echo "  --validate-only     Only validate current configuration"
    echo "  --generate-secrets  Generate new secrets only"
    echo "  --help, -h          Show this help message"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    
    # Parse arguments
    INTERACTIVE=false
    VALIDATE_ONLY=false
    GENERATE_SECRETS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interactive|-i)
                INTERACTIVE=true
                shift
                ;;
            --validate-only)
                VALIDATE_ONLY=true
                shift
                ;;
            --generate-secrets)
                GENERATE_SECRETS=true
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
    
    # Check prerequisites
    check_prerequisites
    
    # Validate only mode
    if $VALIDATE_ONLY; then
        validate_env
        validate_dns
        predeployment_checks
        exit $?
    fi
    
    # Generate secrets only mode
    if $GENERATE_SECRETS; then
        echo "New JWT Secret: $(generate_secret 32)"
        echo "New MySQL Password: $(generate_password 24)"
        echo "New Admin JWT Key: $(generate_password 32)"
        exit 0
    fi
    
    # Full configuration
    setup_env_file
    validate_env || log_warning "Some validations failed, please check .env"
    validate_dns
    setup_nginx_config
    predeployment_checks
    print_summary
}

# Run main function
main "$@"
