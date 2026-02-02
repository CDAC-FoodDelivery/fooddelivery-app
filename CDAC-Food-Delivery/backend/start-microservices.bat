@echo off
REM ===============================================================
REM Food Delivery Microservices Startup Script
REM This script starts all microservices in the correct order
REM ===============================================================

echo.
echo ========================================
echo Food Delivery Microservices Launcher
echo ========================================
echo.

REM Check if running from backend directory
IF NOT EXIST "discovery-server" (
    echo ERROR: Please run this script from the 'backend' directory
    echo Current directory: %CD%
    pause
    exit /b 1
)

echo [INFO] Starting microservices architecture...
echo.

REM Step 1: Discovery Server
echo ========================================
echo Step 1: Starting Discovery Server (Port 8761)
echo ========================================
start "Discovery Server" cmd /k "cd discovery-server && mvn spring-boot:run"
echo [INFO] Discovery Server starting...
echo [INFO] Waiting 30 seconds for Discovery Server to initialize...
timeout /t 30 /nobreak
echo.

REM Step 2: Start all microservices
echo ========================================
echo Step 2: Starting Microservices
echo ========================================
echo.

REM Auth Service
echo [INFO] Starting Auth Service (Port 9081)...
start "Auth Service" cmd /k "cd AuthService && mvn spring-boot:run"
timeout /t 5 /nobreak

REM Menu Service
echo [INFO] Starting Menu Service (Port 9083)...
start "Menu Service" cmd /k "cd Menu-backend && mvn spring-boot:run"
timeout /t 5 /nobreak

REM Hotel Service
echo [INFO] Starting Hotel Service (Port 9082)...
start "Hotel Service" cmd /k "cd fooddelivery_backend && mvn spring-boot:run"
timeout /t 5 /nobreak

REM Admin Rider Service (.NET)
echo [INFO] Starting Admin Rider Service (Port 9086)...
start "Admin Rider Service" cmd /k "cd AdminRiderService && dotnet run"

echo.
echo [INFO] Waiting 25 seconds for all services to initialize...
timeout /t 25 /nobreak
echo.

REM Step 3: API Gateway (Start Last)
echo ========================================
echo Step 3: Starting API Gateway (Port 8080)
echo ========================================
start "API Gateway" cmd /k "cd api-gateway && mvn spring-boot:run"
echo [INFO] API Gateway starting...
timeout /t 15 /nobreak
echo.

echo ========================================
echo All services started!
echo ========================================
echo.
echo Please verify all services in Eureka Dashboard:
echo http://localhost:8761
echo.
echo Expected services:
echo - AUTH-SERVICE (9081)
echo - MENU-SERVICE (9083)
echo - HOTEL-SERVICE (9082)
echo - ADMIN-RIDER-SERVICE (9086)
echo - API-GATEWAY (8080)
echo.
echo Access your application through API Gateway:
echo http://localhost:8080/api/...
echo.
echo Press any key to open Eureka Dashboard...
pause
start http://localhost:8761
