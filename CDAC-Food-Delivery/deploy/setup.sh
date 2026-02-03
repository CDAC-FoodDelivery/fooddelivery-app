#!/bin/bash

# ============================================
# Food Delivery Application - Setup Script
# System Preparation and Dependency Installation
# ============================================
# This script prepares the system for deployment:
# - Checks system requirements
# - Installs Docker and Docker Compose
# - Configures firewall
# - Sets up swap space if needed
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

# Minimum requirements
MIN_RAM_MB=3500
MIN_DISK_GB=15
RECOMMENDED_RAM_MB=7500

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
    echo "   Food Delivery App - System Setup"
    echo "============================================"
    echo ""
}

# ============================================
# Check if running as root
# ============================================
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root or with sudo"
        echo ""
        echo "Usage: sudo $0"
        exit 1
    fi
}

# ============================================
# Detect OS
# ============================================
detect_os() {
    log_step "Detecting operating system..."
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$NAME
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
        OS_NAME="Red Hat Enterprise Linux"
    else
        log_error "Unsupported operating system"
        exit 1
    fi
    
    log_success "Detected: $OS_NAME ($OS $OS_VERSION)"
    
    # Validate supported OS
    case $OS in
        ubuntu|debian)
            PACKAGE_MANAGER="apt"
            ;;
        centos|rhel|fedora|rocky|almalinux)
            PACKAGE_MANAGER="yum"
            if command -v dnf &> /dev/null; then
                PACKAGE_MANAGER="dnf"
            fi
            ;;
        *)
            log_error "Unsupported OS: $OS"
            log_info "Supported: Ubuntu, Debian, CentOS, RHEL, Fedora, Rocky Linux, AlmaLinux"
            exit 1
            ;;
    esac
}

# ============================================
# Check System Resources
# ============================================
check_resources() {
    log_step "Checking system resources..."
    echo ""
    
    # Check RAM
    TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    TOTAL_RAM_MB=$((TOTAL_RAM_KB / 1024))
    TOTAL_RAM_GB=$(echo "scale=1; $TOTAL_RAM_MB / 1024" | bc)
    
    echo "  RAM: ${TOTAL_RAM_GB} GB"
    
    if [ "$TOTAL_RAM_MB" -lt "$MIN_RAM_MB" ]; then
        log_error "Insufficient RAM: ${TOTAL_RAM_GB} GB (minimum: 4 GB)"
        log_info "Consider upgrading your server or adding swap space"
        exit 1
    elif [ "$TOTAL_RAM_MB" -lt "$RECOMMENDED_RAM_MB" ]; then
        log_warning "RAM is below recommended: ${TOTAL_RAM_GB} GB (recommended: 8 GB)"
        log_info "Application may run slowly during builds"
    else
        log_success "RAM: ${TOTAL_RAM_GB} GB (OK)"
    fi
    
    # Check Disk Space
    DISK_AVAILABLE_KB=$(df "$PROJECT_ROOT" | tail -1 | awk '{print $4}')
    DISK_AVAILABLE_GB=$((DISK_AVAILABLE_KB / 1024 / 1024))
    
    echo "  Disk Available: ${DISK_AVAILABLE_GB} GB"
    
    if [ "$DISK_AVAILABLE_GB" -lt "$MIN_DISK_GB" ]; then
        log_error "Insufficient disk space: ${DISK_AVAILABLE_GB} GB (minimum: 15 GB)"
        exit 1
    else
        log_success "Disk Space: ${DISK_AVAILABLE_GB} GB (OK)"
    fi
    
    # Check CPU cores
    CPU_CORES=$(nproc)
    echo "  CPU Cores: $CPU_CORES"
    
    if [ "$CPU_CORES" -lt 2 ]; then
        log_warning "Only $CPU_CORES CPU core(s) available. Builds will be slow."
    else
        log_success "CPU Cores: $CPU_CORES (OK)"
    fi
    
    echo ""
}

