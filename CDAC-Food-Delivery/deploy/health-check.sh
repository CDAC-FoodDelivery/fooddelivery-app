#!/bin/bash

# ============================================
# Food Delivery Application - Health Check
# Service Health Monitoring Utility
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ============================================
# Check Container Health
# ============================================
check_containers() {
    echo ""
    echo "============================================"
    echo "   Container Status"
    echo "============================================"
    echo ""
    
    local services=("nginx" "mysql" "discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend")
    
    printf "%-25s %-12s %-15s\n" "SERVICE" "STATUS" "HEALTH"
    printf "%-25s %-12s %-15s\n" "-------" "------" "------"
    
    for service in "${services[@]}"; do
        local status=$(docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null || echo "not found")
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$service" 2>/dev/null || echo "n/a")
        
        # Color coding
        case $status in
            "running") status_color="${GREEN}${status}${NC}" ;;
            "exited"|"dead") status_color="${RED}${status}${NC}" ;;
            *) status_color="${YELLOW}${status}${NC}" ;;
        esac
        
        case $health in
            "healthy") health_color="${GREEN}${health}${NC}" ;;
            "unhealthy") health_color="${RED}${health}${NC}" ;;
            "starting") health_color="${YELLOW}${health}${NC}" ;;
            *) health_color="${BLUE}${health}${NC}" ;;
        esac
        
        printf "%-25s %-12b %-15b\n" "$service" "$status_color" "$health_color"
    done
    
    echo ""
}

# ============================================
# Check Service Endpoints
# ============================================
check_endpoints() {
    echo ""
    echo "============================================"
    echo "   Service Endpoint Checks"
    echo "============================================"
    echo ""
    
    # Load domain from env
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi
    
    local domain="${DOMAIN:-localhost}"
    
    # Define endpoints to check
    local endpoints=(
        "Frontend|http://localhost:80"
        "API Gateway|http://localhost:8080/actuator/health"
        "Discovery Server|http://localhost:8761"
        "Auth Service|http://localhost:9081/actuator/health"
        "Hotel Service|http://localhost:9082/actuator/health"
        "Menu Service|http://localhost:9083/actuator/health"
        "Admin Service|http://localhost:9086/health"
    )
    
    printf "%-20s %-40s %-10s\n" "SERVICE" "URL" "STATUS"
    printf "%-20s %-40s %-10s\n" "-------" "---" "------"
    
    for ep in "${endpoints[@]}"; do
        IFS='|' read -r name url <<< "$ep"
        
        local response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" 2>/dev/null || echo "000")
        
        if [ "$response" = "200" ] || [ "$response" = "301" ] || [ "$response" = "302" ]; then
            printf "%-20s %-40s ${GREEN}%-10s${NC}\n" "$name" "$url" "OK ($response)"
        elif [ "$response" = "000" ]; then
            printf "%-20s %-40s ${RED}%-10s${NC}\n" "$name" "$url" "UNREACHABLE"
        else
            printf "%-20s %-40s ${YELLOW}%-10s${NC}\n" "$name" "$url" "HTTP $response"
        fi
    done
    
    echo ""
}

# ============================================
# Check Database Connection
# ============================================
check_database() {
    echo ""
    echo "============================================"
    echo "   Database Status"
    echo "============================================"
    echo ""
    
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi
    
    # Use root credentials for admin operations
    local user="root"
    local pass="${MYSQL_ROOT_PASSWORD:-root}"
    
    # Check MySQL is responding
    if docker exec mysql mysqladmin ping -u"$user" -p"$pass" --silent 2>/dev/null; then
        echo -e "MySQL Connection: ${GREEN}OK${NC}"
    else
        echo -e "MySQL Connection: ${RED}FAILED${NC}"
        return 1
    fi
    
    echo ""
    echo "Databases:"
    docker exec mysql mysql -u"$user" -p"$pass" -e "SHOW DATABASES LIKE 'fooddelivery%';" 2>/dev/null | tail -n +2
    
    echo ""
}

