#!/bin/bash

# ============================================
# Food Delivery Application - SSL Setup Script
# Certbot/Let's Encrypt Certificate Management
# ============================================
# Usage:
#   ./setup-ssl.sh --staging     # Test certificate (not trusted)
#   ./setup-ssl.sh --production  # Real certificate (trusted)
#   ./setup-ssl.sh --status      # Check certificate status
# ============================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.prod.yml"

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

print_banner() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - SSL Setup"
    echo "============================================"
    echo ""
}

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ ! -f "$PROJECT_ROOT/.env" ]; then
        log_error ".env file not found!"
        log_info "Run: ./deploy/configure.sh to create one"
        exit 1
    fi
    
    source "$PROJECT_ROOT/.env"
    
    if [ -z "$DOMAIN" ]; then
        log_error "DOMAIN must be set in .env file"
        exit 1
    fi
    
    if [ -z "$SSL_EMAIL" ]; then
        log_error "SSL_EMAIL must be set in .env file"
        exit 1
    fi
    
    log_info "Domain: $DOMAIN"
    log_info "Email: $SSL_EMAIL"
}

# ============================================
# Check DNS Configuration
# ============================================
check_dns() {
    log_step "Checking DNS configuration..."
    
    # Get server's public IP
    local server_ip=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null)
    if [ -z "$server_ip" ]; then
        server_ip=$(curl -s --connect-timeout 5 icanhazip.com 2>/dev/null)
    fi
    if [ -z "$server_ip" ]; then
        server_ip=$(curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null)
    fi
    
    if [ -z "$server_ip" ]; then
        log_error "Could not determine server's public IP"
        exit 1
    fi
    
    log_info "Server IP: $server_ip"
    
    # Get domain's IP
    local domain_ip=$(dig +short "$DOMAIN" 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -1)
    
    if [ -z "$domain_ip" ]; then
        log_error "Domain $DOMAIN does not resolve to any IP address!"
        echo ""
        log_info "╔════════════════════════════════════════════════════════════╗"
        log_info "║  DNS NOT CONFIGURED - SSL certificate cannot be obtained   ║"
        log_info "╚════════════════════════════════════════════════════════════╝"
        echo ""
        log_info "To fix this:"
        log_info "  1. Go to your domain registrar (GoDaddy, Namecheap, Cloudflare, etc.)"
        log_info "  2. Add an A record:"
        log_info "     - Name/Host: @ (or 'fooddelivery' if subdomain)"
        log_info "     - Type: A"
        log_info "     - Value: $server_ip"
        log_info "     - TTL: 300 (or lowest available)"
        log_info "  3. Wait 5-10 minutes for DNS propagation"
        log_info "  4. Verify with: dig +short $DOMAIN"
        log_info "  5. Run this script again"
        echo ""
        exit 1
    fi
    
    log_info "Domain IP: $domain_ip"
    
    if [ "$server_ip" != "$domain_ip" ]; then
        log_error "DNS MISMATCH!"
        log_info "Domain $DOMAIN resolves to: $domain_ip"
        log_info "But this server's IP is: $server_ip"
        echo ""
        log_info "Let's Encrypt will fail because it needs to reach THIS server"
        log_info "when it tries to verify http://$DOMAIN/.well-known/acme-challenge/"
        echo ""
        log_info "Please update your DNS A record to point to: $server_ip"
        echo ""
        
        read -p "Continue anyway (will likely fail)? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "DNS correctly configured: $DOMAIN → $server_ip"
    fi
}

