# ============================================
# Food Delivery Application - Docker Startup
# ============================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Food Delivery App - Docker Launcher" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    docker info 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
    Write-Host "[OK] Docker is running" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Stop existing containers
Write-Host "[STEP 1/4] Stopping existing containers..." -ForegroundColor Yellow
docker-compose down --remove-orphans 2>&1 | Out-Null
Write-Host "  Done" -ForegroundColor Gray
Write-Host ""

# Build all services
Write-Host "[STEP 2/4] Building all services..." -ForegroundColor Yellow
Write-Host "  This may take 5-10 minutes on first run" -ForegroundColor Gray
docker-compose build
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Build failed. Check the logs above." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Build complete" -ForegroundColor Green
Write-Host ""

# Start all services
Write-Host "[STEP 3/4] Starting all services..." -ForegroundColor Yellow
docker-compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to start services." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "  Services started" -ForegroundColor Green
Write-Host ""

# Wait for services to initialize
Write-Host "[STEP 4/4] Waiting for services to initialize..." -ForegroundColor Yellow
$waitTime = 60
for ($i = $waitTime; $i -gt 0; $i--) {
    Write-Host "`r  Waiting: $i seconds remaining...  " -NoNewline
    Start-Sleep -Seconds 1
}
Write-Host "`r  Services should be ready now        " -ForegroundColor Green
Write-Host ""

# Show container status
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Container Status" -ForegroundColor White
Write-Host "============================================" -ForegroundColor Cyan
docker-compose ps
Write-Host ""

# Success message
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   Application Started Successfully!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Yellow
Write-Host "  Frontend:        " -NoNewline; Write-Host "http://localhost:3000" -ForegroundColor Cyan
Write-Host "  API Gateway:     " -NoNewline; Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "  Eureka:          " -NoNewline; Write-Host "http://localhost:8761" -ForegroundColor Cyan
Write-Host ""
Write-Host "Service Ports:" -ForegroundColor Yellow
Write-Host "  Auth Service:    9081"
Write-Host "  Hotel Service:   9082"
Write-Host "  Menu Service:    9083"
Write-Host "  Admin Service:   9086"
Write-Host "  MySQL:           3307"
Write-Host ""
Write-Host "Commands:" -ForegroundColor Yellow
Write-Host "  View logs:       docker-compose logs -f [service-name]"
Write-Host "  Stop all:        docker-compose down"
Write-Host ""

# Open browser
$openBrowser = Read-Host "Open application in browser? (Y/N)"
if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
    Start-Process "http://localhost:3000"
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:8761"
}

Write-Host ""
Write-Host "Done! Enjoy your application!" -ForegroundColor Green
Write-Host ""
