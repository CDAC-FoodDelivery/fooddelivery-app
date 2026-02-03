#!/bin/bash

# ============================================
# Food Delivery Application - SSL Setup Script
# Certbot/Let's Encrypt Certificate Management
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        log_error ".env file not found!"
        exit 1
    fi
    
    source "$PROJECT_ROOT/.env"
    
    if [ -z "$DOMAIN" ] || [ -z "$SSL_EMAIL" ]; then
        log_error "DOMAIN and SSL_EMAIL must be set in .env file"
        exit 1
    fi
    
    log_info "Domain: $DOMAIN"
    log_info "Email: $SSL_EMAIL"
}

# ============================================
# Pre-checks
# ============================================
pre_checks() {
    log_info "Running pre-checks..."
    
    # Check if services are running
    if ! docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" ps | grep -q "nginx"; then
        log_error "Services are not running. Please run deploy.sh first."
        exit 1
    fi
    log_success "Services are running"
    
    # Check if domain resolves to this server
    log_info "Checking DNS resolution for $DOMAIN..."
    
    local server_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null || echo "unknown")
    local domain_ip=$(dig +short "$DOMAIN" 2>/dev/null | tail -n1 || echo "unknown")
    
    if [ "$server_ip" != "unknown" ] && [ "$domain_ip" != "unknown" ]; then
        if [ "$server_ip" = "$domain_ip" ]; then
            log_success "Domain $DOMAIN resolves to this server ($server_ip)"
        else
            log_warning "Domain $DOMAIN resolves to $domain_ip, but this server is $server_ip"
            log_warning "Certificate generation may fail if DNS is not properly configured"
            
            read -p "Continue anyway? (y/n): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        log_warning "Could not verify DNS resolution. Make sure $DOMAIN points to this server."
    fi
}

# ============================================
# Generate Certificate (Staging - for testing)
# ============================================
generate_staging_cert() {
    log_info "Generating staging certificate (for testing)..."
    log_warning "Staging certificates are NOT trusted by browsers"
    
    docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" run --rm certbot \
        certonly --webroot \
        --webroot-path=/var/www/certbot \
        --email "$SSL_EMAIL" \
        --agree-tos \
        --no-eff-email \
        --staging \
        -d "$DOMAIN"
    
    log_success "Staging certificate generated"
    log_info "If successful, run with --production to get a real certificate"
}

# ============================================
# Generate Certificate (Production)
# ============================================
generate_production_cert() {
    log_info "Generating production SSL certificate..."
    log_warning "Rate limits apply! You can only request ~5 certificates per week per domain."
    
    read -p "Are you sure you want to generate a production certificate? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Aborted"
        exit 0
    fi
    
    docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" run --rm certbot \
        certonly --webroot \
        --webroot-path=/var/www/certbot \
        --email "$SSL_EMAIL" \
        --agree-tos \
        --no-eff-email \
        --force-renewal \
        -d "$DOMAIN"
    
    if [ $? -eq 0 ]; then
        log_success "Production certificate generated successfully!"
        configure_ssl
    else
        log_error "Failed to generate certificate"
        log_info "Common issues:"
        log_info "  1. DNS not pointing to this server"
        log_info "  2. Port 80 not accessible from internet"
        log_info "  3. Rate limit exceeded"
        exit 1
    fi
}

# ============================================
# Configure Nginx with SSL
# ============================================
configure_ssl() {
    log_info "Configuring Nginx with SSL..."
    
    # Generate production nginx config
    envsubst '${DOMAIN}' < "$PROJECT_ROOT/nginx/nginx.prod.conf.template" > "$PROJECT_ROOT/nginx/nginx.conf"
    
    # Reload nginx
    docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" exec nginx nginx -s reload
    
    log_success "Nginx configured with SSL"
    log_success "Your site is now available at https://$DOMAIN"
}