# ============================================
# Check SSL Certificate
# ============================================
check_ssl() {
    echo ""
    echo "============================================"
    echo "   SSL Certificate Status"
    echo "============================================"
    echo ""
    
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi
    
    local domain="${DOMAIN:-localhost}"
    
    # Check if HTTPS is working
    if curl -sI "https://$domain" --connect-timeout 5 2>/dev/null | head -1 | grep -q "200\|301\|302"; then
        echo -e "HTTPS Status: ${GREEN}Working${NC}"
        
        # Get certificate info
        echo ""
        echo "Certificate Details:"
        echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | \
            openssl x509 -noout -subject -dates -issuer 2>/dev/null | sed 's/^/  /'
        
        # Check expiry
        local expiry=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | \
            openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
        
        if [ -n "$expiry" ]; then
            local expiry_epoch=$(date -d "$expiry" +%s 2>/dev/null || echo "0")
            local now_epoch=$(date +%s)
            local days_left=$(( (expiry_epoch - now_epoch) / 86400 ))
            
            if [ "$days_left" -lt 7 ]; then
                echo -e "\n  ${RED}WARNING: Certificate expires in $days_left days!${NC}"
            elif [ "$days_left" -lt 30 ]; then
                echo -e "\n  ${YELLOW}Certificate expires in $days_left days${NC}"
            else
                echo -e "\n  ${GREEN}Certificate valid for $days_left more days${NC}"
            fi
        fi
    else
        echo -e "HTTPS Status: ${YELLOW}Not configured or unreachable${NC}"
        echo "Run ./deploy/setup-ssl.sh to configure SSL"
    fi
    
    echo ""
}

# ============================================
# Check Resource Usage
# ============================================
check_resources() {
    echo ""
    echo "============================================"
    echo "   Resource Usage"
    echo "============================================"
    echo ""
    
    docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null | \
        grep -E "^(NAME|nginx|mysql|discovery|api-gateway|auth|hotel|menu|admin|frontend)"
    
    echo ""
}

# ============================================
# Check Logs for Errors
# ============================================
check_logs() {
    local service="${1:-}"
    local lines="${2:-50}"
    
    echo ""
    echo "============================================"
    echo "   Recent Logs (last $lines lines)"
    echo "============================================"
    echo ""
    
    if [ -n "$service" ]; then
        docker logs --tail "$lines" "$service" 2>&1
    else
        echo "Recent errors across all services:"
        echo ""
        
        local services=("api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service")
        
        for svc in "${services[@]}"; do
            local errors=$(docker logs --tail 100 "$svc" 2>&1 | grep -i "error\|exception\|failed" | tail -5)
            if [ -n "$errors" ]; then
                echo "[$svc]"
                echo "$errors"
                echo ""
            fi
        done
    fi
}

# ============================================
# Full Health Report
# ============================================
full_report() {
    check_containers
    check_endpoints
    check_database
    check_ssl
    check_resources
}

# ============================================
# Main
# ============================================
main() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Health Check"
    echo "============================================"
    
    case "${1:-}" in
        --containers|-c)
            check_containers
            ;;
        --endpoints|-e)
            check_endpoints
            ;;
        --database|--db)
            check_database
            ;;
        --ssl)
            check_ssl
            ;;
        --resources|-r)
            check_resources
            ;;
        --logs|-l)
            check_logs "$2" "$3"
            ;;
        --full|-f)
            full_report
            ;;
        --help|-h)
            echo ""
            echo "Usage: $0 [option]"
            echo ""
            echo "Options:"
            echo "  --containers, -c   Check container status"
            echo "  --endpoints, -e    Check service endpoints"
            echo "  --database, --db   Check database connection"
            echo "  --ssl              Check SSL certificate"
            echo "  --resources, -r    Check resource usage"
            echo "  --logs, -l [SVC]   View recent logs (optional: service name)"
            echo "  --full, -f         Full health report"
            echo "  --help, -h         Show this help"
            echo ""
            exit 0
            ;;
        *)
            full_report
            ;;
    esac
}

main "$@"
