# Quickstart Guide: Todo Chatbot Kubernetes Deployment

**Feature**: 001-kubernetes-deployment | **Date**: 2026-02-07
**Audience**: Developers deploying the Todo Chatbot to local Kubernetes

## Prerequisites

Before starting, ensure you have:

- ✅ Docker Desktop installed and running
- ✅ Minikube installed (latest version)
- ✅ kubectl CLI installed (latest version)
- ✅ Helm 3.x installed
- ✅ Minimum 4 CPUs and 8GB RAM available for Minikube
- ✅ 20GB free disk space for images and volumes
- ✅ Container images built: `todo-frontend:local` and `todo-backend:local`

## Quick Start (5 Steps)

### Step 1: Verify Container Images

```bash
# Check that Docker images exist
docker images | grep todo

# Expected output:
# todo-frontend    local    <image-id>    <time>    <size>
# todo-backend     local    <image-id>    <time>    <size>
```

If images don't exist, build them first:
```bash
# From repository root
cd frontend && docker build -t todo-frontend:local .
cd ../backend && docker build -t todo-backend:local .
```

### Step 2: Start Minikube Cluster

```bash
# Run the setup script
chmod +x specs/001-kubernetes-deployment/contracts/minikube-setup.sh
./specs/001-kubernetes-deployment/contracts/minikube-setup.sh

# Or manually:
minikube start --profile=todo-chatbot --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress --profile=todo-chatbot
minikube addons enable metrics-server --profile=todo-chatbot
```

**Important**: Use Minikube's Docker daemon for local images:
```bash
# Linux/Mac
eval $(minikube docker-env --profile=todo-chatbot)

# Windows PowerShell
& minikube -p todo-chatbot docker-env --shell powershell | Invoke-Expression
```

### Step 3: Deploy with Helm Charts

```bash
# Create namespace
kubectl create namespace todo-chatbot

# Deploy PostgreSQL (with init script)
helm install todo-postgres k8s/helm/todo-postgres \
  --namespace todo-chatbot \
  --set postgres.credentials.password=$(openssl rand -base64 32)

# Wait for PostgreSQL to be ready
kubectl wait --for=condition=Ready pod -l app=todo-postgres -n todo-chatbot --timeout=300s

# Deploy Backend
helm install todo-backend k8s/helm/todo-backend \
  --namespace todo-chatbot \
  --set backend.config.jwtSecret=$(openssl rand -base64 32) \
  --set backend.config.openaiApiKey="your-openai-api-key-here"

# Wait for Backend to be ready
kubectl wait --for=condition=Ready pod -l app=todo-backend -n todo-chatbot --timeout=300s

# Deploy Frontend
helm install todo-frontend k8s/helm/todo-frontend \
  --namespace todo-chatbot

# Wait for Frontend to be ready
kubectl wait --for=condition=Ready pod -l app=todo-frontend -n todo-chatbot --timeout=300s
```

### Step 4: Start Minikube Tunnel

**In a separate terminal**, run:
```bash
minikube tunnel --profile=todo-chatbot
```

This exposes LoadBalancer services on localhost. Keep this terminal open.

### Step 5: Access the Application

```bash
# Get the frontend service URL
kubectl get svc todo-frontend -n todo-chatbot

# Expected output:
# NAME            TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
# todo-frontend   LoadBalancer   10.96.xxx.xxx   127.0.0.1     80:xxxxx/TCP   1m

# Open in browser
open http://127.0.0.1  # Mac
# or
start http://127.0.0.1  # Windows
# or
xdg-open http://127.0.0.1  # Linux
```

## Verification Checklist

After deployment, verify everything is working:

```bash
# Check all pods are running
kubectl get pods -n todo-chatbot

# Expected output (all Running):
# NAME                             READY   STATUS    RESTARTS   AGE
# todo-postgres-0                  1/1     Running   0          5m
# todo-backend-xxxxxxxxxx-xxxxx    1/1     Running   0          4m
# todo-frontend-xxxxxxxxxx-xxxxx   1/1     Running   0          3m

# Check all services
kubectl get svc -n todo-chatbot

# Check health endpoints
kubectl exec -it deployment/todo-backend -n todo-chatbot -- curl http://localhost:8000/health
# Expected: {"status":"ok"}

# Check logs for errors
kubectl logs -l app=todo-backend -n todo-chatbot --tail=50
kubectl logs -l app=todo-frontend -n todo-chatbot --tail=50
kubectl logs -l app=todo-postgres -n todo-chatbot --tail=50
```

## Using kubectl-ai (Optional)

If kubectl-ai is installed, you can use AI-assisted operations:

```bash
# Generate Helm chart (if not already created)
kubectl-ai "generate Helm chart for FastAPI backend with health probe on port 8000"

# Scale deployment
kubectl-ai "scale todo-backend to 2 replicas in namespace todo-chatbot"

# Troubleshoot
kubectl-ai "why are todo-backend pods crashing in namespace todo-chatbot"
```

## Using Kagent (Optional)

If Kagent is installed, analyze cluster health:

```bash
# Analyze cluster health
kagent "analyze cluster health and resource utilization"

# Diagnose pod issues
kagent "diagnose why backend pods are in CrashLoopBackOff"

# Get optimization recommendations
kagent "recommend resource optimizations for todo-chatbot namespace"
```

## Common Operations

### View Application Logs

