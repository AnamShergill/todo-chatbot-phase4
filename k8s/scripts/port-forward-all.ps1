# Port-forward both frontend and backend for local testing
Write-Host "🚀 Starting port-forwards..." -ForegroundColor Cyan
Write-Host "Frontend will be at: http://localhost:3000" -ForegroundColor Green
Write-Host "Backend will be at: http://localhost:8000" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop all port-forwards" -ForegroundColor Yellow
Write-Host ""

# Start backend port-forward in background
$backendJob = Start-Job -ScriptBlock {
    kubectl port-forward -n todo-app svc/todo-backend 8000:8000
}

# Start frontend port-forward in background
$frontendJob = Start-Job -ScriptBlock {
    kubectl port-forward -n todo-app svc/todo-frontend 3000:80
}

Write-Host "✅ Port-forwards started" -ForegroundColor Green
Write-Host "   Backend Job ID: $($backendJob.Id)" -ForegroundColor Cyan
Write-Host "   Frontend Job ID: $($frontendJob.Id)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open http://localhost:3000 in your browser" -ForegroundColor Yellow
Write-Host ""

# Wait for user to press Ctrl+C
try {
    while ($true) {
        Start-Sleep -Seconds 1
        
        # Check if jobs are still running
        if ($backendJob.State -ne 'Running') {
            Write-Host "⚠️  Backend port-forward stopped" -ForegroundColor Red
            break
        }
        if ($frontendJob.State -ne 'Running') {
            Write-Host "⚠️  Frontend port-forward stopped" -ForegroundColor Red
            break
        }
    }
} finally {
    Write-Host "`n🛑 Stopping port-forwards..." -ForegroundColor Yellow
    Stop-Job -Job $backendJob, $frontendJob -ErrorAction SilentlyContinue
    Remove-Job -Job $backendJob, $frontendJob -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Port-forwards stopped" -ForegroundColor Green
}
