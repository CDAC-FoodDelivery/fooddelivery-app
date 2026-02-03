#!/bin/bash

# ============================================
# Food Delivery Application - Rollback Script
# Emergency Rollback Procedures
# ============================================
# This script provides:
# - Quick rollback to previous state
# - Database restoration
# - Configuration restoration
# - Verification after rollback
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
BACKUP_DIR="$PROJECT_ROOT/backups"
ROLLBACK_STATE_FILE="$PROJECT_ROOT/.rollback-state"

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
    echo "   Food Delivery App - Rollback"
    echo "============================================"
    echo ""
}

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    fi
}

# ============================================
# Save Current State (Before Deployment)
# ============================================
save_state() {
    log_step "Saving current deployment state..."
    
    mkdir -p "$BACKUP_DIR"
    
    local state_file="$ROLLBACK_STATE_FILE"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    # Save container image IDs
    echo "# Rollback state saved at $(date)" > "$state_file"
    echo "SAVE_TIMESTAMP=$timestamp" >> "$state_file"
    echo "" >> "$state_file"
    echo "# Image digests" >> "$state_file"
    
    local services=("discovery-server" "api-gateway" "auth-service" "hotel-service" "menu-service" "admin-rider-service" "frontend")
    
    for service in "${services[@]}"; do
        local image_id=$(docker inspect --format='{{.Image}}' "$service" 2>/dev/null || echo "none")
        echo "${service}_IMAGE=$image_id" >> "$state_file"
    done
    
    # Backup current .env
    if [ -f "$PROJECT_ROOT/.env" ]; then
        cp "$PROJECT_ROOT/.env" "$BACKUP_DIR/env_$timestamp.backup"
        echo "ENV_BACKUP=$BACKUP_DIR/env_$timestamp.backup" >> "$state_file"
    fi
    
    # Backup nginx config
    if [ -f "$PROJECT_ROOT/nginx/nginx.conf" ]; then
        cp "$PROJECT_ROOT/nginx/nginx.conf" "$BACKUP_DIR/nginx_$timestamp.conf.backup"
        echo "NGINX_BACKUP=$BACKUP_DIR/nginx_$timestamp.conf.backup" >> "$state_file"
    fi
    
    log_success "State saved to $state_file"
    log_info "Use './deploy/rollback.sh --restore' to rollback to this state"
}

# ============================================
# Quick Rollback (Restart Previous Containers)
# ============================================
quick_rollback() {
    log_step "Performing quick rollback..."
    
    cd "$PROJECT_ROOT"
    
    # Stop current containers
    log_info "Stopping current containers..."
    docker compose -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true
    
    # Restart with existing images (no rebuild)
    log_info "Starting containers with existing images..."
    docker compose -f "$COMPOSE_FILE" up -d
    
    # Wait for health
    log_info "Waiting for services to become healthy..."
    sleep 30
    
    # Quick health check
    local healthy=0
    local services=("mysql" "discovery-server" "api-gateway" "auth-service" "frontend" "nginx")
    
    for service in "${services[@]}"; do
        if docker inspect --format='{{.State.Status}}' "$service" 2>/dev/null | grep -q "running"; then
            healthy=$((healthy + 1))
        fi
    done
    
    if [ $healthy -ge ${#services[@]} ]; then
        log_success "Quick rollback complete - all services running"
    else
        log_warning "Quick rollback complete - only $healthy/${#services[@]} services running"
    fi
}

# ============================================
# Restore from Saved State
# ============================================
restore_state() {
    log_step "Restoring from saved state..."
    
    if [ ! -f "$ROLLBACK_STATE_FILE" ]; then
        log_error "No saved state found"
        log_info "Run './deploy/rollback.sh --save' before deployment to save state"
        exit 1
    fi
    
    source "$ROLLBACK_STATE_FILE"
    
    log_info "Found state saved at: $SAVE_TIMESTAMP"
    
    # Restore .env if backup exists
    if [ -n "$ENV_BACKUP" ] && [ -f "$ENV_BACKUP" ]; then
        log_info "Restoring environment configuration..."
        cp "$ENV_BACKUP" "$PROJECT_ROOT/.env"
        log_success "Environment restored"
    fi
    
    # Restore nginx config if backup exists
    if [ -n "$NGINX_BACKUP" ] && [ -f "$NGINX_BACKUP" ]; then
        log_info "Restoring Nginx configuration..."
        cp "$NGINX_BACKUP" "$PROJECT_ROOT/nginx/nginx.conf"
        log_success "Nginx config restored"
    fi
    
    # Perform quick rollback
    quick_rollback
    
    log_success "State restoration complete"
}

# ============================================
# Restore Database from Backup
# ============================================
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        # List available backups
        echo ""
        echo "Available database backups:"
        echo "───────────────────────────"
        ls -la "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "No database backups found"
        echo ""
        log_error "Please specify backup file:"
        log_info "Usage: ./deploy/rollback.sh --restore-db /path/to/backup.sql.gz"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_warning "This will REPLACE the current database!"
    log_warning "All current data will be LOST!"
    echo ""
    read -p "Type 'RESTORE' to confirm: " confirm
    
    if [ "$confirm" != "RESTORE" ]; then
        log_info "Cancelled"
        exit 0
    fi
    
    log_step "Restoring database from: $backup_file"
    
    load_env
    
    # Restore
    gunzip -c "$backup_file" | docker exec -i mysql mysql \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD:-root}"
    
    if [ $? -eq 0 ]; then
        log_success "Database restored successfully"
        log_info "You may need to restart services:"
        log_info "  docker compose -f docker-compose.prod.yml restart"
    else
        log_error "Database restore failed"
        exit 1
    fi
}

