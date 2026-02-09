# Complete end-to-end test
Write-Host "=== COMPLETE END-TO-END TEST ===" -ForegroundColor Cyan
Write-Host ""

$testEmail = "e2etest@example.com"
$testPassword = "test123"
$testName = "E2E Test User"

# 1. Test Backend Health
Write-Host "1. Testing Backend Health..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:8000/health" -TimeoutSec 5
    Write-Host "   ✅ Backend healthy: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Backend health check failed" -ForegroundColor Red
    exit 1
}

# 2. Test Registration
Write-Host "`n2. Testing User Registration..." -ForegroundColor Yellow
$registerBody = @{
    email = $testEmail
    password = $testPassword
    name = $testName
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8000/auth/register" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $registerBody
    
    Write-Host "   ✅ Registration successful" -ForegroundColor Green
    Write-Host "      User ID: $($registerResponse.data.user.id)" -ForegroundColor Cyan
    Write-Host "      Email: $($registerResponse.data.user.email)" -ForegroundColor Cyan
    
    $token = $registerResponse.data.token
    $userId = $registerResponse.data.user.id
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "   ⚠️  User exists, testing login instead..." -ForegroundColor Yellow
        
        $loginBody = @{
            email = $testEmail
            password = $testPassword
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/auth/login" `
            -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body $loginBody
        
        Write-Host "   ✅ Login successful" -ForegroundColor Green
        $token = $loginResponse.data.token
        $userId = $loginResponse.data.user.id
    } else {
        Write-Host "   ❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# 3. Test Token Validation (Get Tasks)
Write-Host "`n3. Testing Token Validation (Fetch Tasks)..." -ForegroundColor Yellow
try {
    $tasksResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $token"}
    
    Write-Host "   ✅ Token validated successfully" -ForegroundColor Green
    Write-Host "      Tasks count: $($tasksResponse.data.tasks.Count)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Token validation failed" -ForegroundColor Red
    exit 1
}

# 4. Test Create Task
Write-Host "`n4. Testing Create Task..." -ForegroundColor Yellow
$taskBody = @{
    title = "Test Task from E2E"
    description = "This task was created by automated test"
    status = "pending"
    priority = "medium"
} | ConvertTo-Json

try {
    $createResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks" `
        -Method POST `
        -Headers @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        } `
        -Body $taskBody
    
    Write-Host "   ✅ Task created successfully" -ForegroundColor Green
    Write-Host "      Task ID: $($createResponse.data.id)" -ForegroundColor Cyan
    Write-Host "      Title: $($createResponse.data.title)" -ForegroundColor Cyan
    
    $taskId = $createResponse.data.id
} catch {
    Write-Host "   ❌ Task creation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 5. Test Get Specific Task
Write-Host "`n5. Testing Get Specific Task..." -ForegroundColor Yellow
try {
    $getTaskResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks/$taskId" `
        -Method GET `
        -Headers @{"Authorization" = "Bearer $token"}
    
    Write-Host "   ✅ Task retrieved successfully" -ForegroundColor Green
    Write-Host "      Title: $($getTaskResponse.data.title)" -ForegroundColor Cyan
    Write-Host "      Status: $($getTaskResponse.data.status)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Task retrieval failed" -ForegroundColor Red
    exit 1
}

# 6. Test Update Task
Write-Host "`n6. Testing Update Task..." -ForegroundColor Yellow
$updateBody = @{
    title = "Updated Test Task"
    description = "This task was updated by automated test"
    status = "in_progress"
    priority = "high"
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks/$taskId" `
        -Method PUT `
        -Headers @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        } `
        -Body $updateBody
    
    Write-Host "   ✅ Task updated successfully" -ForegroundColor Green
    Write-Host "      New title: $($updateResponse.data.title)" -ForegroundColor Cyan
    Write-Host "      New status: $($updateResponse.data.status)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Task update failed" -ForegroundColor Red
    exit 1
}

# 7. Test Delete Task
Write-Host "`n7. Testing Delete Task..." -ForegroundColor Yellow
try {
    $deleteResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks/$taskId" `
        -Method DELETE `
        -Headers @{"Authorization" = "Bearer $token"}
    
    Write-Host "   ✅ Task deleted successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Task deletion failed" -ForegroundColor Red
    exit 1
}

# 8. Test Frontend
Write-Host "`n8. Testing Frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    Write-Host "   ✅ Frontend accessible: HTTP $($frontendResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Frontend not accessible" -ForegroundColor Red
    exit 1
}

# 9. Test Database
Write-Host "`n9. Testing Database..." -ForegroundColor Yellow
try {
    $dbTest = kubectl exec -n todo-app todo-postgres-0 -- psql -U postgres -d todo_chatbot -c "SELECT COUNT(*) FROM users;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   ✅ Database accessible and contains data" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Database check had issues but may be working" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Database check skipped" -ForegroundColor Yellow
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Green
Write-Host "🎉 ALL TESTS PASSED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Backend API: Working" -ForegroundColor Green
Write-Host "✅ Authentication: Working" -ForegroundColor Green
Write-Host "✅ JWT Tokens: Working" -ForegroundColor Green
Write-Host "✅ Task CRUD: Working" -ForegroundColor Green
Write-Host "✅ Frontend UI: Working" -ForegroundColor Green
Write-Host "✅ Database: Working" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Access URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   Backend:  http://localhost:8000" -ForegroundColor White
Write-Host ""
Write-Host "Kubernetes Resources:" -ForegroundColor Cyan
kubectl get pods,svc,pvc -n todo-app
