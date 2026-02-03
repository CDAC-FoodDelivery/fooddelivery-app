#!/bin/bash

# ============================================
# Food Delivery Application - Verification Script
# Comprehensive Deployment Verification
# ============================================
# This script verifies:
# - All services are running and healthy
# - API Gateway is accessible
# - Internal services are NOT exposed externally
# - SSL certificate is valid
# - All endpoints respond correctly
# ============================================

# Don't exit on error - we need to run all tests
set +e

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

# Test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0

# Server IP (will be set during init)
SERVER_IP=""
DOMAIN_RESOLVES_TO_SERVER=false

# ============================================
# Logging Functions
# ============================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[PASS]${NC} $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; TESTS_WARNED=$((TESTS_WARNED + 1)); }
log_error() { echo -e "${RED}[FAIL]${NC} $1"; TESTS_FAILED=$((TESTS_FAILED + 1)); }
log_step() { echo -e "${CYAN}[TEST]${NC} $1"; }

print_banner() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Verification"
    echo "============================================"
    echo ""
}

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    else
        log_warning ".env file not found"
        DOMAIN="localhost"
    fi
}

# ============================================
# Initialize - Get Server IP and Check DNS
# ============================================
initialize() {
    log_info "Initializing verification..."
    echo ""
    
    # Get server's public IP
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null)
    if [ -z "$SERVER_IP" ]; then
        SERVER_IP=$(curl -s --connect-timeout 5 icanhazip.com 2>/dev/null)
    fi
    if [ -z "$SERVER_IP" ]; then
        SERVER_IP=$(curl -s --connect-timeout 5 ipinfo.io/ip 2>/dev/null)
    fi
    
    if [ -n "$SERVER_IP" ]; then
        log_info "Server public IP: $SERVER_IP"
    else
        log_warning "Could not determine server's public IP"
        SERVER_IP="127.0.0.1"
    fi
    
    # Check if domain resolves to this server
    if [ "$DOMAIN" != "localhost" ]; then
        DOMAIN_IP=$(dig +short "$DOMAIN" 2>/dev/null | tail -1)
        
        if [ -n "$DOMAIN_IP" ]; then
            log_info "Domain $DOMAIN resolves to: $DOMAIN_IP"
            
            if [ "$DOMAIN_IP" = "$SERVER_IP" ]; then
                DOMAIN_RESOLVES_TO_SERVER=true
                log_success "DNS is correctly configured"
            else
                log_warning "Domain resolves to different IP than this server"
                log_info "Expected: $SERVER_IP, Got: $DOMAIN_IP"
            fi
        else
            log_warning "Domain $DOMAIN does not resolve (DNS not configured yet)"
        fi
    fi
    echo ""
}

# ============================================
# Test Container Status
# ============================================
test_containers() {
    echo ""
    echo "============================================"
    echo "   Container Status Tests"
    echo "============================================"
    echo ""
    
    local services=("mysql" "discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend" "nginx")
    
    for service in "${services[@]}"; do
        local status=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "not found")
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "n/a")
        
        if [ "$status" = "running" ]; then
            if [ "$health" = "healthy" ] || [ "$health" = "n/a" ]; then
                log_success "$service is running (health: $health)"
            else
                log_warning "$service is running but health: $health"
            fi
        else
            log_error "$service is not running (status: $status)"
        fi
    done
}

