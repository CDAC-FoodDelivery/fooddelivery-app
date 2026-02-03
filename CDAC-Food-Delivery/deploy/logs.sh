#!/bin/bash

# ============================================
# Food Delivery Application - Logs Utility
# Centralized Log Viewing Tool
# ============================================
# This script provides:
# - View logs from all services
# - Filter by service name
# - Follow mode (tail)
# - Search/grep functionality
# - Export logs to file
# ============================================

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
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.prod.yml"
LOGS_DIR="$PROJECT_ROOT/logs"

# All services
ALL_SERVICES=("mysql" "discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend" "nginx" "certbot")

# Backend services only
BACKEND_SERVICES=("api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service")

# ============================================
# Logging Functions
# ============================================
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

print_banner() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Log Viewer"
    echo "============================================"
    echo ""
}

# ============================================
# View Logs for Single Service
# ============================================
view_service_logs() {
    local service="$1"
    local lines="${2:-100}"
    local follow="${3:-false}"
    
    if [ "$follow" = true ]; then
        docker logs -f "$service" 2>&1
    else
        docker logs --tail "$lines" "$service" 2>&1
    fi
}

# ============================================
# View All Logs (Interleaved)
# ============================================
view_all_logs() {
    local lines="${1:-50}"
    local follow="${2:-false}"
    
    if [ "$follow" = true ]; then
        docker compose -f "$COMPOSE_FILE" logs -f
    else
        docker compose -f "$COMPOSE_FILE" logs --tail "$lines"
    fi
}

# ============================================
# View Backend Logs Only
# ============================================
view_backend_logs() {
    local lines="${1:-50}"
    local follow="${2:-false}"
    
    if [ "$follow" = true ]; then
        docker compose -f "$COMPOSE_FILE" logs -f "${BACKEND_SERVICES[@]}"
    else
        docker compose -f "$COMPOSE_FILE" logs --tail "$lines" "${BACKEND_SERVICES[@]}"
    fi
}

# ============================================
# Search Logs
# ============================================
search_logs() {
    local pattern="$1"
    local service="${2:-}"
    local lines="${3:-500}"
    
    if [ -z "$pattern" ]; then
        log_error "Please provide a search pattern"
        echo "Usage: $0 --search 'pattern' [service]"
        exit 1
    fi
    
    echo ""
    log_info "Searching for: '$pattern'"
    echo ""
    
    if [ -n "$service" ]; then
        docker logs --tail "$lines" "$service" 2>&1 | grep -i --color=always "$pattern" || echo "No matches found in $service"
    else
        for svc in "${ALL_SERVICES[@]}"; do
            local matches=$(docker logs --tail "$lines" "$svc" 2>&1 | grep -i "$pattern" 2>/dev/null | head -10)
            if [ -n "$matches" ]; then
                echo -e "${CYAN}[$svc]${NC}"
                echo "$matches" | grep -i --color=always "$pattern"
                echo ""
            fi
        done
    fi
}

# ============================================
# View Errors Only
# ============================================
view_errors() {
    local lines="${1:-200}"
    
    echo ""
    log_info "Showing errors and exceptions from all services..."
    echo ""
    
    for service in "${BACKEND_SERVICES[@]}"; do
        local errors=$(docker logs --tail "$lines" "$service" 2>&1 | grep -iE "error|exception|failed|fatal" | tail -10)
        if [ -n "$errors" ]; then
            echo -e "${RED}[$service]${NC}"
            echo "$errors"
            echo ""
        fi
    done
    
    # Also check nginx
    local nginx_errors=$(docker logs --tail "$lines" nginx 2>&1 | grep -iE "error|warn" | tail -5)
    if [ -n "$nginx_errors" ]; then
        echo -e "${RED}[nginx]${NC}"
        echo "$nginx_errors"
        echo ""
    fi
}

# ============================================
# Export Logs to File
# ============================================
export_logs() {
    local service="${1:-all}"
    local lines="${2:-1000}"
    
    mkdir -p "$LOGS_DIR"
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="$LOGS_DIR/${service}_logs_$timestamp.log"
    
    log_info "Exporting logs to: $output_file"
    
    if [ "$service" = "all" ]; then
        docker compose -f "$COMPOSE_FILE" logs --tail "$lines" > "$output_file" 2>&1
    else
        docker logs --tail "$lines" "$service" > "$output_file" 2>&1
    fi
    
    if [ -f "$output_file" ]; then
        local size=$(du -h "$output_file" | cut -f1)
        log_info "Exported $size to $output_file"
    fi
}

# ============================================
# Live Statistics View
# ============================================
live_stats() {
    log_info "Showing live log statistics (Ctrl+C to exit)..."
    echo ""
    
    while true; do
        clear
        echo "============================================"
        echo "   Live Log Statistics - $(date +%H:%M:%S)"
        echo "============================================"
        echo ""
        
        printf "%-25s %10s %10s %10s\n" "SERVICE" "LOGS" "ERRORS" "WARNS"
        printf "%-25s %10s %10s %10s\n" "───────" "────" "──────" "─────"
        
        for service in "${ALL_SERVICES[@]}"; do
            if docker inspect "$service" &>/dev/null; then
                local total=$(docker logs --tail 100 "$service" 2>&1 | wc -l)
                local errors=$(docker logs --tail 100 "$service" 2>&1 | grep -ciE "error|exception|failed" || echo "0")
                local warns=$(docker logs --tail 100 "$service" 2>&1 | grep -ci "warn" || echo "0")
                
                if [ "$errors" -gt 0 ]; then
                    printf "%-25s %10s ${RED}%10s${NC} ${YELLOW}%10s${NC}\n" "$service" "$total" "$errors" "$warns"
                elif [ "$warns" -gt 0 ]; then
                    printf "%-25s %10s %10s ${YELLOW}%10s${NC}\n" "$service" "$total" "$errors" "$warns"
                else
                    printf "%-25s %10s %10s %10s\n" "$service" "$total" "$errors" "$warns"
                fi
            fi
        done
        
        echo ""
        echo "(Last 100 lines • Refreshing every 5s • Ctrl+C to exit)"
        sleep 5
    done
}

