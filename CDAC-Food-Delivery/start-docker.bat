@echo off
REM ============================================
REM Food Delivery Application - Docker Startup
REM ============================================

echo.
echo ============================================
echo    Food Delivery App - Docker Launcher
echo ============================================
echo.

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo [INFO] Docker is running
echo.

REM Stop existing containers
echo [STEP 1/4] Stopping existing containers...
docker-compose down --remove-orphans
echo.

REM Remove old volumes (optional - uncomment if you want fresh data)
REM echo [INFO] Removing old data volumes...
REM docker volume rm cdac-food-delivery_mysql-data 2>nul

REM Build all services
echo [STEP 2/4] Building all services (this may take a few minutes)...
docker-compose build
if errorlevel 1 (
    echo [ERROR] Build failed. Check the logs above.
    pause
    exit /b 1
)
echo.

REM Start all services
echo [STEP 3/4] Starting all services...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start services.
    pause
    exit /b 1
)
echo.

REM Wait for services to initialize
echo [STEP 4/4] Waiting for services to initialize (60 seconds)...
timeout /t 60 /nobreak
echo.

REM Show container status
echo ============================================
echo    Container Status
echo ============================================
docker-compose ps
echo.

echo ============================================
echo    Application Started Successfully!
echo ============================================
echo.
echo Access Points:
echo   Frontend:        http://localhost:3000
echo   API Gateway:     http://localhost:8080
echo   Eureka:          http://localhost:8761
echo.
echo Service Ports:
echo   Auth Service:    9081
echo   Hotel Service:   9082
echo   Menu Service:    9083
echo   Admin Service:   9086
echo   MySQL:           3307
echo.
echo To view logs:      docker-compose logs -f [service-name]
echo To stop:           docker-compose down
echo.

REM Open browser
choice /C YN /M "Open application in browser"
if errorlevel 2 goto :end
start http://localhost:3000
start http://localhost:8761

:end
echo.
echo Press any key to exit...
pause >nul