# ============================================
# Test Local Access (Internal to Server)
# ============================================
test_local_access() {
    echo ""
    echo "============================================"
    echo "   Local Access Tests (via Docker network)"
    echo "============================================"
    echo ""
    
    log_step "Testing services locally via Docker exec..."
    
    # Test nginx from inside Docker network
    local nginx_local=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" http://localhost/ 2>/dev/null || echo "fail")
    if [ "$nginx_local" = "200" ] || [ "$nginx_local" = "301" ]; then
        log_success "Nginx serving frontend locally (code: $nginx_local)"
    else
        log_error "Nginx not serving frontend locally (code: $nginx_local)"
    fi
    
    # Test API Gateway from inside Docker
    local api_local=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" http://api-gateway:8080/actuator/health 2>/dev/null || echo "fail")
    if [ "$api_local" = "200" ]; then
        log_success "API Gateway accessible within Docker network"
    else
        log_warning "API Gateway not responding (code: $api_local)"
    fi
    
    # Test frontend nginx health endpoint
    local frontend_health=$(docker exec frontend curl -s -o /dev/null -w "%{http_code}" http://localhost/health 2>/dev/null || echo "fail")
    if [ "$frontend_health" = "200" ]; then
        log_success "Frontend health endpoint working"
    else
        log_warning "Frontend health endpoint not responding (code: $frontend_health)"
    fi
}

# ============================================
# Test Public Access (Should Work)
# ============================================
test_public_access() {
    echo ""
    echo "============================================"
    echo "   Public Access Tests"
    echo "============================================"
    echo ""
    
    # First check if DNS is set up
    if [ "$DOMAIN_RESOLVES_TO_SERVER" != "true" ]; then
        log_warning "Skipping domain-based tests - DNS not configured"
        log_info "Configure an A record for $DOMAIN → $SERVER_IP"
        log_info "Testing via IP instead..."
        echo ""
        
        # Test via IP
        local ip_http=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$SERVER_IP" 2>/dev/null || echo "000")
        if [ "$ip_http" = "200" ] || [ "$ip_http" = "301" ] || [ "$ip_http" = "302" ]; then
            log_success "Frontend accessible via IP http://$SERVER_IP (code: $ip_http)"
        elif [ "$ip_http" = "000" ]; then
            log_error "Cannot connect to http://$SERVER_IP"
            log_info "Check if firewall allows port 80: sudo ufw status"
        else
            log_warning "Frontend returned unexpected code via IP: $ip_http"
        fi
        return
    fi
    
    log_step "Testing frontend access via $DOMAIN..."
    
    # Test HTTP
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "301" ] || [ "$http_code" = "302" ]; then
        log_success "Frontend HTTP accessible (code: $http_code)"
    elif [ "$http_code" = "000" ]; then
        log_error "Cannot connect to http://$DOMAIN"
        log_info "Possible causes:"
        log_info "  1. Firewall blocking port 80"
        log_info "  2. Nginx not responding"
        log_info "  Run: sudo ufw status && docker logs nginx --tail 20"
    else
        log_error "Frontend HTTP returned: $http_code"
    fi
    
    # Test HTTPS (only if SSL configured)
    if grep -q "ssl_certificate" "$PROJECT_ROOT/nginx/nginx.conf" 2>/dev/null; then
        local https_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 -k "https://$DOMAIN" 2>/dev/null || echo "000")
        
        if [ "$https_code" = "200" ]; then
            log_success "Frontend HTTPS accessible (code: $https_code)"
        elif [ "$https_code" = "000" ]; then
            log_error "Cannot connect to https://$DOMAIN"
        else
            log_warning "Frontend HTTPS returned: $https_code"
        fi
    else
        log_info "HTTPS not configured yet - run ./deploy/setup-ssl.sh"
    fi
    
    log_step "Testing API Gateway access..."
    
    local api_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$DOMAIN/api/hotels" 2>/dev/null || echo "000")
    
    if [ "$api_code" = "200" ]; then
        log_success "API Gateway accessible (code: $api_code)"
    elif [ "$api_code" = "401" ] || [ "$api_code" = "403" ]; then
        log_success "API Gateway responding (auth required)"
    elif [ "$api_code" = "000" ]; then
        # Don't double count if we already failed HTTP
        if [ "$http_code" != "000" ]; then
            log_warning "API endpoint not responding"
        fi
    else
        log_warning "API Gateway returned: $api_code"
    fi
}