# ============================================
# Interactive Mode
# ============================================
interactive_mode() {
    while true; do
        clear
        print_banner
        
        echo "Select a service to view logs:"
        echo ""
        echo "  1) All services"
        echo "  2) Backend services only"
        echo "  3) api-gateway"
        echo "  4) auth-service"
        echo "  5) hotel-service"
        echo "  6) menu-service"
        echo "  7) admin-rider-service"
        echo "  8) frontend"
        echo "  9) nginx"
        echo " 10) mysql"
        echo ""
        echo "  e) View errors only"
        echo "  s) Search logs"
        echo "  x) Export logs"
        echo "  q) Quit"
        echo ""
        read -p "Enter choice: " choice
        
        case $choice in
            1) view_all_logs 100 false; read -p "Press Enter to continue..." ;;
            2) view_backend_logs 100 false; read -p "Press Enter to continue..." ;;
            3) view_service_logs "api-gateway" 100 false; read -p "Press Enter to continue..." ;;
            4) view_service_logs "auth-service" 100 false; read -p "Press Enter to continue..." ;;
            5) view_service_logs "hotel-service" 100 false; read -p "Press Enter to continue..." ;;
            6) view_service_logs "menu-service" 100 false; read -p "Press Enter to continue..." ;;
            7) view_service_logs "admin-rider-service" 100 false; read -p "Press Enter to continue..." ;;
            8) view_service_logs "frontend" 100 false; read -p "Press Enter to continue..." ;;
            9) view_service_logs "nginx" 100 false; read -p "Press Enter to continue..." ;;
            10) view_service_logs "mysql" 100 false; read -p "Press Enter to continue..." ;;
            e) view_errors 200; read -p "Press Enter to continue..." ;;
            s) 
                read -p "Enter search pattern: " pattern
                search_logs "$pattern"
                read -p "Press Enter to continue..."
                ;;
            x) 
                read -p "Export which service? (all/service-name): " svc
                export_logs "$svc" 1000
                read -p "Press Enter to continue..."
                ;;
            q|Q) exit 0 ;;
            *) log_error "Invalid choice" ;;
        esac
    done
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [options] [service]"
    echo ""
    echo "View Options:"
    echo "  [service]           View logs for specific service"
    echo "  --all, -a           View all service logs"
    echo "  --backend, -b       View backend services only"
    echo "  --follow, -f        Follow log output (tail -f)"
    echo "  --lines N, -n N     Number of lines to show (default: 100)"
    echo ""
    echo "Analysis Options:"
    echo "  --errors, -e        Show errors/exceptions only"
    echo "  --search PATTERN    Search logs for pattern"
    echo "  --stats             Live log statistics view"
    echo ""
    echo "Other Options:"
    echo "  --export [service]  Export logs to file"
    echo "  --interactive, -i   Interactive mode"
    echo "  --help, -h          Show this help"
    echo ""
    echo "Available Services:"
    for svc in "${ALL_SERVICES[@]}"; do
        echo "  - $svc"
    done
    echo ""
    echo "Examples:"
    echo "  $0 api-gateway              # View api-gateway logs"
    echo "  $0 -f auth-service          # Follow auth-service logs"
    echo "  $0 --errors                 # View all errors"
    echo "  $0 --search 'exception'     # Search for 'exception'"
    echo "  $0 -a -n 50                 # Last 50 lines from all"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    # Parse arguments
    FOLLOW=false
    LINES=100
    SERVICE=""
    MODE="default"
    SEARCH_PATTERN=""
    EXPORT_SERVICE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --all|-a)
                MODE="all"
                shift
                ;;
            --backend|-b)
                MODE="backend"
                shift
                ;;
            --follow|-f)
                FOLLOW=true
                shift
                ;;
            --lines|-n)
                LINES="$2"
                shift 2
                ;;
            --errors|-e)
                MODE="errors"
                shift
                ;;
            --search)
                MODE="search"
                SEARCH_PATTERN="$2"
                shift 2
                ;;
            --stats)
                MODE="stats"
                shift
                ;;
            --export)
                MODE="export"
                EXPORT_SERVICE="${2:-all}"
                shift
                [[ "$1" != -* && -n "$1" ]] && shift
                ;;
            --interactive|-i)
                MODE="interactive"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                SERVICE="$1"
                shift
                ;;
        esac
    done
    
    # Execute based on mode
    case $MODE in
        all)
            print_banner
            view_all_logs "$LINES" "$FOLLOW"
            ;;
        backend)
            print_banner
            view_backend_logs "$LINES" "$FOLLOW"
            ;;
        errors)
            print_banner
            view_errors "$LINES"
            ;;
        search)
            print_banner
            search_logs "$SEARCH_PATTERN" "$SERVICE" "$LINES"
            ;;
        stats)
            live_stats
            ;;
        export)
            print_banner
            export_logs "$EXPORT_SERVICE" "$LINES"
            ;;
        interactive)
            interactive_mode
            ;;
        default)
            if [ -n "$SERVICE" ]; then
                print_banner
                view_service_logs "$SERVICE" "$LINES" "$FOLLOW"
            else
                print_banner
                log_info "No service specified, showing all logs..."
                echo ""
                view_all_logs "$LINES" "$FOLLOW"
            fi
            ;;
    esac
}

# Run main function
main "$@"
