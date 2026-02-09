# Verify Deployment - Todo Chatbot Kubernetes
# Usage: .\verify-deployment.ps1

Write-Host "🔍 Verifying Todo Chatbot Deployment..." -ForegroundColor Green

$allPassed = $true

# Check cluster
Write-Host "`n1️⃣  Checking Minikube cluster..." -ForegroundColor Yellow
$status = minikube -p todo-chatbot status 2>&1
if ($status -match "Running") {
    Write-Host "✅ Cluster is running" -ForegroundColor Green
} else {
    Write-Host "❌ Cluster is not running" -ForegroundColor Red
    $allPassed = $false
}

# Check namespace
Write-Host "`n2️⃣  Checking namespace..." -ForegroundColor Yellow
$ns = kubectl get namespace todo-app -o name 2>&1
if ($ns -match "todo-app") {
    Write-Host "✅ Namespace exists" -ForegroundColor Green
} else {
    Write-Host "❌ Namespace not found" -ForegroundColor Red
    $allPassed = $false
}

# Check pods
Write-Host "`n3️⃣  Checking pods..." -ForegroundColor Yellow
$pods = kubectl get pods -n todo-app -o json | ConvertFrom-Json
$runningPods = ($pods.items | Where-Object { $_.status.phase -eq "Running" }).Count
$totalPods = $pods.items.Count
Write-Host "Running: $runningPods/$totalPods" -ForegroundColor Cyan
if ($runningPods -eq $totalPods -and $totalPods -ge 3) {
    Write-Host "✅ All pods running" -ForegroundColor Green
} else {
    Write-Host "❌ Some pods not running" -ForegroundColor Red
    $allPassed = $false
}

# Check services
Write-Host "`n4️⃣  Checking services..." -ForegroundColor Yellow
$services = kubectl get svc -n todo-app -o name 2>&1
$svcCount = ($services | Measure-Object).Count
Write-Host "Services found: $svcCount" -ForegroundColor Cyan
if ($svcCount -ge 3) {
    Write-Host "✅ All services created" -ForegroundColor Green
} else {
    Write-Host "❌ Missing services" -ForegroundColor Red
    $allPassed = $false
}

# Check PVC
Write-Host "`n5️⃣  Checking persistent volume..." -ForegroundColor Yellow
$pvc = kubectl get pvc -n todo-app -o json | ConvertFrom-Json
if ($pvc.items[0].status.phase -eq "Bound") {
    Write-Host "✅ PVC is bound" -ForegroundColor Green
} else {
    Write-Host "❌ PVC not bound" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host "`n================================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "ALL CHECKS PASSED!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "SOME CHECKS FAILED" -ForegroundColor Red
    exit 1
}