# ============================================
# Setup Auto-Renewal Cron Job
# ============================================
setup_renewal() {
    log_info "Setting up automatic certificate renewal..."
    
    # Create renewal script
    cat > "$PROJECT_ROOT/deploy/renew-certs.sh" << 'EOF'
#!/bin/bash
# Auto-renewal script for SSL certificates

cd "$(dirname "$0")/.."

# Renew certificates
docker compose -f docker-compose.prod.yml run --rm certbot renew --quiet

# Reload nginx if renewal was successful
if [ $? -eq 0 ]; then
    docker compose -f docker-compose.prod.yml exec nginx nginx -s reload
fi
EOF
    
    chmod +x "$PROJECT_ROOT/deploy/renew-certs.sh"
    
    # Add to crontab (run twice daily as recommended by Let's Encrypt)
    local cron_job="0 */12 * * * $PROJECT_ROOT/deploy/renew-certs.sh >> /var/log/certbot-renewal.log 2>&1"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "renew-certs.sh"; then
        log_info "Cron job already exists"
    else
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        log_success "Cron job added for automatic renewal (runs twice daily)"
    fi
}

# ============================================
# Check Certificate Status
# ============================================
check_status() {
    log_info "Checking SSL certificate status..."
    
    docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" run --rm certbot certificates
    
    echo ""
    log_info "Testing HTTPS connection..."
    
    if curl -sI "https://$DOMAIN" 2>/dev/null | head -1 | grep -q "200\|301\|302"; then
        log_success "HTTPS is working correctly!"
    else
        log_warning "Could not verify HTTPS connection"
    fi
    
    # Check certificate expiry
    echo ""
    log_info "Certificate expiration info:"
    echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | \
        openssl x509 -noout -dates 2>/dev/null || log_warning "Could not check certificate dates"
}

# ============================================
# Revoke Certificate
# ============================================
revoke_cert() {
    log_warning "This will revoke the SSL certificate for $DOMAIN"
    read -p "Are you sure? (type 'REVOKE' to confirm): " confirm
    
    if [ "$confirm" = "REVOKE" ]; then
        docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" run --rm certbot revoke \
            --cert-name "$DOMAIN"
        log_success "Certificate revoked"
    else
        log_info "Revocation cancelled"
    fi
}

# ============================================
# Main
# ============================================
main() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - SSL Setup"
    echo "============================================"
    echo ""
    
    load_env
    
    case "${1:-}" in
        --staging)
            pre_checks
            generate_staging_cert
            ;;
        --production)
            pre_checks
            generate_production_cert
            setup_renewal
            ;;
        --configure)
            configure_ssl
            ;;
        --renew)
            docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" run --rm certbot renew
            docker compose -f "$PROJECT_ROOT/docker-compose.prod.yml" exec nginx nginx -s reload
            ;;
        --status)
            check_status
            ;;
        --revoke)
            revoke_cert
            ;;
        --help|-h)
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --staging      Generate staging/test certificate (not trusted)"
            echo "  --production   Generate production certificate (trusted)"
            echo "  --configure    Configure Nginx with existing certificates"
            echo "  --renew        Force certificate renewal"
            echo "  --status       Check certificate status"
            echo "  --revoke       Revoke the certificate"
            echo "  --help, -h     Show this help"
            echo ""
            echo "Recommended workflow:"
            echo "  1. First test with: $0 --staging"
            echo "  2. If successful:   $0 --production"
            echo ""
            exit 0
            ;;
        *)
            echo "Interactive SSL Setup"
            echo ""
            echo "1) Generate staging certificate (for testing)"
            echo "2) Generate production certificate"
            echo "3) Check certificate status"
            echo "4) Exit"
            echo ""
            read -p "Select option [1-4]: " option
            
            case $option in
                1)
                    pre_checks
                    generate_staging_cert
                    ;;
                2)
                    pre_checks
                    generate_production_cert
                    setup_renewal
                    ;;
                3)
                    check_status
                    ;;
                *)
                    log_info "Exiting..."
                    exit 0
                    ;;
            esac
            ;;
    esac
}

main "$@"