# ============================================
# Test Internal Services NOT Exposed
# ============================================
test_internal_not_exposed() {
    echo ""
    echo "============================================"
    echo "   Security Tests (Internal Services)"
    echo "============================================"
    echo ""
    
    log_step "Verifying internal services are NOT accessible from outside..."
    echo ""
    
    # We need to test from outside - if we're on the server, 
    # we use nc (netcat) with a timeout to check if ports are open
    # A port is "exposed" if we can establish a TCP connection to it
    
    # List of internal ports that should NOT be accessible externally
    declare -A internal_ports=(
        ["8761"]="Discovery Server"
        ["8080"]="API Gateway Direct"
        ["9081"]="Auth Service"
        ["9082"]="Hotel Service"
        ["9083"]="Menu Service"
        ["9086"]="Admin Rider Service"
        ["3306"]="MySQL"
        ["3307"]="MySQL (mapped)"
    )
    
    # Use netcat to test if port is open from external perspective
    # If we're ON the server, we simulate external by checking if Docker
    # exposes the port to the host
    
    for port in "${!internal_ports[@]}"; do
        local service="${internal_ports[$port]}"
        
        # Check if port is bound on the host (exposed)
        # ss -tuln will show listening ports
        if ss -tuln 2>/dev/null | grep -q ":$port " ; then
            log_error "$service (port $port) IS exposed on host! Should be internal only."
        else
            log_success "$service (port $port) is NOT exposed externally"
        fi
    done
    
    echo ""
    log_info "Only ports 80 and 443 should be exposed (via nginx)"
    
    # Verify nginx ports ARE exposed
    if ss -tuln 2>/dev/null | grep -q ":80 " ; then
        log_success "Port 80 (HTTP) is correctly exposed"
    else
        log_error "Port 80 (HTTP) is NOT exposed! Nginx may not be running."
    fi
    
    if ss -tuln 2>/dev/null | grep -q ":443 " ; then
        log_success "Port 443 (HTTPS) is correctly exposed"
    else
        log_info "Port 443 (HTTPS) not exposed (SSL not configured yet)"
    fi
}

# ============================================
# Test SSL Certificate
# ============================================
test_ssl() {
    echo ""
    echo "============================================"
    echo "   SSL Certificate Tests"
    echo "============================================"
    echo ""
    
    log_step "Checking SSL certificate..."
    
    # Check if SSL is configured in nginx
    if ! grep -q "ssl_certificate" "$PROJECT_ROOT/nginx/nginx.conf" 2>/dev/null; then
        log_info "SSL not configured yet"
        log_info "Run: ./deploy/setup-ssl.sh --production"
        return
    fi
    
    # Check if HTTPS is working
    local https_accessible=false
    if [ "$DOMAIN_RESOLVES_TO_SERVER" = "true" ]; then
        if curl -sI "https://$DOMAIN" --connect-timeout 10 -k 2>/dev/null | head -1 | grep -qE "200|301|302"; then
            https_accessible=true
            log_success "HTTPS connection successful"
        fi
    fi
    
    if [ "$https_accessible" = "true" ]; then
        # Get certificate info
        CERT_INFO=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:443" 2>/dev/null)
        
        if [ -n "$CERT_INFO" ]; then
            # Check expiry
            EXPIRY=$(echo "$CERT_INFO" | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
            
            if [ -n "$EXPIRY" ]; then
                EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s 2>/dev/null || echo "0")
                NOW_EPOCH=$(date +%s)
                DAYS_LEFT=$(( (EXPIRY_EPOCH - NOW_EPOCH) / 86400 ))
                
                if [ "$DAYS_LEFT" -gt 30 ]; then
                    log_success "SSL certificate valid for $DAYS_LEFT more days"
                elif [ "$DAYS_LEFT" -gt 7 ]; then
                    log_warning "SSL certificate expires in $DAYS_LEFT days"
                elif [ "$DAYS_LEFT" -gt 0 ]; then
                    log_error "SSL certificate expires in $DAYS_LEFT days! Renew immediately!"
                else
                    log_error "SSL certificate has EXPIRED!"
                fi
            fi
        fi
    else
        if [ "$DOMAIN_RESOLVES_TO_SERVER" = "true" ]; then
            log_warning "HTTPS not accessible"
        else
            log_info "Cannot test SSL - DNS not configured"
        fi
    fi
}

