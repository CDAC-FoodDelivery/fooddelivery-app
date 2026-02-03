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

set -e  # Exit on error (but we'll handle errors manually for checks)

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
# Get Server IP
# ============================================
get_server_ip() {
    SERVER_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || \
                curl -s --connect-timeout 5 icanhazip.com 2>/dev/null || \
                hostname -I 2>/dev/null | awk '{print $1}' || \
                echo "127.0.0.1")
    echo "$SERVER_IP"
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
# Test Public Access (Should Work)
# ============================================
test_public_access() {
    echo ""
    echo "============================================"
    echo "   Public Access Tests"
    echo "============================================"
    echo ""
    
    log_step "Testing frontend access..."
    
    # Test HTTP (should redirect or work)
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "301" ] || [ "$http_code" = "302" ]; then
        log_success "Frontend HTTP accessible (code: $http_code)"
    else
        log_error "Frontend HTTP not accessible (code: $http_code)"
    fi
    
    # Test HTTPS
    local https_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 -k "https://$DOMAIN" 2>/dev/null || echo "000")
    
    if [ "$https_code" = "200" ]; then
        log_success "Frontend HTTPS accessible (code: $https_code)"
    elif [ "$https_code" = "000" ]; then
        log_warning "Frontend HTTPS not accessible (SSL may not be configured yet)"
    else
        log_error "Frontend HTTPS issue (code: $https_code)"
    fi
    
    log_step "Testing API Gateway access..."
    
    # Test API health via public domain
    local api_health=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "http://$DOMAIN/api/hotels" 2>/dev/null || echo "000")
    
    if [ "$api_health" = "200" ] || [ "$api_health" = "401" ] || [ "$api_health" = "403" ]; then
        log_success "API Gateway accessible via public domain (code: $api_health)"
    elif [ "$api_health" = "000" ]; then
        log_error "API Gateway not accessible"
    else
        log_warning "API Gateway returned unexpected code: $api_health"
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
    
    log_step "Verifying internal services are NOT accessible externally..."
    echo ""
    
    local server_ip=$(get_server_ip)
    
    # List of internal ports that should NOT be accessible
    local internal_ports=(
        "8761:Discovery Server"
        "8080:API Gateway"
        "9081:Auth Service"
        "9082:Hotel Service"
        "9083:Menu Service"
        "9086:Admin Rider Service"
        "3306:MySQL"
        "3307:MySQL (mapped)"
    )
    
    for port_info in "${internal_ports[@]}"; do
        local port="${port_info%%:*}"
        local service="${port_info##*:}"
        
        # Try to connect to the port
        local result=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://$server_ip:$port" 2>/dev/null || echo "000")
        
        if [ "$result" = "000" ]; then
            log_success "$service (port $port) is NOT exposed externally"
        else
            log_error "$service (port $port) IS exposed externally! (code: $result)"
        fi
    done
    
    echo ""
    log_info "Note: Only ports 80 and 443 should be exposed"
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
    
    # Check if HTTPS is working
    if curl -sI "https://$DOMAIN" --connect-timeout 10 2>/dev/null | head -1 | grep -qE "200|301|302"; then
        log_success "HTTPS connection successful"
        
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
                
                # Check issuer
                ISSUER=$(echo "$CERT_INFO" | openssl x509 -noout -issuer 2>/dev/null | sed 's/issuer=//')
                if echo "$ISSUER" | grep -qi "Let's Encrypt"; then
                    log_success "Certificate issued by Let's Encrypt"
                else
                    log_info "Certificate issuer: $ISSUER"
                fi
            fi
        fi
    else
        log_warning "HTTPS not accessible or not configured yet"
        log_info "Run: ./deploy/setup-ssl.sh --production"
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
    
    local base_url="http://$DOMAIN"
    
    # Use HTTPS if available
    if curl -sI "https://$DOMAIN" --connect-timeout 5 2>/dev/null | head -1 | grep -q "200"; then
        base_url="https://$DOMAIN"
    fi
    
    log_info "Testing endpoints at: $base_url"
    echo ""
    
    # Define endpoints to test
    local endpoints=(
        "/api/hotels:Hotels List"
        "/api/auth/health:Auth Health"
        "/health:Nginx Health"
    )
    
    for endpoint_info in "${endpoints[@]}"; do
        local endpoint="${endpoint_info%%:*}"
        local name="${endpoint_info##*:}"
        
        local result=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 "${base_url}${endpoint}" 2>/dev/null || echo "000")
        
        if [ "$result" = "200" ]; then
            log_success "$name: OK (200)"
        elif [ "$result" = "401" ] || [ "$result" = "403" ]; then
            log_success "$name: Protected endpoint (needs auth)"
        elif [ "$result" = "000" ]; then
            log_error "$name: Connection failed"
        else
            log_warning "$name: Returned code $result"
        fi
    done
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
        DBS=$(docker exec mysql mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "SHOW DATABASES LIKE 'fooddelivery%';" 2>/dev/null | tail -n +2 | wc -l)
        
        if [ "$DBS" -ge 4 ]; then
            log_success "All $DBS application databases exist"
        else
            log_warning "Only $DBS application databases found (expected 4)"
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
        echo "  Your application is accessible at:"
        if curl -sI "https://$DOMAIN" --connect-timeout 5 2>/dev/null | head -1 | grep -q "200"; then
            echo "  → https://$DOMAIN"
        else
            echo "  → http://$DOMAIN"
            echo ""
            echo "  To enable HTTPS, run:"
            echo "  → ./deploy/setup-ssl.sh --production"
        fi
    else
        echo -e "  ${RED}✗ $TESTS_FAILED test(s) failed${NC}"
        echo ""
        echo "  Troubleshooting:"
        echo "  → Check logs: ./deploy/logs.sh"
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
    
    # Just test basic access
    test_containers
    test_public_access
    generate_report
}

# ============================================
# Full Test
# ============================================
full_test() {
    log_info "Running full verification..."
    
    test_containers
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
    
    # Additional security checks
    log_step "Checking security headers..."
    
    HEADERS=$(curl -sI "http://$DOMAIN" 2>/dev/null)
    
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
    echo "  --quick, -q      Quick verification (containers + access)"
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
