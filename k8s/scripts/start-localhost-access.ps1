# Start localhost access for frontend and backend
Write-Host "Setting up localhost access..." -ForegroundColor Cyan

# Check if port-forwards are already running
$existingForwards = Get-Process -Name kubectl -ErrorAction SilentlyContinue
if ($existingForwards) {
    Write-Host "Stopping existing port-forwards..." -ForegroundColor Yellow
    Stop-Process -Name kubectl -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

Write-Host "`nCurrent services:" -ForegroundColor Cyan
kubectl get svc -n todo-app

Write-Host "`nStarting port-forwards..." -ForegroundColor Cyan

# Start backend port-forward (8000)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Backend port-forward (localhost:8000)' -ForegroundColor Green; kubectl port-forward -n todo-app svc/todo-backend 8000:8000" -WindowStyle Minimized

Start-Sleep -Seconds 2

# Start frontend port-forward (3000)
Start-Process powershell -ArgumentList "-NoExit", "-Command", "Write-Host 'Frontend port-forward (localhost:3000)' -ForegroundColor Green; kubectl port-forward -n todo-app svc/todo-frontend 3000:80" -WindowStyle Minimized

Start-Sleep -Seconds 3

Write-Host "`nPort-forwards started!" -ForegroundColor Green
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor Cyan
Write-Host "   Backend:  http://localhost:8000" -ForegroundColor Cyan

Write-Host "`nTesting connections..." -ForegroundColor Yellow

# Test backend
try {
    $backendTest = Invoke-RestMethod -Uri "http://localhost:8000/health" -TimeoutSec 5
    Write-Host "Backend health check: $($backendTest.status)" -ForegroundColor Green
} catch {
    Write-Host "Backend not ready yet (may still be starting)" -ForegroundColor Yellow
}

# Test frontend
try {
    $frontendTest = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "Frontend responding: HTTP $($frontendTest.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "Frontend not ready yet (may still be starting)" -ForegroundColor Yellow
}

Write-Host "`nOpen in browser:" -ForegroundColor Cyan
Write-Host "   http://localhost:3000" -ForegroundColor White

Write-Host "`nTo stop port-forwards, run:" -ForegroundColor Yellow
Write-Host "   ./k8s/scripts/stop-localhost-access.ps1" -ForegroundColor White