# ============================================
# Test API Endpoints
# ============================================
test_api_endpoints() {
    echo ""
    echo "============================================"
    echo "   API Endpoint Tests"
    echo "============================================"
    echo ""
    
    # Test internally via Docker to avoid DNS issues
    log_info "Testing API endpoints via Docker network..."
    echo ""
    
    # Test via nginx container calling API gateway
    local hotels=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" "http://api-gateway:8080/api/hotels" 2>/dev/null || echo "fail")
    if [ "$hotels" = "200" ]; then
        log_success "Hotels API: OK (200)"
    elif [ "$hotels" = "401" ]; then
        log_success "Hotels API: Protected (requires auth)"
    else
        log_warning "Hotels API: Returned $hotels"
    fi
    
    local auth_health=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" "http://auth-service:9081/actuator/health" 2>/dev/null || echo "fail")
    if [ "$auth_health" = "200" ]; then
        log_success "Auth Service Health: OK (200)"
    else
        log_warning "Auth Service Health: Returned $auth_health"
    fi
    
    local hotel_health=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" "http://hotel-service:9082/actuator/health" 2>/dev/null || echo "fail")
    if [ "$hotel_health" = "200" ]; then
        log_success "Hotel Service Health: OK (200)"
    else
        log_warning "Hotel Service Health: Returned $hotel_health"
    fi
    
    local menu_health=$(docker exec nginx curl -s -o /dev/null -w "%{http_code}" "http://menu-service:9083/actuator/health" 2>/dev/null || echo "fail")
    if [ "$menu_health" = "200" ]; then
        log_success "Menu Service Health: OK (200)"
    else
        log_warning "Menu Service Health: Returned $menu_health"
    fi
}

# ============================================
# Test Database Connection
# ============================================
test_database() {
    echo ""
    echo "============================================"
    echo "   Database Tests"
    echo "============================================"
    echo ""
    
    log_step "Testing database connectivity..."
    
    # Test MySQL ping
    if docker exec mysql mysqladmin ping -u root -p"${MYSQL_ROOT_PASSWORD:-root}" --silent 2>/dev/null; then
        log_success "MySQL is responding"
        
        # Check databases exist
        DBS=$(docker exec mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -N -e "SELECT COUNT(*) FROM information_schema.SCHEMATA WHERE SCHEMA_NAME LIKE 'fooddelivery%';" 2>/dev/null | tr -d '[:space:]')
        
        if [ "$DBS" -ge 4 ] 2>/dev/null; then
            log_success "All $DBS application databases exist"
        elif [ -n "$DBS" ]; then
            log_warning "Only $DBS application databases found (expected 4)"
        else
            log_warning "Could not count databases"
        fi
    else
        log_error "MySQL is not responding"
    fi
}

