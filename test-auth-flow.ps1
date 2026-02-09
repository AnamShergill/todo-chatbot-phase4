# Test the complete auth flow
Write-Host "🧪 Testing Authentication Flow..." -ForegroundColor Cyan

# Register a new user
Write-Host "`n1. Testing Registration..." -ForegroundColor Yellow
$registerBody = @{
    email = "flowtest@example.com"
    password = "test123"
    name = "Flow Test User"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8000/auth/register" `
        -Method POST `
        -Headers @{"Content-Type"="application/json"} `
        -Body $registerBody
    
    Write-Host "✅ Registration successful!" -ForegroundColor Green
    Write-Host "   User ID: $($registerResponse.data.user.id)" -ForegroundColor Cyan
    Write-Host "   Token: $($registerResponse.data.token.Substring(0,20))..." -ForegroundColor Cyan
    
    $token = $registerResponse.data.token
    $userId = $registerResponse.data.user.id
    
    # Test fetching tasks with the token
    Write-Host "`n2. Testing Task Fetch with Token..." -ForegroundColor Yellow
    $taskResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $token"
        }
    
    Write-Host "✅ Task fetch successful!" -ForegroundColor Green
    Write-Host "   Tasks count: $($taskResponse.data.tasks.Count)" -ForegroundColor Cyan
    
    Write-Host "`n🎉 AUTH FLOW WORKING! Registration and API calls succeed." -ForegroundColor Green
    
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "⚠️  User already exists, trying login instead..." -ForegroundColor Yellow
        
        # Try login
        $loginBody = @{
            email = "flowtest@example.com"
            password = "test123"
        } | ConvertTo-Json
        
        $loginResponse = Invoke-RestMethod -Uri "http://localhost:8000/auth/login" `
            -Method POST `
            -Headers @{"Content-Type"="application/json"} `
            -Body $loginBody
        
        Write-Host "✅ Login successful!" -ForegroundColor Green
        $token = $loginResponse.data.token
        $userId = $loginResponse.data.user.id
        
        # Test fetching tasks
        Write-Host "`n2. Testing Task Fetch with Token..." -ForegroundColor Yellow
        $taskResponse = Invoke-RestMethod -Uri "http://localhost:8000/api/$userId/tasks" `
            -Method GET `
            -Headers @{
                "Authorization" = "Bearer $token"
            }
        
        Write-Host "✅ Task fetch successful!" -ForegroundColor Green
        Write-Host "   Tasks count: $($taskResponse.data.tasks.Count)" -ForegroundColor Cyan
        
        Write-Host "`n🎉 AUTH FLOW WORKING! Login and API calls succeed." -ForegroundColor Green
    } else {
        Write-Host "❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}
