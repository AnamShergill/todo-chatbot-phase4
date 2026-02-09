# Todo Chatbot - Kubernetes Deployment Quickstart

**Last Updated**: February 9, 2026 - 11:00 PM PKT
**Status**: Phase 4 Complete (85%), Phase 5 Verification In Progress

## Current Deployment Status

### ✅ Completed
- Minikube cluster running (profile: `todo-chatbot`)
- All 3 pods deployed and running:
  - `todo-postgres-0` - PostgreSQL database with persistent storage
  - `todo-backend-*` - FastAPI backend with MCP server
  - `todo-frontend-*` - Next.js frontend
- Services exposed via NodePort
- Database initialized with schema
- Backend connected to database
- Frontend configured with internal service URL

### 🔄 In Progress
- User registration endpoint verification (known 404 issue being investigated)

## Quick Access

### ✅ Option 1: Port Forward to Pod (RECOMMENDED)
```powershell
# Get frontend pod name
kubectl get pods -n todo-app -l app=todo-frontend

# Port forward to pod (use actual pod name from above)
kubectl port-forward -n todo-app pod/todo-frontend-7cbfb79fd8-h2pp6 3000:3000

# Open browser at:
http://localhost:3000
```

### Option 2: Minikube Service Tunnel
```powershell
# Start tunnel (keeps running - use separate terminal)
minikube -p todo-chatbot service todo-frontend -n todo-app --url

# Use the URL provided (e.g., http://127.0.0.1:56962)
```

### Option 3: Direct NodePort Access
```powershell
# Get Minikube IP
minikube -p todo-chatbot ip

# Access at (replace IP if different):
http://192.168.49.2:30555
```

### Backend Access (for API testing)
```powershell
# Port forward backend
kubectl port-forward -n todo-app svc/todo-backend 8000:8000

# Test health endpoint
Invoke-WebRequest -Uri http://localhost:8000/health
```

## Fast Verification Commands

### 1. Check All Pods Running
```bash
kubectl get pods -n todo-app
```
Expected: All pods show `1/1 Running`

### 2. Check Services
```bash
kubectl get svc -n todo-app
```
Expected: 
- `todo-frontend` NodePort 80:30555
- `todo-backend` NodePort 8000:31195
- `todo-postgres` ClusterIP 5432

### 3. Test Backend Health
```bash
curl http://192.168.49.2:31195/health
```
Expected: `{"status":"ok"}`

### 4. Test Frontend Loading
```bash
curl -I http://192.168.49.2:30555
```
Expected: `200 OK` with HTML content

### 5. Check Backend Logs
```bash
kubectl logs -n todo-app -l app=todo-backend --tail=20
```

### 6. Check Frontend Logs
```bash
kubectl logs -n todo-app -l app=todo-frontend --tail=20
```

## ✅ VERIFIED WORKING (as of 11:45 PM PKT)

### Infrastructure
- ✅ All 3 pods running (postgres, backend, frontend)
- ✅ All services created with correct ports
- ✅ Persistent volume bound (5Gi)
- ✅ Database schema initialized (users, tasks, conversations, messages)

### Application
- ✅ Frontend UI loads at http://localhost:3000
- ✅ Backend health endpoint responding
- ✅ Pod-to-pod connectivity working
- ✅ Next.js server running on port 3000

### Screenshots
![Frontend UI Loading](screenshots/frontend-ui-loads.png)
![All Pods Running](screenshots/pods-running.png)

## Known Issues

### ⚠️ User Registration 404 Error
**Status**: Under investigation
**Symptom**: POST to `/auth/register` returns 404
**Workaround**: None yet - marked as post-deadline task
**Impact**: Cannot create new users via UI
**Root Cause**: Frontend calling wrong API URL or backend endpoint mismatch

**Investigation Steps Taken**:
1. ✅ Verified backend endpoint exists at `/auth/register`
2. ✅ Updated frontend `.env.local` with correct internal service URL
3. ✅ Rebuilt frontend Docker image with `--no-cache`
4. ✅ Redeployed frontend Helm chart
5. 🔄 Needs browser testing to confirm fix

**Next Steps** (Post-Deadline):
- Test registration in browser at `http://192.168.49.2:30555`
- Check browser Network tab for actual request URL
- Verify frontend environment variables are correctly injected
- Consider direct pod-to-pod connectivity test

## Working Features

