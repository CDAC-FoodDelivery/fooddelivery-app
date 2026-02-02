# Cleanup Script for Deployment
# This script removes all unnecessary development files and folders

Write-Host "Starting cleanup for deployment..." -ForegroundColor Green

# Navigate to project root
$projectRoot = "f:\FLUTTER\CDAC-Food-Delivery_v1\CDAC-Food-Delivery"
Set-Location $projectRoot

# Count removed items
$removedCount = 0

# 1. Remove development documentation files from root
Write-Host ""
Write-Host "1. Removing development documentation files..." -ForegroundColor Yellow
$devDocs = @(
    "ADMINRIDER_REFACTORING_COMPLETE.md",
    "ADMIN_FINAL_FIX.md",
    "ADMIN_SERVICE_GATEWAY_FIX.md",
    "BACKEND_ANALYSIS_AND_FIXES.md",
    "COMPREHENSIVE_JSON_FIX.md",
    "CORS_FIX_GUIDE.md",
    "DATABASE_PER_SERVICE_ARCHITECTURE.md",
    "DUPLICATE_CORS_FIX.md",
    "FINAL_TRANSFORMATION_SUMMARY.md",
    "FRONTEND_ERRORS_FIX.md",
    "FRONTEND_FIXES_SUMMARY.md",
    "GATEWAY_500_ERROR_DIAGNOSTIC.md",
    "HOTEL_API_500_ERROR_FIX.md",
    "IMPLEMENTATION_SUMMARY.md",
    "JSON_DESERIALIZATION_FIX.md",
    "JSON_NAMING_MISMATCH_FIX.md",
    "MENU_SERVICE_CRUD_FIX.md",
    "MICROSERVICES_TRANSFORMATION_COMPLETE.md",
    "NULL_FIELDS_DATABASE_FIX.md",
    "RIDER_AUTHENTICATION_FIX.md"
)

foreach ($file in $devDocs) {
    $filePath = Join-Path $projectRoot $file
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "  Removed: $file" -ForegroundColor Gray
        $removedCount++
    }
}

# 2. Remove development scripts
Write-Host ""
Write-Host "2. Removing development scripts..." -ForegroundColor Yellow
$devScripts = @(
    "verify-rider-fix.ps1",
    "tables.txt"
)

foreach ($file in $devScripts) {
    $filePath = Join-Path $projectRoot $file
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "  Removed: $file" -ForegroundColor Gray
        $removedCount++
    }
}

# 3. Remove IDE-specific folders
Write-Host ""
Write-Host "3. Removing IDE-specific folders..." -ForegroundColor Yellow
$ideFolders = @(
    ".vscode",
    "backend\.idea"
)

foreach ($folder in $ideFolders) {
    $folderPath = Join-Path $projectRoot $folder
    if (Test-Path $folderPath) {
        Remove-Item $folderPath -Recurse -Force
        Write-Host "  Removed: $folder" -ForegroundColor Gray
        $removedCount++
    }
}

# 4. Remove frontend build artifacts and dev folders
Write-Host ""
Write-Host "4. Removing frontend build artifacts..." -ForegroundColor Yellow
$frontendCleanup = @(
    "frontend\node_modules",
    "frontend\.vite",
    "frontend\dist"
)

foreach ($folder in $frontendCleanup) {
    $folderPath = Join-Path $projectRoot $folder
    if (Test-Path $folderPath) {
        Remove-Item $folderPath -Recurse -Force
        Write-Host "  Removed: $folder" -ForegroundColor Gray
        $removedCount++
    }
}

# 5. Remove backend development files
Write-Host ""
Write-Host "5. Removing backend development files..." -ForegroundColor Yellow
$backendDevFiles = @(
    "backend\BUILD_ALL_SERVICES.md",
    "backend\FOODDELIVERY BACKEND sql.txt",
    "backend\MENU-BACKEND sql file.txt",
    "backend\build-all.ps1",
    "backend\set-java-17.ps1"
)

foreach ($file in $backendDevFiles) {
    $filePath = Join-Path $projectRoot $file
    if (Test-Path $filePath) {
        Remove-Item $filePath -Force
        Write-Host "  Removed: $file" -ForegroundColor Gray
        $removedCount++
    }
}

# 6. Remove target folders from Java projects (build artifacts)
Write-Host ""
Write-Host "6. Removing Java build artifacts (target folders)..." -ForegroundColor Yellow
$javaProjects = @(
    "backend\discovery-server",
    "backend\api-gateway",
    "backend\AuthService",
    "backend\fooddelivery_backend",
    "backend\Menu-backend"
)

