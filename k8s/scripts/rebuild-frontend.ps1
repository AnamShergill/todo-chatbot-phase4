# Rebuild frontend with correct API URL for Kubernetes
Write-Host "🔨 Rebuilding frontend with Kubernetes backend URL..." -ForegroundColor Cyan

# Build with correct environment variable
docker build `
  --build-arg NEXT_PUBLIC_API_BASE_URL=http://todo-backend.todo-app.svc.cluster.local:8000 `
  --build-arg NEXT_PUBLIC_CHATKIT_ENABLED=true `
  -t todo-frontend:k8s `
  ./frontend

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Frontend image built successfully" -ForegroundColor Green

# Load into minikube
Write-Host "📦 Loading image into minikube..." -ForegroundColor Cyan
minikube image load todo-frontend:k8s

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to load image into minikube" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Image loaded into minikube" -ForegroundColor Green

# Update deployment to use new image
Write-Host "🔄 Updating frontend deployment..." -ForegroundColor Cyan
helm upgrade todo-frontend ./k8s/helm/todo-frontend `
  --set image.repository=todo-frontend `
  --set image.tag=k8s `
  --set image.pullPolicy=Never `
  -n todo-app

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Helm upgrade failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Deployment updated" -ForegroundColor Green

# Wait for rollout
Write-Host "⏳ Waiting for rollout to complete..." -ForegroundColor Cyan
kubectl rollout status deployment/todo-frontend -n todo-app --timeout=120s

Write-Host "🎉 Frontend rebuild complete! Restart port-forward and test." -ForegroundColor Green