# ============================================
# Setup Swap Space
# ============================================
setup_swap() {
    log_step "Checking swap space..."
    
    SWAP_TOTAL=$(free -m | grep Swap | awk '{print $2}')
    
    if [ "$SWAP_TOTAL" -lt 2000 ]; then
        log_warning "Low swap space: ${SWAP_TOTAL} MB"
        
        # Check if we should create swap
        if [ "$TOTAL_RAM_MB" -lt "$RECOMMENDED_RAM_MB" ]; then
            log_info "Creating 4GB swap file for build stability..."
            
            # Check if swap file already exists
            if [ -f /swapfile ]; then
                log_info "Swap file already exists"
            else
                # Create swap file
                fallocate -l 4G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=4096
                chmod 600 /swapfile
                mkswap /swapfile
                swapon /swapfile
                
                # Make permanent
                if ! grep -q "/swapfile" /etc/fstab; then
                    echo '/swapfile none swap sw 0 0' >> /etc/fstab
                fi
                
                log_success "Created and enabled 4GB swap file"
            fi
        fi
    else
        log_success "Swap space: ${SWAP_TOTAL} MB (OK)"
    fi
}

# ============================================
# Update System Packages
# ============================================
update_packages() {
    log_step "Updating system packages..."
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get update -qq
            apt-get upgrade -y -qq
            ;;
        yum|dnf)
            $PACKAGE_MANAGER update -y -q
            ;;
    esac
    
    log_success "System packages updated"
}

# ============================================
# Install Required Packages
# ============================================
install_prerequisites() {
    log_step "Installing prerequisite packages..."
    
    case $PACKAGE_MANAGER in
        apt)
            apt-get install -y -qq curl wget git nano htop net-tools dnsutils bc gettext-base
            ;;
        yum|dnf)
            $PACKAGE_MANAGER install -y -q curl wget git nano htop net-tools bind-utils bc gettext
            ;;
    esac
    
    log_success "Prerequisites installed"
}

# ============================================
# Install Docker
# ============================================
install_docker() {
    log_step "Checking Docker installation..."
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
        log_success "Docker already installed: $DOCKER_VERSION"
    else
        log_info "Installing Docker..."
        
        # Use official Docker install script
        curl -fsSL https://get.docker.com | sh
        
        # Start and enable Docker
        systemctl start docker
        systemctl enable docker
        
        DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
        log_success "Docker installed: $DOCKER_VERSION"
    fi
    
    # Verify Docker Compose (V2)
    if docker compose version &> /dev/null; then
        COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || docker compose version | awk '{print $4}')
        log_success "Docker Compose V2 available: $COMPOSE_VERSION"
    else
        log_error "Docker Compose V2 not available"
        log_info "Please ensure you have Docker Desktop or Docker Engine 20.10+"
        exit 1
    fi
    
    # Verify Docker is running
    if ! docker info &> /dev/null 2>&1; then
        log_error "Docker daemon is not running"
        systemctl start docker
        sleep 3
        if ! docker info &> /dev/null 2>&1; then
            log_error "Failed to start Docker daemon"
            exit 1
        fi
    fi
    log_success "Docker daemon is running"
}

# ============================================
# Configure Non-Root Docker Access
# ============================================
configure_docker_user() {
    log_step "Configuring Docker user access..."
    
    # Get the user who ran sudo (if any)
    ACTUAL_USER="${SUDO_USER:-$USER}"
    
    if [ "$ACTUAL_USER" != "root" ]; then
        if ! groups "$ACTUAL_USER" | grep -q docker; then
            usermod -aG docker "$ACTUAL_USER"
            log_success "Added $ACTUAL_USER to docker group"
            log_warning "You may need to log out and back in for group changes to take effect"
        else
            log_info "$ACTUAL_USER already in docker group"
        fi
    fi
}

# ============================================
# Configure Firewall
# ============================================
configure_firewall() {
    log_step "Configuring firewall..."
    
    # Check for UFW (Ubuntu/Debian)
    if command -v ufw &> /dev/null; then
        # Check if UFW is active
        UFW_STATUS=$(ufw status | head -1)
        
        if echo "$UFW_STATUS" | grep -q "inactive"; then
            log_info "UFW is inactive, enabling with default rules..."
            ufw --force enable
        fi
        
        # Allow required ports
        ufw allow OpenSSH
        ufw allow 80/tcp
        ufw allow 443/tcp
        
        # Reload
        ufw reload
        
        log_success "UFW configured: SSH, HTTP (80), HTTPS (443) allowed"
        
    # Check for firewalld (RHEL/CentOS)
    elif command -v firewall-cmd &> /dev/null; then
        # Check if firewalld is running
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --permanent --add-service=ssh
            firewall-cmd --permanent --add-port=80/tcp
            firewall-cmd --permanent --add-port=443/tcp
            firewall-cmd --reload
            
            log_success "Firewalld configured: SSH, HTTP (80), HTTPS (443) allowed"
        else
            log_warning "Firewalld is not running"
        fi
    else
        log_warning "No firewall detected (ufw/firewalld)"
        log_info "Make sure ports 80 and 443 are open in your cloud provider's firewall"
    fi
}

