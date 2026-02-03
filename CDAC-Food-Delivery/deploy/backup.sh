#!/bin/bash

# ============================================
# Food Delivery Application - Backup Script
# Database and Volume Backup Utility
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

# Backup settings
BACKUP_DIR="${BACKUP_DIR:-$PROJECT_ROOT/backups}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================
# Load Environment
# ============================================
load_env() {
    if [ -f "$PROJECT_ROOT/.env" ]; then
        source "$PROJECT_ROOT/.env"
    else
        log_error ".env file not found"
        exit 1
    fi
}

# ============================================
# Create Backup Directory
# ============================================
setup_backup_dir() {
    mkdir -p "$BACKUP_DIR"
    log_info "Backup directory: $BACKUP_DIR"
}

# ============================================
# Backup MySQL Databases
# ============================================
backup_databases() {
    log_info "Backing up MySQL databases..."
    
    local databases=("fooddelivery_auth" "fooddelivery_hotel" "fooddelivery_menu" "fooddelivery_admin_rider")
    local backup_file="$BACKUP_DIR/mysql_backup_$TIMESTAMP.sql.gz"
    
    # Dump all databases at once
    docker exec fooddelivery-mysql mysqldump \
        -u"$MYSQL_USER" \
        -p"$MYSQL_PASSWORD" \
        --databases "${databases[@]}" \
        --single-transaction \
        --routines \
        --triggers \
        2>/dev/null | gzip > "$backup_file"
    
    if [ $? -eq 0 ]; then
        local size=$(du -h "$backup_file" | cut -f1)
        log_success "Database backup created: $backup_file ($size)"
    else
        log_error "Database backup failed"
        return 1
    fi
}

# ============================================
# Backup Individual Database
# ============================================
backup_single_database() {
    local db_name="$1"
    log_info "Backing up database: $db_name..."
    
    local backup_file="$BACKUP_DIR/${db_name}_$TIMESTAMP.sql.gz"
    
    docker exec fooddelivery-mysql mysqldump \
        -u"$MYSQL_USER" \
        -p"$MYSQL_PASSWORD" \
        "$db_name" \
        --single-transaction \
        2>/dev/null | gzip > "$backup_file"
    
    if [ $? -eq 0 ]; then
        log_success "Created: $backup_file"
    else
        log_error "Failed to backup $db_name"
    fi
}

# ============================================
# Backup Docker Volumes
# ============================================
backup_volumes() {
    log_info "Backing up Docker volumes..."
    
    local volume_backup_dir="$BACKUP_DIR/volumes_$TIMESTAMP"
    mkdir -p "$volume_backup_dir"
    
    # Backup MySQL data volume
    log_info "Backing up MySQL data volume..."
    docker run --rm \
        -v fooddelivery-mysql-data:/source:ro \
        -v "$volume_backup_dir":/backup \
        alpine tar czf /backup/mysql-data.tar.gz -C /source .
    
    log_success "Volume backup created: $volume_backup_dir"
}

# ============================================
# Backup Configuration Files
# ============================================
backup_configs() {
    log_info "Backing up configuration files..."
    
    local config_backup="$BACKUP_DIR/configs_$TIMESTAMP.tar.gz"
    
    cd "$PROJECT_ROOT"
    tar czf "$config_backup" \
        --exclude='.env' \
        .env.example \
        docker-compose.prod.yml \
        nginx/ \
        init-databases.sql \
        2>/dev/null
    
    log_success "Config backup created: $config_backup"
}

# ============================================
# Cleanup Old Backups
# ============================================
cleanup_old_backups() {
    log_info "Cleaning up backups older than $BACKUP_RETENTION_DAYS days..."
    
    local count=$(find "$BACKUP_DIR" -type f -mtime +$BACKUP_RETENTION_DAYS 2>/dev/null | wc -l)
    
    if [ "$count" -gt 0 ]; then
        find "$BACKUP_DIR" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
        find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true
        log_success "Removed $count old backup files"
    else
        log_info "No old backups to clean up"
    fi
}

# ============================================
# List Backups
# ============================================
list_backups() {
    echo ""
    echo "Available Backups in $BACKUP_DIR:"
    echo "=================================="
    
    if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
        ls -lah "$BACKUP_DIR" | tail -n +2
    else
        echo "No backups found"
    fi
    echo ""
}

# ============================================
# Restore Database
# ============================================
restore_database() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        log_error "Please specify backup file to restore"
        echo ""
        echo "Available backups:"
        ls -la "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "No database backups found"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_warning "This will REPLACE the current database!"
    read -p "Are you sure? (type 'RESTORE' to confirm): " confirm
    
    if [ "$confirm" != "RESTORE" ]; then
        log_info "Restore cancelled"
        exit 0
    fi
    
    log_info "Restoring from: $backup_file"
    
    gunzip -c "$backup_file" | docker exec -i fooddelivery-mysql mysql \
        -u"$MYSQL_USER" \
        -p"$MYSQL_PASSWORD"
    
    if [ $? -eq 0 ]; then
        log_success "Database restored successfully"
        log_info "You may need to restart the services: docker compose -f docker-compose.prod.yml restart"
    else
        log_error "Restore failed"
        exit 1
    fi
}

# ============================================
# Full Backup
# ============================================
full_backup() {
    log_info "Starting full backup..."
    echo ""
    
    backup_databases
    backup_configs
    cleanup_old_backups
    
    echo ""
    log_success "Full backup completed!"
    list_backups
}

# ============================================
# Main
# ============================================
main() {
    echo ""
    echo "============================================"
    echo "   Food Delivery App - Backup Utility"
    echo "============================================"
    echo ""
    
    load_env
    setup_backup_dir
    
    case "${1:-}" in
        --full)
            full_backup
            ;;
        --database|--db)
            backup_databases
            ;;
        --database-single)
            backup_single_database "${2:-}"
            ;;
        --volumes)
            backup_volumes
            ;;
        --configs)
            backup_configs
            ;;
        --restore)
            restore_database "$2"
            ;;
        --list)
            list_backups
            ;;
        --cleanup)
            cleanup_old_backups
            ;;
        --help|-h)
            echo "Usage: $0 [option]"
            echo ""
            echo "Backup Options:"
            echo "  --full             Full backup (databases + configs)"
            echo "  --database, --db   Backup all databases"
            echo "  --database-single NAME  Backup single database"
            echo "  --volumes          Backup Docker volumes"
            echo "  --configs          Backup configuration files"
            echo ""
            echo "Management Options:"
            echo "  --restore FILE     Restore database from backup"
            echo "  --list             List available backups"
            echo "  --cleanup          Remove old backups"
            echo "  --help, -h         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  BACKUP_DIR            Backup directory (default: ./backups)"
            echo "  BACKUP_RETENTION_DAYS Days to keep backups (default: 7)"
            echo ""
            exit 0
            ;;
        *)
            full_backup
            ;;
    esac
}

main "$@"
