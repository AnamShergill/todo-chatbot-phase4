# Cleanup - Todo Chatbot Kubernetes Deployment
# Usage: .\cleanup.ps1 [-DeleteCluster]

param(
    [switch]$DeleteCluster
)

Write-Host "🧹 Cleaning up Todo Chatbot deployment..." -ForegroundColor Yellow

# Uninstall Helm releases
Write-Host "`n📦 Uninstalling Helm releases..." -ForegroundColor Yellow
helm uninstall todo-frontend -n todo-app 2>$null
helm uninstall todo-backend -n todo-app 2>$null
helm uninstall todo-postgres -n todo-app 2>$null
Write-Host "✅ Helm releases removed" -ForegroundColor Green

# Delete namespace
Write-Host "`n🗑️  Deleting namespace..." -ForegroundColor Yellow
kubectl delete namespace todo-app --timeout=60s
Write-Host "✅ Namespace deleted" -ForegroundColor Green

# Optionally delete cluster
if ($DeleteCluster) {
    Write-Host "`n🔥 Deleting Minikube cluster..." -ForegroundColor Red
    minikube -p todo-chatbot delete
    Write-Host "✅ Cluster deleted" -ForegroundColor Green
} else {
    Write-Host "`n⏸️  Stopping Minikube cluster..." -ForegroundColor Yellow
    minikube -p todo-chatbot stop
    Write-Host "✅ Cluster stopped (use -DeleteCluster to delete)" -ForegroundColor Green
}

Write-Host "`n🎉 Cleanup complete!" -ForegroundColor Green
