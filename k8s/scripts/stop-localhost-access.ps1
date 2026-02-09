# Stop all port-forwards
Write-Host "🛑 Stopping localhost access..." -ForegroundColor Yellow

$kubectlProcesses = Get-Process -Name kubectl -ErrorAction SilentlyContinue

if ($kubectlProcesses) {
    Write-Host "   Found $($kubectlProcesses.Count) kubectl process(es)" -ForegroundColor Cyan
    Stop-Process -Name kubectl -Force
    Write-Host "✅ All port-forwards stopped" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No port-forwards running" -ForegroundColor Cyan
}