# ============================================
# Test Service Discovery
# ============================================
test_service_discovery() {
    echo ""
    echo "============================================"
    echo "   Service Discovery Tests"
    echo "============================================"
    echo ""
    
    log_step "Checking Eureka service registry..."
    
    # Check Eureka (internal)
    local eureka_apps=$(docker exec discovery-server wget -q -O - http://localhost:8761/eureka/apps 2>/dev/null | grep -c "<application>" || echo "0")
    
    if [ "$eureka_apps" -gt 0 ]; then
        log_success "Eureka has $eureka_apps registered service(s)"
        
        # List registered services
        log_info "Registered services:"
        docker exec discovery-server wget -q -O - http://localhost:8761/eureka/apps 2>/dev/null | grep -oP '(?<=<name>)[^<]+' | sort -u | while read svc; do
            echo "    - $svc"
        done
    else
        log_warning "No services registered in Eureka yet"
    fi
}

# ============================================
# Generate Report
# ============================================
generate_report() {
    echo ""
    echo "============================================"
    echo "   Verification Summary"
    echo "============================================"
    echo ""
    
    local total=$((TESTS_PASSED + TESTS_FAILED + TESTS_WARNED))
    
    echo -e "  ${GREEN}Passed:${NC}  $TESTS_PASSED"
    echo -e "  ${RED}Failed:${NC}  $TESTS_FAILED"
    echo -e "  ${YELLOW}Warnings:${NC} $TESTS_WARNED"
    echo "  ─────────────────"
    echo "  Total:   $total"
    echo ""
    
    if [ "$TESTS_FAILED" -eq 0 ]; then
        if [ "$TESTS_WARNED" -eq 0 ]; then
            echo -e "  ${GREEN}✓ All tests passed!${NC}"
        else
            echo -e "  ${YELLOW}✓ Deployment OK with warnings${NC}"
        fi
        echo ""
        
        if [ "$DOMAIN_RESOLVES_TO_SERVER" = "true" ]; then
            echo "  Your application is accessible at:"
            if grep -q "ssl_certificate" "$PROJECT_ROOT/nginx/nginx.conf" 2>/dev/null; then
                echo "  → https://$DOMAIN"
            else
                echo "  → http://$DOMAIN"
                echo ""
                echo "  To enable HTTPS, run:"
                echo "  → ./deploy/setup-ssl.sh --production"
            fi
        else
            echo "  Application is running but DNS not configured."
            echo ""
            echo "  Next steps:"
            echo "  1. Add A record: $DOMAIN → $SERVER_IP"
            echo "  2. Wait for DNS propagation"
            echo "  3. Run: ./deploy/setup-ssl.sh --production"
            echo ""
            echo "  You can test now via IP: http://$SERVER_IP"
        fi
    else
        echo -e "  ${RED}✗ $TESTS_FAILED test(s) failed${NC}"
        echo ""
        echo "  Troubleshooting:"
        echo "  → Check logs: ./deploy/logs.sh --errors"
        echo "  → Health check: ./deploy/health-check.sh"
        echo "  → Restart services: docker compose -f docker-compose.prod.yml restart"
    fi
    echo ""
}

# ============================================
# Quick Test
# ============================================
quick_test() {
    log_info "Running quick verification..."
    
    test_containers
    test_local_access
    generate_report
}

# ============================================
# Full Test
# ============================================
full_test() {
    log_info "Running full verification..."
    
    test_containers
    test_local_access
    test_public_access
    test_internal_not_exposed
    test_ssl
    test_api_endpoints
    test_database
    test_service_discovery
    generate_report
}

# ============================================
# Security Audit
# ============================================
security_audit() {
    echo ""
    echo "============================================"
    echo "   Security Audit"
    echo "============================================"
    echo ""
    
    test_internal_not_exposed
    test_ssl
    
    # Additional security checks via Docker
    log_step "Checking security headers..."
    
    # Get headers from nginx internally
    HEADERS=$(docker exec nginx curl -sI http://localhost/ 2>/dev/null)
    
    if echo "$HEADERS" | grep -qi "X-Frame-Options"; then
        log_success "X-Frame-Options header present"
    else
        log_warning "X-Frame-Options header missing"
    fi
    
    if echo "$HEADERS" | grep -qi "X-Content-Type-Options"; then
        log_success "X-Content-Type-Options header present"
    else
        log_warning "X-Content-Type-Options header missing"
    fi
    
    if echo "$HEADERS" | grep -qi "X-XSS-Protection"; then
        log_success "X-XSS-Protection header present"
    else
        log_warning "X-XSS-Protection header missing"
    fi
    
    generate_report
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --quick, -q      Quick verification (containers + local access)"
    echo "  --full, -f       Full verification (all tests)"
    echo "  --security, -s   Security-focused audit"
    echo "  --containers     Test containers only"
    echo "  --ssl            Test SSL only"
    echo "  --api            Test API endpoints only"
    echo "  --help, -h       Show this help message"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    load_env
    initialize
    
    case "${1:-}" in
        --quick|-q)
            quick_test
            ;;
        --full|-f)
            full_test
            ;;
        --security|-s)
            security_audit
            ;;
        --containers)
            test_containers
            generate_report
            ;;
        --ssl)
            test_ssl
            generate_report
            ;;
        --api)
            test_api_endpoints
            generate_report
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            full_test
            ;;
    esac
    
    # Exit with error code if tests failed
    if [ "$TESTS_FAILED" -gt 0 ]; then
        exit 1
    fi
}

# Run main function
main "$@"