# ============================================
# Create Directory Structure
# ============================================
setup_directories() {
    log_step "Setting up directory structure..."
    
    # Create required directories
    mkdir -p "$PROJECT_ROOT/nginx"
    mkdir -p "$PROJECT_ROOT/backups"
    mkdir -p "$PROJECT_ROOT/logs"
    
    # Set proper ownership
    ACTUAL_USER="${SUDO_USER:-$USER}"
    if [ "$ACTUAL_USER" != "root" ]; then
        chown -R "$ACTUAL_USER:$ACTUAL_USER" "$PROJECT_ROOT/backups"
        chown -R "$ACTUAL_USER:$ACTUAL_USER" "$PROJECT_ROOT/logs"
    fi
    
    log_success "Directory structure created"
}

# ============================================
# Test Docker Installation
# ============================================
test_docker() {
    log_step "Testing Docker installation..."
    
    if docker run --rm hello-world &> /dev/null; then
        log_success "Docker test passed"
    else
        log_error "Docker test failed"
        log_info "Try running: systemctl restart docker"
        exit 1
    fi
}

# ============================================
# Print Summary
# ============================================
print_summary() {
    echo ""
    echo "============================================"
    echo "   Setup Complete!"
    echo "============================================"
    echo ""
    echo "  System Information:"
    echo "  -------------------"
    echo "  OS:            $OS_NAME"
    echo "  RAM:           ${TOTAL_RAM_GB} GB"
    echo "  Disk:          ${DISK_AVAILABLE_GB} GB available"
    echo "  CPU Cores:     $CPU_CORES"
    echo "  Docker:        $(docker --version | awk '{print $3}' | tr -d ',')"
    echo "  Compose:       $(docker compose version --short 2>/dev/null || echo 'V2')"
    echo ""
    echo "  Next Steps:"
    echo "  -----------"
    echo "  1. Run: ./deploy/configure.sh"
    echo "  2. Run: ./deploy/build.sh"
    echo "  3. Run: ./deploy/deploy.sh"
    echo ""
    
    # Reminder about group changes
    ACTUAL_USER="${SUDO_USER:-$USER}"
    if [ "$ACTUAL_USER" != "root" ]; then
        echo "  ${YELLOW}Note:${NC} Log out and back in for docker group changes"
        echo "        to take effect, or run: newgrp docker"
        echo ""
    fi
}

# ============================================
# Show Help
# ============================================
show_help() {
    echo "Usage: sudo $0 [options]"
    echo ""
    echo "Options:"
    echo "  --check-only    Only check requirements, don't install anything"
    echo "  --skip-docker   Skip Docker installation (if already installed)"
    echo "  --skip-firewall Skip firewall configuration"
    echo "  --help, -h      Show this help message"
    echo ""
}

# ============================================
# Main Execution
# ============================================
main() {
    print_banner
    
    # Parse arguments
    CHECK_ONLY=false
    SKIP_DOCKER=false
    SKIP_FIREWALL=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                CHECK_ONLY=true
                shift
                ;;
            --skip-docker)
                SKIP_DOCKER=true
                shift
                ;;
            --skip-firewall)
                SKIP_FIREWALL=true
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
    
    # Must be root
    check_root
    
    # Detect OS first
    detect_os
    
    # Check resources
    check_resources
    
    # Exit if check-only mode
    if $CHECK_ONLY; then
        log_success "System check complete"
        exit 0
    fi
    
    # Update and install packages
    update_packages
    install_prerequisites
    
    # Setup swap if needed
    setup_swap
    
    # Install Docker (unless skipped)
    if ! $SKIP_DOCKER; then
        install_docker
        configure_docker_user
        test_docker
    fi
    
    # Configure firewall (unless skipped)
    if ! $SKIP_FIREWALL; then
        configure_firewall
    fi
    
    # Setup directories
    setup_directories
    
    # Done!
    print_summary
}

# Run main function
main "$@"
