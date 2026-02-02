# Remove All Markdown Files Script
# This script removes all .md files from the project

Write-Host "Searching for all .md files in the project..." -ForegroundColor Yellow

$projectRoot = "f:\FLUTTER\CDAC-Food-Delivery_v1\CDAC-Food-Delivery"
Set-Location $projectRoot

# Find all .md files recursively
$mdFiles = Get-ChildItem -Path $projectRoot -Filter "*.md" -Recurse -File

Write-Host "Found $($mdFiles.Count) markdown files" -ForegroundColor Cyan
Write-Host ""

if ($mdFiles.Count -eq 0) {
    Write-Host "No markdown files found to remove." -ForegroundColor Green
    exit 0
}

# List all files that will be removed
Write-Host "The following files will be removed:" -ForegroundColor Yellow
foreach ($file in $mdFiles) {
    $relativePath = $file.FullName.Replace($projectRoot + "\", "")
    Write-Host "  - $relativePath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Removing all markdown files..." -ForegroundColor Yellow

$removedCount = 0
foreach ($file in $mdFiles) {
    try {
        Remove-Item $file.FullName -Force
        $relativePath = $file.FullName.Replace($projectRoot + "\", "")
        Write-Host "  Removed: $relativePath" -ForegroundColor Green
        $removedCount++
    }
    catch {
        Write-Host "  Failed to remove: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Removal Complete!" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total markdown files removed: $removedCount" -ForegroundColor White
Write-Host ""
