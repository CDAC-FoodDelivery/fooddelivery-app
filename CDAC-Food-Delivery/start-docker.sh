#!/bin/bash

# ============================================
# Food Delivery Application - Docker Startup
# For Linux/Mac systems
# ============================================

echo ""
echo "============================================"
echo "   Food Delivery App - Docker Launcher"
echo "============================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "[ERROR] Docker is not running. Please start Docker first."
    exit 1
fi

echo "[OK] Docker is running"
echo ""

# Stop existing containers
echo "[STEP 1/4] Stopping existing containers..."
docker-compose down --remove-orphans
echo ""

# Build all services
echo "[STEP 2/4] Building all services..."
echo "  This may take 5-10 minutes on first run"
docker-compose build
if [ $? -ne 0 ]; then
    echo "[ERROR] Build failed. Check the logs above."
    exit 1
fi
echo "  Build complete"
echo ""

# Start all services
echo "[STEP 3/4] Starting all services..."
docker-compose up -d
if [ $? -ne 0 ]; then
    echo "[ERROR] Failed to start services."
    exit 1
fi
echo "  Services started"
echo ""

# Wait for services to initialize
echo "[STEP 4/4] Waiting for services to initialize (60 seconds)..."
sleep 60
echo "  Services should be ready now"
echo ""

# Show container status
echo "============================================"
echo "   Container Status"
echo "============================================"
docker-compose ps
echo ""

# Success message
echo "============================================"
echo "   Application Started Successfully!"
echo "============================================"
echo ""
echo "Access Points:"
echo "  Frontend:        http://localhost:3000"
echo "  API Gateway:     http://localhost:8080"
echo "  Eureka:          http://localhost:8761"
echo ""
echo "Service Ports:"
echo "  Auth Service:    9081"
echo "  Hotel Service:   9082"
echo "  Menu Service:    9083"
echo "  Admin Service:   9086"
echo "  MySQL:           3307"
echo ""
echo "Commands:"
echo "  View logs:       docker-compose logs -f [service-name]"
echo "  Stop all:        docker-compose down"
echo ""

# Open browser (optional)
read -p "Open application in browser? (y/n): " choice
if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open http://localhost:3000
        xdg-open http://localhost:8761
    elif command -v open &> /dev/null; then
        open http://localhost:3000
        open http://localhost:8761
    fi
fi

echo ""
echo "Done! Enjoy your application!"
echo ""
