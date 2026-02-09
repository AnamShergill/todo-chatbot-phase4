# Deploy All Components - Todo Chatbot Kubernetes Deployment
# Usage: .\deploy-all.ps1

Write-Host "🚀 Starting Todo Chatbot Kubernetes Deployment..." -ForegroundColor Green

# Check prerequisites
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow
$minikube = Get-Command minikube -ErrorAction SilentlyContinue
$kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
$helm = Get-Command helm -ErrorAction SilentlyContinue

if (-not $minikube) { Write-Error "Minikube not found!"; exit 1 }
if (-not $kubectl) { Write-Error "kubectl not found!"; exit 1 }
if (-not $helm) { Write-Error "Helm not found!"; exit 1 }

Write-Host "✅ All prerequisites found" -ForegroundColor Green

# Start Minikube
Write-Host "`n🔧 Starting Minikube cluster..." -ForegroundColor Yellow
minikube -p todo-chatbot start
if ($LASTEXITCODE -ne 0) { Write-Error "Failed to start Minikube"; exit 1 }

# Create namespace
Write-Host "`n📦 Creating namespace..." -ForegroundColor Yellow
kubectl create namespace todo-app --dry-run=client -o yaml | kubectl apply -f -

# Deploy PostgreSQL
Write-Host "`n🗄️  Deploying PostgreSQL..." -ForegroundColor Yellow
helm upgrade --install todo-postgres k8s/helm/todo-postgres -n todo-app
kubectl wait --for=condition=Ready pod -l app=todo-postgres -n todo-app --timeout=300s

# Deploy Backend
Write-Host "`n⚙️  Deploying Backend..." -ForegroundColor Yellow
helm upgrade --install todo-backend k8s/helm/todo-backend -n todo-app
kubectl wait --for=condition=Ready pod -l app=todo-backend -n todo-app --timeout=300s

# Deploy Frontend
Write-Host "`n🌐 Deploying Frontend..." -ForegroundColor Yellow
helm upgrade --install todo-frontend k8s/helm/todo-frontend -n todo-app
kubectl wait --for=condition=Ready pod -l app=todo-frontend -n todo-app --timeout=300s

# Verify deployment
Write-Host "`n✅ Verifying deployment..." -ForegroundColor Yellow
kubectl get pods,svc -n todo-app

Write-Host "`n🎉 Deployment complete!" -ForegroundColor Green
Write-Host "`nAccess frontend:" -ForegroundColor Cyan
Write-Host "kubectl port-forward -n todo-app svc/todo-frontend 3000:80" -ForegroundColor White
Write-Host "Then open: http://localhost:3000" -ForegroundColor White
