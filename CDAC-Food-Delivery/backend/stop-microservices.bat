@echo off
REM ===============================================================
REM Food Delivery Microservices Shutdown Script
REM This script stops all running microservices
REM ===============================================================

echo.
echo ========================================
echo Food Delivery Microservices Shutdown
echo ========================================
echo.

echo [WARNING] This will stop all Java and .NET processes running on microservice ports
echo.
choice /C YN /M "Do you want to continue"
if errorlevel 2 goto :cancel

echo.
echo [INFO] Stopping services...
echo.

REM Stop processes on each port
FOR %%P IN (8761 8080 9081 9082 9083 9086) DO (
    echo [INFO] Checking port %%P...
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%%P ^| findstr LISTENING') do (
        echo [INFO] Found process %%a on port %%P
        taskkill /F /PID %%a > nul 2>&1
        if errorlevel 1 (
            echo [WARN] Could not kill process %%a
        ) else (
            echo [SUCCESS] Stopped process on port %%P
        )
    )
)

echo.
echo ========================================
echo Shutdown Complete
echo ========================================
echo.
goto :end

:cancel
echo.
echo [INFO] Shutdown cancelled
echo.

:end
pause
