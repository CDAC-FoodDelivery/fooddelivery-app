# Complete Deployment Script for Food Delivery Application
# This script deploys all backend services and frontend

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   Food Delivery Application - Complete Deployment" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "f:\FLUTTER\CDAC-Food-Delivery_v1\CDAC-Food-Delivery"
$backendPath = Join-Path $projectRoot "backend"

# Function to start a service in a new window
function Start-Service {
    param(
        [string]$ServiceName,
        [string]$ServicePath,
        [string]$Command,
        [int]$Port
    )
    
    Write-Host "Starting $ServiceName on port $Port..." -ForegroundColor Yellow
    $fullPath = Join-Path $backendPath $ServicePath
    
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$fullPath'; Write-Host 'Starting $ServiceName...' -ForegroundColor Green; $Command" -WindowStyle Normal
    
    Write-Host "  ✓ $ServiceName window opened" -ForegroundColor Green
}

# Step 1: Start Discovery Server
Write-Host "Step 1: Starting Discovery Server (Eureka)" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Gray
Start-Service -ServiceName "Discovery Server" -ServicePath "discovery-server" -Command "mvn spring-boot:run" -Port 8761
Write-Host "  Waiting 35 seconds for Discovery Server to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 35

# Step 2: Start API Gateway
Write-Host ""
Write-Host "Step 2: Starting API Gateway" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Gray
Start-Service -ServiceName "API Gateway" -ServicePath "api-gateway" -Command "mvn spring-boot:run" -Port 8080
Write-Host "  Waiting 20 seconds for API Gateway to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Step 3: Start Microservices
Write-Host ""
Write-Host "Step 3: Starting Microservices" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Gray

# Auth Service
Start-Service -ServiceName "Auth Service" -ServicePath "AuthService" -Command "mvn spring-boot:run" -Port 9081
Start-Sleep -Seconds 5

# FoodDelivery Backend (Hotel Service)
Start-Service -ServiceName "Hotel Service" -ServicePath "fooddelivery_backend" -Command "mvn spring-boot:run" -Port 9082
Start-Sleep -Seconds 5

# Menu Service
Start-Service -ServiceName "Menu Service" -ServicePath "Menu-backend" -Command "mvn spring-boot:run" -Port 9083
Start-Sleep -Seconds 5

# Admin Rider Service (.NET)
Start-Service -ServiceName "Admin Rider Service" -ServicePath "AdminRiderService" -Command "dotnet run" -Port 9086
Start-Sleep -Seconds 5

Write-Host "  Waiting 30 seconds for all microservices to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 30

# Step 4: Start Frontend
Write-Host ""
Write-Host "Step 4: Starting Frontend Application" -ForegroundColor Cyan
Write-Host "-------------------------------------------------------" -ForegroundColor Gray
$frontendPath = Join-Path $projectRoot "frontend"

Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; Write-Host 'Installing dependencies...' -ForegroundColor Green; npm install; Write-Host 'Starting development server...' -ForegroundColor Green; npm run dev" -WindowStyle Normal
Write-Host "  ✓ Frontend window opened" -ForegroundColor Green

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "   All Services Started Successfully!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Service Status:" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------" -ForegroundColor Gray
Write-Host "✓ Discovery Server (Eureka): http://localhost:8761" -ForegroundColor White
Write-Host "✓ API Gateway:                http://localhost:8080" -ForegroundColor White
Write-Host "✓ Auth Service:               http://localhost:9081" -ForegroundColor White
Write-Host "✓ Hotel Service:              http://localhost:9082" -ForegroundColor White
Write-Host "✓ Menu Service:               http://localhost:9083" -ForegroundColor White
Write-Host "✓ Admin Rider Service:        http://localhost:9086" -ForegroundColor White
Write-Host "✓ Frontend Application:       http://localhost:5173" -ForegroundColor Green
Write-Host ""
Write-Host "Primary Access Points:" -ForegroundColor Yellow
Write-Host "-------------------------------------------------------" -ForegroundColor Gray
Write-Host "→ Main Application:      http://localhost:5173" -ForegroundColor Cyan
Write-Host "→ Eureka Dashboard:      http://localhost:8761" -ForegroundColor Cyan
Write-Host "→ API Gateway:           http://localhost:8080" -ForegroundColor Cyan
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "- Each service is running in its own PowerShell window" -ForegroundColor Gray
Write-Host "- Wait a few minutes for all services to fully initialize" -ForegroundColor Gray
Write-Host "- Check Eureka Dashboard to verify all services are registered" -ForegroundColor Gray
Write-Host "- Frontend will be available after npm install completes" -ForegroundColor Gray
Write-Host ""
Write-Host "Opening Browser Windows in 10 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Open browser windows
Start-Process "http://localhost:8761"
Start-Sleep -Seconds 2
Start-Process "http://localhost:5173"

Write-Host ""
Write-Host "Browser windows opened!" -ForegroundColor Green
Write-Host "Deployment complete! Enjoy your application! 🚀" -ForegroundColor Green
Write-Host ""
