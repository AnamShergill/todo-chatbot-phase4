# Kubernetes Deployment

This directory contains all Kubernetes deployment configurations for the Todo Chatbot application.

## Quick Start

```powershell
# 1. Start Minikube
minikube -p todo-chatbot start

# 2. Access Frontend
kubectl port-forward -n todo-app pod/todo-frontend-7cbfb79fd8-h2pp6 3000:3000

# 3. Open Browser
http://localhost:3000
```

## Directory Structure

```
k8s/
├── helm/                    # Helm charts
│   ├── todo-postgres/      # PostgreSQL database
│   ├── todo-backend/       # FastAPI backend
│   └── todo-frontend/      # Next.js frontend
├── secrets/                # Kubernetes secrets
│   ├── postgres-secret.yaml
│   └── backend-secret.yaml
├── QUICKSTART.md           # Quick access guide
├── DEPLOYMENT_COMPLETE.md  # Detailed completion report
└── README.md              # This file
```

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick access and troubleshooting
- **[DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md)** - Full deployment details
- **[../FINAL_DEPLOYMENT_REPORT.md](../FINAL_DEPLOYMENT_REPORT.md)** - Executive summary

## Status

✅ **DEPLOYED** - All components running
⚠️ **Known Issue** - User registration returns 404 (post-deadline fix)

## Support

```powershell
# Check status
kubectl get pods,svc -n todo-app

# View logs
kubectl logs -n todo-app -l app=<component>

# Restart cluster
minikube -p todo-chatbot start
```

For detailed troubleshooting, see [QUICKSTART.md](QUICKSTART.md).