# ============================================
# Emergency Stop All
# ============================================
emergency_stop() {
    log_warning "EMERGENCY STOP - Stopping all services..."
    
    cd "$PROJECT_ROOT"
    
    docker compose -f "$COMPOSE_FILE" down --remove-orphans
    
    log_success "All services stopped"
    log_info "To restart: ./deploy/deploy.sh --no-build"
}

# ============================================
# Rollback to Previous Git Commit
# ============================================
rollback_git() {
    local commits="${1:-1}"
    
    log_step "Rolling back $commits commit(s)..."
    
    cd "$PROJECT_ROOT"
    
    # Check if git is available and this is a repo
    if ! git rev-parse --is-inside-work-tree &> /dev/null; then
        log_error "Not a git repository"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log_warning "You have uncommitted changes"
        read -p "Stash changes and continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git stash
            log_info "Changes stashed"
        else
            log_info "Cancelled"
            exit 0
        fi
    fi
    
    # Get current commit for reference
    CURRENT_COMMIT=$(git rev-parse HEAD)
    
    # Rollback
    git reset --hard HEAD~$commits
    
    log_success "Rolled back $commits commit(s)"
    log_info "Previous commit: $CURRENT_COMMIT"
    log_info "Current commit: $(git rev-parse HEAD)"
    
    echo ""
    log_info "To apply changes, rebuild and deploy:"
    log_info "  ./deploy/build.sh && ./deploy/deploy.sh"
    echo ""
    log_info "To undo this rollback:"
    log_info "  git reset --hard $CURRENT_COMMIT"
}

# ============================================
# List Available Rollback Points
# ============================================
list_rollback_points() {
    echo ""
    echo "============================================"
    echo "   Available Rollback Points"
    echo "============================================"
    echo ""
    
    # Saved state
    echo "Saved Deployment State:"
    echo "────────────────────────"
    if [ -f "$ROLLBACK_STATE_FILE" ]; then
        source "$ROLLBACK_STATE_FILE"
        echo "  Timestamp: $SAVE_TIMESTAMP"
        if [ -n "$ENV_BACKUP" ]; then echo "  Env backup: $ENV_BACKUP"; fi
        if [ -n "$NGINX_BACKUP" ]; then echo "  Nginx backup: $NGINX_BACKUP"; fi
    else
        echo "  No saved state found"
    fi
    
    echo ""
    echo "Database Backups:"
    echo "─────────────────"
    if ls "$BACKUP_DIR"/*.sql.gz 2>/dev/null; then
        ls -lah "$BACKUP_DIR"/*.sql.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    else
        echo "  No database backups found"
    fi
    
    echo ""
    echo "Git History (last 5 commits):"
    echo "──────────────────────────────"
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        git log --oneline -5 | sed 's/^/  /'
    else
        echo "  Not a git repository"
    fi
    
    echo ""
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Rollback Options:"
    echo "  --quick             Quick rollback (restart with existing images)"
    echo "  --restore           Restore from saved deployment state"
    echo "  --restore-db FILE   Restore database from backup file"
    echo "  --git [N]           Rollback N git commits (default: 1)"
    echo ""
    echo "State Management:"
    echo "  --save              Save current state before deployment"
    echo "  --list              List available rollback points"
    echo ""
    echo "Emergency:"
    echo "  --stop              Emergency stop all services"
    echo ""
    echo "Other:"
    echo "  --help, -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --save           # Save state before deployment"
    echo "  $0 --quick          # Quick restart if something breaks"
    echo "  $0 --restore        # Full restore from saved state"
    echo "  $0 --restore-db ./backups/mysql_backup_20260203.sql.gz"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    
    case "${1:-}" in
        --save)
            save_state
            ;;
        --quick)
            quick_rollback
            ;;
        --restore)
            restore_state
            ;;
        --restore-db)
            restore_database "$2"
            ;;
        --git)
            rollback_git "${2:-1}"
            ;;
        --stop)
            emergency_stop
            ;;
        --list)
            list_rollback_points
            ;;
        --help|-h)
            show_help
            ;;
        *)
            log_info "No option specified. Showing available options..."
            echo ""
            list_rollback_points
            echo ""
            show_help
            ;;
    esac
}

# Run main function
main "$@"