### ✅ Verified Working
- Database persistence (PostgreSQL with PVC)
- Backend health endpoint
- Pod-to-pod connectivity (frontend can reach backend internally)
- Service discovery within cluster
- Helm chart deployments
- Resource limits and probes

### 🔄 Needs Testing
- User registration via UI
- User login via UI
- Task CRUD operations via UI
- AI chatbot functionality
- Session persistence

## Deployment Architecture

```
┌─────────────────────────────────────────────────┐
│           Minikube Cluster (todo-chatbot)       │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │      Namespace: todo-app                 │  │
│  │                                          │  │
│  │  ┌──────────────┐    ┌──────────────┐  │  │
│  │  │  Frontend    │───▶│   Backend    │  │  │
│  │  │  (Next.js)   │    │  (FastAPI)   │  │  │
│  │  │  Port: 3000  │    │  Port: 8000  │  │  │
│  │  │  NodePort:   │    │  NodePort:   │  │  │
│  │  │  30555       │    │  31195       │  │  │
│  │  └──────────────┘    └──────┬───────┘  │  │
│  │                              │          │  │
│  │                              ▼          │  │
│  │                      ┌──────────────┐  │  │
│  │                      │  PostgreSQL  │  │  │
│  │                      │  Port: 5432  │  │  │
│  │                      │  PVC: 5Gi    │  │  │
│  │                      └──────────────┘  │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
         ▲
         │ Access via: http://192.168.49.2:30555
         │
    Host Machine
```

## Environment Configuration

### Frontend Environment
```
NEXT_PUBLIC_API_BASE_URL=http://todo-backend.todo-app.svc.cluster.local:8000
NEXT_PUBLIC_BETTER_AUTH_URL=http://todo-backend.todo-app.svc.cluster.local:8000
```

### Backend Environment
```
DATABASE_URL=postgresql://postgres:<password>@todo-postgres:5432/todo_chatbot
JWT_SECRET=<generated>
OPENAI_API_KEY=<placeholder>
FRONTEND_URL=http://todo-frontend
LOG_LEVEL=info
```

### Database Credentials
```
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<generated>
POSTGRES_DB=todo_chatbot
```

## Troubleshooting

### Pod Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name> -n todo-app

# Check logs
kubectl logs <pod-name> -n todo-app
```

### Service Not Accessible
```bash
# Check endpoints
kubectl get endpoints -n todo-app

# Test from within cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -n todo-app -- curl http://todo-backend:8000/health
```

### Database Connection Issues
```bash
# Check postgres logs
kubectl logs todo-postgres-0 -n todo-app

# Test connection from backend pod
kubectl exec -it deployment/todo-backend -n todo-app -- curl http://todo-postgres:5432
```

### Minikube Issues
```bash
# Check minikube status
minikube -p todo-chatbot status

# Restart if needed
minikube -p todo-chatbot stop
minikube -p todo-chatbot start
```

## Cleanup Commands

### Remove Deployment (Keep Cluster)
```bash
helm uninstall todo-frontend -n todo-app
helm uninstall todo-backend -n todo-app
helm uninstall todo-postgres -n todo-app
kubectl delete namespace todo-app
```

### Full Cleanup (Remove Everything)
```bash
# Delete namespace
kubectl delete namespace todo-app

# Stop minikube
minikube -p todo-chatbot stop

# Delete cluster
minikube -p todo-chatbot delete
```

## Next Steps (Post-Deadline)

1. **Fix Registration Issue**
   - Debug frontend API calls in browser
   - Verify environment variable injection
   - Test with direct curl to backend

2. **Complete Phase 5 Verification**
   - Test all CRUD operations
   - Test AI chatbot functionality
   - Verify data persistence across pod restarts
   - Test scaling (multiple replicas)

3. **Phase 6: Operations & Documentation**
   - Create automation scripts
   - Add monitoring/logging
   - Performance optimization
   - Security hardening

## Resources

- **Helm Charts**: `k8s/helm/`
- **Secrets**: `k8s/secrets/`
- **Specs**: `specs/001-kubernetes-deployment/`
- **Backend Code**: `backend/`
- **Frontend Code**: `frontend/`

## Support

For issues or questions:
1. Check pod logs: `kubectl logs -n todo-app <pod-name>`
2. Check pod status: `kubectl describe pod -n todo-app <pod-name>`
3. Review this quickstart guide
4. Check `specs/001-kubernetes-deployment/tasks.md` for detailed task list
