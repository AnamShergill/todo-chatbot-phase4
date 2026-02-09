# 📸 Screenshots for Submission

## Required Screenshots

### 1. All Kubernetes Resources Running
**Command**:
```powershell
kubectl get all -n todo-app
```

**What to show**:
- All 3 pods in Running status (1/1 Ready)
- All 3 services configured
- Deployments and StatefulSet healthy

---

### 2. Persistent Storage
**Command**:
```powershell
kubectl get pvc -n todo-app
```

**What to show**:
- PVC bound to volume
- 5Gi capacity
- Status: Bound

---

### 3. Backend Health Check
**Command**:
```powershell
curl http://localhost:8000/health
```

**What to show**:
- JSON response: `{"status":"healthy"}`
- HTTP 200 status

---

### 4. Complete Test Suite Results
**Command**:
```powershell
./k8s/scripts/test-complete-flow.ps1
```

**What to show**:
- All 10 tests passing
- Green checkmarks for each test
- "ALL TESTS PASSED" message

---

### 5. Frontend UI - Login Page
**URL**: http://localhost:3000

**What to show**:
- Clean, modern UI
- Login form visible
- "Get Started" button
- TodoBoom branding

---

### 6. Frontend UI - Registration Page
**URL**: http://localhost:3000/register

**What to show**:
- Registration form with fields:
  - Name
  - Email
  - Password
  - Confirm Password
- "Sign up" button

---

### 7. Frontend UI - Welcome Page
**After successful registration**

**What to show**:
- Welcome message
- "Welcome to TodoBoom! 💥"
- "Go to Dashboard" button
- Feature cards (Organize, Track, Achieve)

---

### 8. Frontend UI - Dashboard
**URL**: http://localhost:3000/dashboard

**What to show**:
- Dashboard loaded successfully
- User logged in (no redirect to login)
- Task list visible
- Navigation working

---

### 9. Database Tables
**Command**:
```powershell
kubectl exec -n todo-app todo-postgres-0 -- psql -U postgres -d todo_chatbot -c "\dt"
```

**What to show**:
- List of tables:
  - users
  - tasks
  - conversations
  - messages

---

### 10. Database Users
**Command**:
```powershell
kubectl exec -n todo-app todo-postgres-0 -- psql -U postgres -d todo_chatbot -c "SELECT id, email, name FROM users;"
```

**What to show**:
- Registered users in database
- User IDs, emails, names

---

### 11. Pod Logs - Backend
**Command**:
```powershell
kubectl logs -n todo-app -l app=todo-backend --tail=20
```

**What to show**:
- Application startup logs
- Health check requests
- API requests being processed
- No errors

---

### 12. Pod Logs - Frontend
**Command**:
```powershell
kubectl logs -n todo-app -l app=todo-frontend --tail=20
```

**What to show**:
- Next.js server running
- Port 3000 listening
- No errors

---

## Optional Screenshots (Bonus Points)

### 13. Helm Releases
**Command**:
```powershell
helm list -n todo-app
```

**What to show**:
- All 3 Helm releases deployed
- Status: deployed
- Revision numbers

---

### 14. Secrets (Redacted)
**Command**:
```powershell
kubectl get secrets -n todo-app
```

**What to show**:
- Secrets created (names only, not values)
- todo-backend-secret
- todo-postgres-secret

---

### 15. ConfigMaps
**Command**:
```powershell
kubectl get configmaps -n todo-app
```

**What to show**:
- ConfigMaps created
- todo-backend-config
- todo-frontend-config
- todo-postgres-init

---

### 16. Service Endpoints
**Command**:
```powershell
kubectl get endpoints -n todo-app
```

**What to show**:
- Endpoints for each service
- IP addresses assigned

---

### 17. Resource Usage
**Command**:
```powershell
kubectl top pods -n todo-app
```

**What to show**:
- CPU and memory usage for each pod
- Resource efficiency

---

### 18. Describe Pod (Backend)
**Command**:
```powershell
kubectl describe pod -n todo-app -l app=todo-backend
```

**What to show**:
- Pod details
- Events showing successful startup
- No errors or warnings

---

## Screenshot Organization

### Recommended Structure
```
screenshots/
├── 01-kubernetes-resources.png
├── 02-persistent-storage.png
├── 03-backend-health.png
├── 04-test-results.png
├── 05-frontend-login.png
├── 06-frontend-register.png
├── 07-frontend-welcome.png
├── 08-frontend-dashboard.png
├── 09-database-tables.png
├── 10-database-users.png
├── 11-backend-logs.png
├── 12-frontend-logs.png
└── bonus/
    ├── 13-helm-releases.png
    ├── 14-secrets.png
    ├── 15-configmaps.png
    ├── 16-endpoints.png
    ├── 17-resource-usage.png
    └── 18-pod-details.png
```

---

## Tips for Taking Screenshots

1. **Use Full Screen**: Capture entire terminal/browser window
2. **High Resolution**: Use at least 1920x1080
3. **Clear Text**: Ensure all text is readable
4. **Highlight Success**: Show green checkmarks and "Running" status
5. **Timestamp**: Include timestamps where visible
6. **No Sensitive Data**: Redact any passwords or API keys
7. **Consistent Format**: Use same screenshot tool for all images
8. **Annotations**: Add arrows or highlights to important parts

---

## Quick Screenshot Script

```powershell
# Create screenshots directory
New-Item -ItemType Directory -Force -Path screenshots

# Run all commands and save output
kubectl get all -n todo-app > screenshots/01-resources.txt
kubectl get pvc -n todo-app > screenshots/02-storage.txt
curl http://localhost:8000/health > screenshots/03-health.txt
./k8s/scripts/test-complete-flow.ps1 > screenshots/04-tests.txt

Write-Host "Screenshots prepared! Take manual screenshots of:"
Write-Host "- Frontend UI at http://localhost:3000"
Write-Host "- Registration flow"
Write-Host "- Dashboard"
```

---

## Submission Checklist

- [ ] All 12 required screenshots taken
- [ ] Screenshots are clear and readable
- [ ] No sensitive information visible
- [ ] Screenshots organized in folder
- [ ] README.md included with screenshot descriptions
- [ ] All tests passing in screenshots
- [ ] UI screenshots show working application
- [ ] Database screenshots show data

---

**Ready to submit!** 🎉