# ============================================
# Check Services Running
# ============================================
check_services() {
    log_step "Checking services..."
    
    # Use docker inspect to reliably check if nginx is running
    local nginx_status=$(docker inspect --format='{{.State.Status}}' nginx 2>/dev/null || echo "not found")
    
    if [ "$nginx_status" != "running" ]; then
        log_error "Nginx is not running! (status: $nginx_status)"
        log_info "Please run: ./deploy/deploy.sh first"
        exit 1
    fi
    log_success "Nginx is running"
    
    # Test that nginx can serve the ACME challenge path
    log_step "Testing ACME challenge path..."
    
    # Create a test file in the certbot webroot
    docker exec nginx sh -c "mkdir -p /var/www/certbot/.well-known/acme-challenge && echo 'test' > /var/www/certbot/.well-known/acme-challenge/test" 2>/dev/null || true
    
    # Try to access it via HTTP
    local test_result=$(curl -s --connect-timeout 10 "http://$DOMAIN/.well-known/acme-challenge/test" 2>/dev/null)
    
    if [ "$test_result" = "test" ]; then
        log_success "ACME challenge path is accessible"
        # Clean up test file
        docker exec nginx rm -f /var/www/certbot/.well-known/acme-challenge/test 2>/dev/null || true
    else
        log_error "Cannot access ACME challenge path!"
        log_info "Let's Encrypt needs to access: http://$DOMAIN/.well-known/acme-challenge/"
        echo ""
        log_info "Possible causes:"
        log_info "  1. Firewall blocking port 80"
        log_info "  2. Nginx not configured correctly"
        log_info "  3. DNS not pointing to this server"
        echo ""
        log_info "Check firewall: sudo ufw status"
        log_info "Check nginx: docker logs nginx --tail 20"
        
        # Clean up
        docker exec nginx rm -f /var/www/certbot/.well-known/acme-challenge/test 2>/dev/null || true
        
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# ============================================
# Check for Existing Certificate
# ============================================
check_existing_cert() {
    local cert_exists=false
    
    # Check if certificate exists in Docker volume
    if docker run --rm -v fooddelivery-certbot-certs:/certs:ro alpine \
        test -f "/certs/live/$DOMAIN/fullchain.pem" 2>/dev/null; then
        cert_exists=true
    fi
    
    echo "$cert_exists"
}

# ============================================
# Generate Certificate (Staging - for testing)
# ============================================
generate_staging_cert() {
    log_step "Generating STAGING certificate (for testing)..."
    log_warning "Staging certificates are NOT trusted by browsers"
    log_warning "Use this to test before requesting a production certificate"
    echo ""
    
    local cert_exists=$(check_existing_cert)
    local extra_flags=""
    
    if [ "$cert_exists" = "true" ]; then
        log_info "Existing certificate found, will replace with staging cert"
        extra_flags="--break-my-certs"  # Allow downgrade to staging
    fi
    
    # Run certbot
    docker compose -f "$COMPOSE_FILE" run --rm certbot \
        certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$SSL_EMAIL" \
        --agree-tos \
        --no-eff-email \
        --staging \
        $extra_flags \
        -d "$DOMAIN"
    
    local result=$?
    
    if [ $result -eq 0 ]; then
        log_success "Staging certificate generated successfully!"
        echo ""
        log_info "Certificate location: /etc/letsencrypt/live/$DOMAIN/"
        log_info "This certificate is NOT trusted by browsers"
        echo ""
        log_info "If this worked, run: $0 --production"
    else
        log_error "Failed to generate staging certificate"
        show_troubleshooting
        exit 1
    fi
}

# ============================================
# Generate Certificate (Production)
# ============================================
generate_production_cert() {
    log_step "Generating PRODUCTION certificate..."
    log_warning "Rate limits: ~5 certificates per week per domain"
    echo ""
    
    local cert_exists=$(check_existing_cert)
    
    if [ "$cert_exists" = "true" ]; then
        log_info "Existing certificate found"
        read -p "Replace existing certificate? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted"
            exit 0
        fi
    else
        read -p "Request production certificate? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted"
            exit 0
        fi
    fi
    
    echo ""
    log_info "Requesting certificate from Let's Encrypt..."
    echo ""
    
    # Run certbot - use --force-renewal only if cert exists
    local renewal_flag=""
    if [ "$cert_exists" = "true" ]; then
        renewal_flag="--force-renewal"
    fi
    
    docker compose -f "$COMPOSE_FILE" run --rm certbot \
        certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$SSL_EMAIL" \
        --agree-tos \
        --no-eff-email \
        $renewal_flag \
        -d "$DOMAIN"
    
    local result=$?
    
    if [ $result -eq 0 ]; then
        log_success "Production certificate generated successfully!"
        echo ""
        configure_ssl
        setup_renewal
    else
        log_error "Failed to generate production certificate"
        show_troubleshooting
        exit 1
    fi
}

# ============================================
# Configure Nginx with SSL
# ============================================
configure_ssl() {
    log_step "Configuring Nginx for HTTPS..."
    
    # CRITICAL: Check if certificates exist first
    local cert_exists=$(check_existing_cert)
    
    if [ "$cert_exists" != "true" ]; then
        log_error "SSL certificates do not exist yet!"
        echo ""
        log_info "You need to obtain certificates first:"
        log_info "  1. Make sure DNS is configured: dig +short $DOMAIN"
        log_info "  2. Run: $0 --staging     (to test)"
        log_info "  3. Run: $0 --production  (to get real certs)"
        echo ""
        log_info "Reverting to HTTP-only configuration..."
        reset_to_http
        exit 1
    fi
    
    log_success "SSL certificates found"
    
    # Check if template exists
    if [ ! -f "$PROJECT_ROOT/nginx/nginx.prod.conf.template" ]; then
        log_error "nginx.prod.conf.template not found"
        exit 1
    fi
    
    # Generate production nginx config with SSL
    export DOMAIN
    envsubst '${DOMAIN}' < "$PROJECT_ROOT/nginx/nginx.prod.conf.template" > "$PROJECT_ROOT/nginx/nginx.conf"
    
    # Also copy proxy_params if it exists
    if [ -f "$PROJECT_ROOT/nginx/proxy_params_custom" ]; then
        docker cp "$PROJECT_ROOT/nginx/proxy_params_custom" nginx:/etc/nginx/proxy_params_custom 2>/dev/null || true
    fi
    
    # Reload nginx
    log_info "Reloading Nginx..."
    docker compose -f "$COMPOSE_FILE" exec nginx nginx -t && \
    docker compose -f "$COMPOSE_FILE" exec nginx nginx -s reload
    
    if [ $? -eq 0 ]; then
        log_success "Nginx configured with SSL"
        echo ""
        log_success "════════════════════════════════════════════════"
        log_success "  Your site is now available at:"
        log_success "  https://$DOMAIN"
        log_success "════════════════════════════════════════════════"
        echo ""
    else
        log_error "Failed to reload Nginx"
        log_info "Check nginx config: docker exec nginx nginx -t"
    fi
}

# ============================================
# Reset to HTTP-only Configuration
# ============================================
reset_to_http() {
    log_info "Applying HTTP-only nginx configuration..."
    
    if [ -f "$PROJECT_ROOT/nginx/nginx.initial.conf" ]; then
        cp "$PROJECT_ROOT/nginx/nginx.initial.conf" "$PROJECT_ROOT/nginx/nginx.conf"
        
        # Reload nginx with HTTP-only config
        docker compose -f "$COMPOSE_FILE" exec nginx nginx -t && \
        docker compose -f "$COMPOSE_FILE" exec nginx nginx -s reload
        
        if [ $? -eq 0 ]; then
            log_success "Nginx reset to HTTP-only mode"
        else
            log_warning "Could not reload nginx, may need to restart: docker compose -f docker-compose.prod.yml restart nginx"
        fi
    else
        log_warning "nginx.initial.conf not found"
    fi
}

# ============================================
# Setup Auto-Renewal
# ============================================
setup_renewal() {
    log_step "Setting up automatic certificate renewal..."
    
    # Create renewal script
    cat > "$PROJECT_ROOT/deploy/renew-certs.sh" << 'RENEWAL_SCRIPT'
#!/bin/bash
# Auto-renewal script for SSL certificates
# Runs via cron twice daily

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/var/log/certbot-renewal.log"

echo "$(date): Starting certificate renewal check" >> "$LOG_FILE"

cd "$PROJECT_ROOT"

# Attempt renewal
docker compose -f docker-compose.prod.yml run --rm certbot renew --quiet 2>&1 | tee -a "$LOG_FILE"

# Reload nginx if renewal was successful
if [ $? -eq 0 ]; then
    docker compose -f docker-compose.prod.yml exec -T nginx nginx -s reload 2>&1 | tee -a "$LOG_FILE"
    echo "$(date): Renewal check completed" >> "$LOG_FILE"
fi
RENEWAL_SCRIPT
    
    chmod +x "$PROJECT_ROOT/deploy/renew-certs.sh"
    
    # Add to crontab (run twice daily as recommended by Let's Encrypt)
    local cron_job="0 */12 * * * $PROJECT_ROOT/deploy/renew-certs.sh"
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "renew-certs.sh"; then
        log_info "Cron job already exists"
    else
        (crontab -l 2>/dev/null; echo "$cron_job") | crontab -
        log_success "Cron job added for automatic renewal (runs every 12 hours)"
    fi
}

# ============================================
# Check Certificate Status
# ============================================
check_status() {
    log_step "Checking SSL certificate status..."
    echo ""
    
    # List certificates
    docker compose -f "$COMPOSE_FILE" run --rm certbot certificates
    
    echo ""
    
    # Test HTTPS connection
    log_step "Testing HTTPS connection..."
    
    if curl -sI "https://$DOMAIN" --connect-timeout 10 2>/dev/null | head -1 | grep -qE "200|301|302"; then
        log_success "HTTPS is working!"
        
        # Show certificate info
        echo ""
        log_info "Certificate details:"
        echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null | \
            openssl x509 -noout -subject -issuer -dates 2>/dev/null || true
    else
        log_warning "Could not verify HTTPS connection"
        log_info "Certificate may not be configured in Nginx yet"
        log_info "Run: $0 --configure"
    fi
}

# ============================================
# Troubleshooting Guide
# ============================================
show_troubleshooting() {
    echo ""
    log_info "════════════════════════════════════════════════"
    log_info "  Troubleshooting Guide"
    log_info "════════════════════════════════════════════════"
    echo ""
    log_info "1. Check DNS: dig +short $DOMAIN"
    log_info "   → Should return your server's IP"
    echo ""
    log_info "2. Check firewall: sudo ufw status"
    log_info "   → Port 80 must be ALLOW"
    echo ""
    log_info "3. Test ACME challenge:"
    log_info "   curl http://$DOMAIN/.well-known/acme-challenge/test"
    log_info "   → Should return 'test' (or 404, not connection error)"
    echo ""
    log_info "4. Check nginx logs: docker logs nginx --tail 50"
    echo ""
    log_info "5. Check certbot logs:"
    log_info "   docker compose -f docker-compose.prod.yml run --rm certbot certificates"
    echo ""
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --staging      Generate staging/test certificate (not browser-trusted)"
    echo "  --production   Generate production certificate (browser-trusted)"
    echo "  --configure    Configure Nginx with existing certificates"
    echo "  --renew        Force certificate renewal"
    echo "  --status       Check certificate status"
    echo "  --help, -h     Show this help"
    echo ""
    echo "Recommended workflow:"
    echo "  1. Run staging test:  $0 --staging"
    echo "  2. If successful:     $0 --production"
    echo ""
    echo "Prerequisites:"
    echo "  - Domain must resolve to this server (DNS A record)"
    echo "  - Port 80 must be accessible from internet"
    echo "  - Services must be running (./deploy/deploy.sh)"
    echo ""
}

# ============================================
# Interactive Menu
# ============================================
interactive_menu() {
    echo "Interactive SSL Setup"
    echo ""
    echo "1) Generate staging certificate (for testing)"
    echo "2) Generate production certificate"
    echo "3) Check certificate status"
    echo "4) Configure Nginx with SSL"
    echo "5) Show troubleshooting guide"
    echo "6) Exit"
    echo ""
    read -p "Select option [1-6]: " option
    
    case $option in
        1)
            check_dns
            check_services
            generate_staging_cert
            ;;
        2)
            check_dns
            check_services
            generate_production_cert
            ;;
        3)
            check_status
            ;;
        4)
            configure_ssl
            ;;
        5)
            show_troubleshooting
            ;;
        *)
            log_info "Exiting..."
            exit 0
            ;;
    esac
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    load_env
    
    case "${1:-}" in
        --staging)
            check_dns
            check_services
            generate_staging_cert
            ;;
        --production)
            check_dns
            check_services
            generate_production_cert
            ;;
        --configure)
            configure_ssl
            ;;
        --reset)
            reset_to_http
            log_info "Now you can run: $0 --staging or $0 --production"
            ;;
        --renew)
            log_step "Forcing certificate renewal..."
            docker compose -f "$COMPOSE_FILE" run --rm certbot renew --force-renewal
            docker compose -f "$COMPOSE_FILE" exec nginx nginx -s reload
            log_success "Renewal complete"
            ;;
        --status)
            check_status
            ;;
        --troubleshoot)
            show_troubleshooting
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            interactive_menu
            ;;
    esac
}

# Run main function
main "$@"
