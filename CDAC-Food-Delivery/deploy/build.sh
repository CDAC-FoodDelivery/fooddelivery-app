#!/bin/bash

# ============================================
# Food Delivery Application - Build Script
# Docker Image Building Utility
# ============================================
# This script handles:
# - Building all Docker images
# - Parallel builds for speed
# - Image tagging
# - Build cache management
# - Cleanup options
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

# Build settings
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.prod.yml"
BUILD_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Services to build (in dependency order)
SERVICES=(
    "discovery-server"
    "api-gateway"
    "auth-service"
    "hotel-service"
    "menu-service"
    "admin-rider-service"
    "frontend"
)

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
    echo "   Food Delivery App - Image Builder"
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
        log_error "Docker is not installed"
        exit 1
    fi
    
    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose is not available"
        exit 1
    fi
    
    # Check if compose file exists
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "docker-compose.prod.yml not found"
        exit 1
    fi
    
    # Check Docker daemon
    if ! docker info &> /dev/null 2>&1; then
        log_error "Docker daemon is not running"
        exit 1
    fi
    
    # Check disk space
    DISK_AVAILABLE_GB=$(df "$PROJECT_ROOT" | tail -1 | awk '{print int($4/1024/1024)}')
    if [ "$DISK_AVAILABLE_GB" -lt 5 ]; then
        log_warning "Low disk space: ${DISK_AVAILABLE_GB}GB available"
        log_info "Docker builds may fail. Consider running: docker system prune"
    fi
    
    log_success "Prerequisites checked"
}

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
        log_info "Loaded environment from .env"
    else
        log_warning ".env file not found, using defaults"
    fi
}

# ============================================
# Clean Old Images
# ============================================
clean_old_images() {
    log_step "Cleaning old images..."
    
    # Remove dangling images
    DANGLING=$(docker images -f "dangling=true" -q)
    if [ -n "$DANGLING" ]; then
        docker rmi $DANGLING 2>/dev/null || true
        log_success "Removed dangling images"
    else
        log_info "No dangling images to remove"
    fi
}

# ============================================
# Clean Build Cache
# ============================================
clean_build_cache() {
    log_step "Cleaning Docker build cache..."
    
    docker builder prune -f
    
    log_success "Build cache cleaned"
}

# ============================================
# Build All Services (Parallel)
# ============================================
build_all_parallel() {
    log_step "Building all Docker images (parallel)..."
    log_info "This may take 5-15 minutes on first run..."
    echo ""
    
    local start_time=$(date +%s)
    
    cd "$PROJECT_ROOT"
    
    if docker compose -f "$COMPOSE_FILE" build --parallel; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local minutes=$((duration / 60))
        local seconds=$((duration % 60))
        
        echo ""
        log_success "All images built successfully in ${minutes}m ${seconds}s"
    else
        log_error "Build failed"
        exit 1
    fi
}

# ============================================
# Build All Services (Sequential)
# ============================================
build_all_sequential() {
    log_step "Building all Docker images (sequential)..."
    log_info "This may take 10-20 minutes..."
    echo ""
    
    local start_time=$(date +%s)
    local failed=0
    
    cd "$PROJECT_ROOT"
    
    for service in "${SERVICES[@]}"; do
        echo ""
        log_info "Building: $service"
        echo "----------------------------------------"
        
        if docker compose -f "$COMPOSE_FILE" build "$service"; then
            log_success "$service built successfully"
        else
            log_error "Failed to build $service"
            failed=$((failed + 1))
        fi
    done
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))
    
    echo ""
    if [ $failed -eq 0 ]; then
        log_success "All ${#SERVICES[@]} images built in ${minutes}m ${seconds}s"
    else
        log_error "$failed service(s) failed to build"
        exit 1
    fi
}

# ============================================
# Build Single Service
# ============================================
build_single() {
    local service=$1
    
    log_step "Building service: $service"
    
    cd "$PROJECT_ROOT"
    
    if docker compose -f "$COMPOSE_FILE" build "$service"; then
        log_success "$service built successfully"
    else
        log_error "Failed to build $service"
        exit 1
    fi
}