```bash
# Backend logs (real-time)
kubectl logs -f deployment/todo-backend -n todo-chatbot

# Frontend logs (real-time)
kubectl logs -f deployment/todo-frontend -n todo-chatbot

# PostgreSQL logs (real-time)
kubectl logs -f statefulset/todo-postgres -n todo-chatbot
```

### Scale Deployments

```bash
# Scale backend to 2 replicas
kubectl scale deployment todo-backend --replicas=2 -n todo-chatbot

# Scale frontend to 2 replicas
kubectl scale deployment todo-frontend --replicas=2 -n todo-chatbot

# Verify scaling
kubectl get pods -n todo-chatbot
```

### Update Configuration

```bash
# Update backend environment variable
kubectl set env deployment/todo-backend LOG_LEVEL=debug -n todo-chatbot

# Update via Helm (recommended)
helm upgrade todo-backend k8s/helm/todo-backend \
  --namespace todo-chatbot \
  --set backend.config.logLevel=debug
```

### Restart Deployments

```bash
# Restart backend (rolling restart)
kubectl rollout restart deployment/todo-backend -n todo-chatbot

# Restart frontend
kubectl rollout restart deployment/todo-frontend -n todo-chatbot

# Check rollout status
kubectl rollout status deployment/todo-backend -n todo-chatbot
```

### Access Database

```bash
# Port-forward to PostgreSQL
kubectl port-forward svc/todo-postgres 5432:5432 -n todo-chatbot

# In another terminal, connect with psql
psql -h localhost -U postgres -d todo_chatbot
# Password: (from Secret)

# Or exec into pod
kubectl exec -it todo-postgres-0 -n todo-chatbot -- psql -U postgres -d todo_chatbot
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n todo-chatbot

# Check events
kubectl get events -n todo-chatbot --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n todo-chatbot
kubectl top nodes
```

### Image Pull Errors

```bash
# Verify you're using Minikube's Docker daemon
eval $(minikube docker-env --profile=todo-chatbot)

# Rebuild images in Minikube's Docker
docker build -t todo-frontend:local ./frontend
docker build -t todo-backend:local ./backend

# Verify images exist in Minikube
docker images | grep todo
```

### Database Connection Issues

```bash
# Check PostgreSQL is running
kubectl get pods -l app=todo-postgres -n todo-chatbot

# Check PostgreSQL logs
kubectl logs todo-postgres-0 -n todo-chatbot

# Verify Secret exists
kubectl get secret todo-postgres-secret -n todo-chatbot

# Test connection from backend pod
kubectl exec -it deployment/todo-backend -n todo-chatbot -- \
  curl -v telnet://todo-postgres:5432
```

### LoadBalancer Not Accessible

```bash
# Ensure minikube tunnel is running
minikube tunnel --profile=todo-chatbot

# Check service status
kubectl get svc todo-frontend -n todo-chatbot

# If EXTERNAL-IP is pending, tunnel may not be running
# Start tunnel in separate terminal
```

### Health Probes Failing

```bash
# Check health endpoint manually
kubectl exec -it deployment/todo-backend -n todo-chatbot -- \
  curl http://localhost:8000/health

# Check probe configuration
kubectl describe pod <pod-name> -n todo-chatbot | grep -A 10 "Liveness\|Readiness"

# Increase initial delay if needed
helm upgrade todo-backend k8s/helm/todo-backend \
  --namespace todo-chatbot \
  --set backend.healthProbes.liveness.initialDelaySeconds=60
```

## Cleanup

### Remove Deployment (Keep Cluster)

```bash
# Uninstall Helm releases
helm uninstall todo-frontend -n todo-chatbot
helm uninstall todo-backend -n todo-chatbot
helm uninstall todo-postgres -n todo-chatbot

# Delete namespace (removes all resources)
kubectl delete namespace todo-chatbot
```

### Stop Minikube Cluster

```bash
# Stop cluster (preserves state)
minikube stop --profile=todo-chatbot

# Start again later
minikube start --profile=todo-chatbot
```

### Complete Cleanup

```bash
# Delete cluster entirely
minikube delete --profile=todo-chatbot

# This removes:
# - All pods, services, deployments
# - All persistent volumes
# - All configuration
# - The entire cluster
```

## Performance Tips

1. **Resource Allocation**: Adjust CPU/memory limits in values.yaml if needed
2. **Replica Count**: Start with 1 replica, scale up if needed
3. **Image Optimization**: Ensure Docker images are optimized (<200MB frontend, <300MB backend)
4. **Database Tuning**: Adjust PostgreSQL shared_buffers if needed
5. **Health Probes**: Tune probe timing based on actual startup times

## Security Notes

- **Secrets**: Never commit Secrets to version control
- **Passwords**: Use strong generated passwords (openssl rand -base64 32)
- **API Keys**: Store OpenAI API key in Secret, not ConfigMap
- **Non-root**: All containers run as non-root users
- **Resource Limits**: Prevent resource exhaustion attacks

## Next Steps

After successful deployment:

1. ✅ Test user registration and login
2. ✅ Create tasks via web UI
3. ✅ Test AI chatbot task management
4. ✅ Verify data persistence (restart pods)
5. ✅ Test scaling (increase replicas)
6. ✅ Monitor resource usage
7. ✅ Review logs for errors

## Additional Resources

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Helm Documentation**: https://helm.sh/docs/
- **Minikube Documentation**: https://minikube.sigs.k8s.io/docs/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Project Spec**: `specs/001-kubernetes-deployment/spec.md`
- **Implementation Plan**: `specs/001-kubernetes-deployment/plan.md`
- **Research**: `specs/001-kubernetes-deployment/research.md`
