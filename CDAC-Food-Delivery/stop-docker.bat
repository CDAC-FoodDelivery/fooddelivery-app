@echo off
REM ============================================
REM Food Delivery Application - Docker Shutdown
REM ============================================

echo.
echo ============================================
echo    Stopping Food Delivery Application
echo ============================================
echo.

docker-compose down

echo.
echo All containers stopped.
echo.

choice /C YN /M "Remove data volumes (fresh start next time)"
if errorlevel 2 goto :end
docker volume rm cdac-food-delivery_mysql-data 2>nul
echo Data volumes removed.

:end
echo.
pause
