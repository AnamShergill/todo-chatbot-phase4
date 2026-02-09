# Troubleshooting Guide

## Common Issues and Solutions

### 1. Cluster Not Responding

**Symptom**: `kubectl` commands fail with connection errors

**Solution**:
```powershell
# Check cluster status
minikube -p todo-chatbot status

# If stopped, start it
minikube -p todo-chatbot start

# Verify context
kubectl config current-context
# Should show: todo-chatbot
```

### 2. Pod Not Starting

**Symptom**: Pod stuck in Pending or CrashLoopBackOff

**Solution**:
```powershell
# Check pod status
kubectl get pods -n todo-app

# Describe pod for details
kubectl describe pod <pod-name> -n todo-app

# Check logs
kubectl logs <pod-name> -n todo-app

# Common fixes:
# - Insufficient resources: Reduce resource limits in values.yaml
# - Image pull error: Verify image exists with `docker images`
# - Config error: Check ConfigMap and Secret values
```

### 3. Frontend UI Not Loading

**Symptom**: Browser shows connection refused or timeout

**Solution**:
```powershell
# Verify pod is running
kubectl get pods -n todo-app -l app=todo-frontend

# Check pod logs
kubectl logs -n todo-app -l app=todo-frontend --tail=50

# Verify port-forward is running
# Should see "Forwarding from 127.0.0.1:3000"

# Try alternative access
minikube -p todo-chatbot service todo-frontend -n todo-app --url
```

### 4. Database Connection Failed

**Symptom**: Backend logs show database connection errors

**Solution**:
```powershell
# Check postgres pod
kubectl get pods -n todo-app -l app=todo-postgres

# Check postgres logs
kubectl logs -n todo-app todo-postgres-0

# Verify secret exists
kubectl get secret todo-postgres-secret -n todo-app

# Test connection from backend pod
kubectl exec -n todo-app deployment/todo-backend -- env | grep DATABASE_URL
```

### 5. User Registration 404 Error

**Symptom**: POST to `/auth/register` returns 404

**Status**: Known issue - under investigation

**Temporary Workaround**: None currently

**Investigation Steps**:
1. Check browser Network tab for actual request URL
2. Verify backend logs: `kubectl logs -n todo-app -l app=todo-backend`
3. Test backend directly: Port-forward and curl
4. Check frontend environment variables in pod

### 6. Minikube Out of Resources

**Symptom**: Pods stuck in Pending, events show insufficient resources

**Solution**:
```powershell
# Check resource usage
kubectl top nodes
kubectl top pods -n todo-app

# Reduce resource limits in values.yaml files
# Then redeploy:
helm upgrade todo-frontend k8s/helm/todo-frontend -n todo-app
```

### 7. PVC Not Binding

**Symptom**: PersistentVolumeClaim stuck in Pending

**Solution**:
```powershell
# Check PVC status
kubectl get pvc -n todo-app

# Describe for details
kubectl describe pvc <pvc-name> -n todo-app

# Check storage class
kubectl get storageclass

# If using Minikube, ensure storage provisioner is enabled
minikube addons enable storage-provisioner -p todo-chatbot
```

### 8. Helm Release Failed

**Symptom**: `helm install` or `helm upgrade` fails

**Solution**:
```powershell
# Check Helm release status
helm list -n todo-app

# Get release history
helm history <release-name> -n todo-app

# Rollback if needed
helm rollback <release-name> -n todo-app

# Or uninstall and reinstall
helm uninstall <release-name> -n todo-app
helm install <release-name> k8s/helm/<chart> -n todo-app
```

## Diagnostic Commands

```powershell
# Full cluster status
kubectl get all -n todo-app

# Check events
kubectl get events -n todo-app --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n todo-app

# Check logs for all pods
kubectl logs -n todo-app -l app=todo-frontend --tail=50
kubectl logs -n todo-app -l app=todo-backend --tail=50
kubectl logs -n todo-app todo-postgres-0 --tail=50

# Verify secrets and configmaps
kubectl get secrets,configmaps -n todo-app

# Check endpoints
kubectl get endpoints -n todo-app
```

## Emergency Recovery

### Complete Reset
```powershell
# 1. Delete everything
helm uninstall todo-frontend todo-backend todo-postgres -n todo-app
kubectl delete namespace todo-app

# 2. Restart cluster
minikube -p todo-chatbot stop
minikube -p todo-chatbot start

# 3. Redeploy
.\k8s\scripts\deploy-all.ps1
```

### Cluster Won't Start
```powershell
# Delete and recreate
minikube -p todo-chatbot delete
minikube -p todo-chatbot start --cpus=4 --memory=8192
```

## Getting Help

1. Check pod logs first
2. Review this troubleshooting guide
3. Check QUICKSTART.md for access instructions
4. Review DEPLOYMENT_COMPLETE.md for configuration details