# ============================================
# Build with No Cache
# ============================================
build_no_cache() {
    log_step "Building all images without cache..."
    log_warning "This will take significantly longer!"
    echo ""
    
    local start_time=$(date +%s)
    
    cd "$PROJECT_ROOT"
    
    if docker compose -f "$COMPOSE_FILE" build --no-cache --parallel; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local minutes=$((duration / 60))
        
        echo ""
        log_success "All images rebuilt from scratch in ${minutes}m"
    else
        log_error "Build failed"
        exit 1
    fi
}

# ============================================
# List Built Images
# ============================================
list_images() {
    echo ""
    echo "============================================"
    echo "   Built Images"
    echo "============================================"
    echo ""
    
    # Get project name (usually directory name)
    PROJECT_NAME=$(basename "$PROJECT_ROOT" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    
    docker images --filter "reference=*${PROJECT_NAME}*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    
    echo ""
    
    # Show total size
    TOTAL_SIZE=$(docker images --filter "reference=*${PROJECT_NAME}*" --format "{{.Size}}" | awk '
        {
            if ($0 ~ /GB/) { sum += $1 * 1024 }
            else if ($0 ~ /MB/) { sum += $1 }
        }
        END { printf "%.2f GB\n", sum/1024 }
    ')
    
    log_info "Total image size: ~$TOTAL_SIZE"
}

# ============================================
# Print Summary
# ============================================
print_summary() {
    echo ""
    echo "============================================"
    echo "   Build Complete!"
    echo "============================================"
    echo ""
    
    list_images
    
    echo ""
    echo "  Next Steps:"
    echo "  -----------"
    echo "  1. Run: ./deploy/deploy.sh"
    echo "  2. After deployment: ./deploy/setup-ssl.sh"
    echo ""
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [options] [service]"
    echo ""
    echo "Options:"
    echo "  --parallel          Build all services in parallel (default)"
    echo "  --sequential        Build services one by one"
    echo "  --no-cache          Build without using cache"
    echo "  --clean             Clean old/dangling images before build"
    echo "  --clean-cache       Clean Docker build cache before build"
    echo "  --list              List built images without building"
    echo "  --service NAME      Build only specified service"
    echo "  --help, -h          Show this help message"
    echo ""
    echo "Available Services:"
    for svc in "${SERVICES[@]}"; do
        echo "  - $svc"
    done
    echo ""
    echo "Examples:"
    echo "  $0                  # Build all services in parallel"
    echo "  $0 --sequential     # Build services sequentially"
    echo "  $0 --service auth-service  # Build only auth-service"
    echo "  $0 --clean --no-cache      # Full clean rebuild"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    
    # Parse arguments
    BUILD_MODE="parallel"
    NO_CACHE=false
    CLEAN_IMAGES=false
    CLEAN_CACHE=false
    LIST_ONLY=false
    SINGLE_SERVICE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --parallel)
                BUILD_MODE="parallel"
                shift
                ;;
            --sequential)
                BUILD_MODE="sequential"
                shift
                ;;
            --no-cache)
                NO_CACHE=true
                shift
                ;;
            --clean)
                CLEAN_IMAGES=true
                shift
                ;;
            --clean-cache)
                CLEAN_CACHE=true
                shift
                ;;
            --list)
                LIST_ONLY=true
                shift
                ;;
            --service)
                SINGLE_SERVICE="$2"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                # Check if it's a service name
                for svc in "${SERVICES[@]}"; do
                    if [ "$1" = "$svc" ]; then
                        SINGLE_SERVICE="$1"
                        break
                    fi
                done
                if [ -z "$SINGLE_SERVICE" ]; then
                    log_error "Unknown option: $1"
                    show_help
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # List only mode
    if $LIST_ONLY; then
        list_images
        exit 0
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Load environment
    load_env
    
    # Clean if requested
    if $CLEAN_IMAGES; then
        clean_old_images
    fi
    
    if $CLEAN_CACHE; then
        clean_build_cache
    fi
    
    # Build
    if [ -n "$SINGLE_SERVICE" ]; then
        build_single "$SINGLE_SERVICE"
    elif $NO_CACHE; then
        build_no_cache
    elif [ "$BUILD_MODE" = "sequential" ]; then
        build_all_sequential
    else
        build_all_parallel
    fi
    
    # Summary
    print_summary
}

# Run main function
main "$@"