foreach ($project in $javaProjects) {
    $targetPath = Join-Path $projectRoot "$project\target"
    if (Test-Path $targetPath) {
        Remove-Item $targetPath -Recurse -Force
        Write-Host "  Removed: $project\target" -ForegroundColor Gray
        $removedCount++
    }
}

# 7. Remove .NET build artifacts
Write-Host ""
Write-Host "7. Removing .NET build artifacts..." -ForegroundColor Yellow
$dotnetProjects = @(
    "backend\AdminRiderService"
)

foreach ($project in $dotnetProjects) {
    $binPath = Join-Path $projectRoot "$project\bin"
    $objPath = Join-Path $projectRoot "$project\obj"
    
    if (Test-Path $binPath) {
        Remove-Item $binPath -Recurse -Force
        Write-Host "  Removed: $project\bin" -ForegroundColor Gray
        $removedCount++
    }
    
    if (Test-Path $objPath) {
        Remove-Item $objPath -Recurse -Force
        Write-Host "  Removed: $project\obj" -ForegroundColor Gray
        $removedCount++
    }
}

# 8. Create a deployment-ready documentation file
Write-Host ""
Write-Host "8. Creating deployment documentation..." -ForegroundColor Yellow
$deploymentDoc = @"
# Food Delivery Application - Deployment Guide

## Project Structure
This is a microservices-based food delivery application with the following components:

### Backend Services
- **Discovery Server**: Eureka service registry (Port: 8761)
- **API Gateway**: Central routing gateway (Port: 8080)
- **AuthService**: Authentication service (Port: 9081)
- **FoodDelivery Backend**: Main backend service (Port: 9082)
- **Menu Backend**: Menu management service (Port: 9083)
- **AdminRider Service**: Admin and rider management (.NET service, Port: 9086)

### Frontend
- React-based frontend application
- Default port: 5173

## Prerequisites
- Java 17+
- .NET 8.0+
- MySQL 8.0+
- Node.js 18+
- npm or yarn

## Database Setup
Run the SQL script to set up all required databases:
``````sql
mysql -u root -p < setup-databases.sql
``````

## Starting the Application

### 1. Start Backend Services (in order)
``````bash
# Start Discovery Server first
cd backend/discovery-server
mvn spring-boot:run

# Wait for discovery server to be up, then start API Gateway
cd backend/api-gateway
mvn spring-boot:run

# Start microservices
cd backend/AuthService
mvn spring-boot:run

cd backend/fooddelivery_backend
mvn spring-boot:run

cd backend/Menu-backend
mvn spring-boot:run

# Start .NET service
cd backend/AdminRiderService
dotnet run
``````

Or use the batch files:
``````bash
cd backend
start-microservices.bat
``````

### 2. Start Frontend
``````bash
cd frontend
npm install
npm run dev
``````

## Access Points
- Frontend: http://localhost:5173
- API Gateway: http://localhost:8080
- Discovery Server: http://localhost:8761

## Important Files
- **README.md**: Detailed project documentation
- **API_REFERENCE.md**: API endpoint documentation
- **QUICK_REFERENCE.md**: Quick command reference
- **QUICK_START.md**: Quick start guide
- **setup-databases.sql**: Database initialization script
- **backend/start-microservices.bat**: Start all backend services
- **backend/stop-microservices.bat**: Stop all backend services

## Documentation
See the /docs folder for architecture diagrams and detailed documentation:
- ARCHITECTURE_FLOW.md
- MICROSERVICES_ARCHITECTURE.md
- CONFIGURATION_SUMMARY.md
- ER Diagram.png
- RelationalSchema.png

## Support
For issues or questions, refer to the documentation in the /docs folder.
"@

$deploymentDocPath = Join-Path $projectRoot "DEPLOYMENT_GUIDE.md"
Set-Content -Path $deploymentDocPath -Value $deploymentDoc
Write-Host "  Created: DEPLOYMENT_GUIDE.md" -ForegroundColor Gray

# Summary
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Cleanup Complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total items removed: $removedCount" -ForegroundColor White
Write-Host ""
Write-Host "Your project is now ready for deployment!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review DEPLOYMENT_GUIDE.md for deployment instructions" -ForegroundColor White
Write-Host "2. Run npm install in the frontend folder before deployment" -ForegroundColor White
Write-Host "3. Build the frontend with npm run build if needed" -ForegroundColor White
Write-Host "4. Review and update configuration files with production settings" -ForegroundColor White
Write-Host ""
