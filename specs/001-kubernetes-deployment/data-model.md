# Data Model: Phase IV - Kubernetes Deployment

**Feature**: 001-kubernetes-deployment | **Date**: 2026-02-07
**Input**: Specification requirements and research decisions

## Overview

This document defines the Kubernetes resource model and configuration structure for deploying the AI Todo Chatbot. Unlike traditional application data models, this focuses on infrastructure entities and their relationships in the Kubernetes environment.

## Kubernetes Resource Model

### 1. Namespace

**Entity**: Kubernetes Namespace
**Purpose**: Logical isolation for all Todo Chatbot resources

**Attributes**:
- name: `todo-chatbot` (default) or configurable via Helm values
- labels:
  - app: todo-chatbot
  - environment: local

**Relationships**:
- Contains: All Deployments, StatefulSets, Services, ConfigMaps, Secrets, PVCs

**Validation Rules**:
- Name must be DNS-compliant (lowercase, alphanumeric, hyphens)
- Must exist before deploying any resources

**State Transitions**:
- Created → Active → Terminating → Deleted

---

### 2. PostgreSQL StatefulSet

**Entity**: Kubernetes StatefulSet for PostgreSQL database
**Purpose**: Manage PostgreSQL pod with stable network identity and persistent storage

**Attributes**:
- name: `todo-postgres`
- replicas: 1 (single instance for local development)
- serviceName: `todo-postgres-headless`
- podManagementPolicy: OrderedReady
- updateStrategy: RollingUpdate

**Container Spec**:
- image: bitnami/postgresql:latest
- ports: 5432
- resources:
  - requests: 500m CPU, 1Gi RAM
  - limits: 1000m CPU, 2Gi RAM
- securityContext:
  - runAsNonRoot: true
  - runAsUser: 1001
- env (from Secret):
  - POSTGRES_PASSWORD
  - POSTGRES_USER
  - POSTGRES_DB

**Volume Mounts**:
- /bitnami/postgresql (data directory) → PVC
- /docker-entrypoint-initdb.d (init scripts) → ConfigMap

**Health Probes**:
- livenessProbe: exec pg_isready
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5
- readinessProbe: exec pg_isready
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5

**Relationships**:
- Uses: PersistentVolumeClaim (todo-postgres-data)
- Uses: Secret (todo-postgres-secret)
- Uses: ConfigMap (todo-postgres-init)
- Exposes: Service (todo-postgres)

**Validation Rules**:
- Must have PVC bound before pod starts
- Must have Secret with database credentials
- Init ConfigMap must contain valid SQL

**State Transitions**:
- Pending → Running → Terminating → Terminated

---

### 3. Backend Deployment

**Entity**: Kubernetes Deployment for FastAPI backend
**Purpose**: Manage backend application pods with MCP server and AI agents

**Attributes**:
- name: `todo-backend`
- replicas: 1-2 (configurable)
- strategy: RollingUpdate
  - maxSurge: 1
  - maxUnavailable: 0

**Container Spec**:
- image: todo-backend:local
- imagePullPolicy: Never (local image)
- ports: 8000
- resources:
  - requests: 500m CPU, 1Gi RAM
  - limits: 1000m CPU, 2Gi RAM
- securityContext:
  - runAsNonRoot: true
  - runAsUser: 1000
- env (from ConfigMap and Secret):
  - DATABASE_URL (from Secret)
  - JWT_SECRET (from Secret)
  - OPENAI_API_KEY (from Secret)
  - FRONTEND_URL (from ConfigMap)

**Health Probes**:
- livenessProbe: httpGet /health
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5
- readinessProbe: httpGet /health
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5

**Relationships**:
- Uses: ConfigMap (todo-backend-config)
- Uses: Secret (todo-backend-secret)
- Depends on: PostgreSQL StatefulSet (database connectivity)
- Exposes: Service (todo-backend)

**Validation Rules**:
- Must have valid database connection string
- Must have JWT secret configured
- Health endpoint must return 200 OK

**State Transitions**:
- Pending → Running → Terminating → Terminated

---

### 4. Frontend Deployment

**Entity**: Kubernetes Deployment for Next.js frontend
**Purpose**: Manage frontend application pods serving web UI

**Attributes**:
- name: `todo-frontend`
- replicas: 1-2 (configurable)
- strategy: RollingUpdate
  - maxSurge: 1
  - maxUnavailable: 0

**Container Spec**:
- image: todo-frontend:local
- imagePullPolicy: Never (local image)
- ports: 3000
- resources:
  - requests: 250m CPU, 512Mi RAM
  - limits: 500m CPU, 1Gi RAM
- securityContext:
  - runAsNonRoot: true
  - runAsUser: 1000
- env (from ConfigMap):
  - NEXT_PUBLIC_API_URL (backend service URL)
  - NEXT_PUBLIC_CHATKIT_ENABLED

**Health Probes**:
- livenessProbe: httpGet /
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5
- readinessProbe: httpGet /
  - initialDelaySeconds: 30
  - periodSeconds: 10
  - failureThreshold: 3
  - timeoutSeconds: 5

**Relationships**:
- Uses: ConfigMap (todo-frontend-config)
- Depends on: Backend Deployment (API connectivity)
- Exposes: Service (todo-frontend, LoadBalancer)

**Validation Rules**:
- Must have valid backend API URL
- Health endpoint must return 200 OK

**State Transitions**:
- Pending → Running → Terminating → Terminated

---

### 5. PersistentVolumeClaim

**Entity**: Kubernetes PersistentVolumeClaim for PostgreSQL data
**Purpose**: Request persistent storage for database data

**Attributes**:
- name: `todo-postgres-data`
- storageClassName: standard (Minikube default)
- accessModes: ReadWriteOnce
- storage: 5Gi

**Relationships**:
- Bound to: PersistentVolume (auto-provisioned by Minikube)
- Used by: PostgreSQL StatefulSet

**Validation Rules**:
- Must be bound before StatefulSet pod starts
- Storage size must be sufficient for database data

**State Transitions**:
- Pending → Bound → Released → Deleted

---

### 6. Services

#### PostgreSQL Service (ClusterIP)

**Entity**: Kubernetes Service for database access
**Purpose**: Provide stable endpoint for backend to connect to database

**Attributes**:
- name: `todo-postgres`
- type: ClusterIP
- ports: 5432 → 5432
- selector: app=todo-postgres

**Relationships**:
- Routes to: PostgreSQL StatefulSet pods

---

#### Backend Service (ClusterIP)

**Entity**: Kubernetes Service for backend API
**Purpose**: Provide stable endpoint for frontend to connect to backend

**Attributes**:
- name: `todo-backend`
- type: ClusterIP
- ports: 8000 → 8000
- selector: app=todo-backend

**Relationships**:
- Routes to: Backend Deployment pods

---

#### Frontend Service (LoadBalancer)

**Entity**: Kubernetes Service for frontend web UI
**Purpose**: Expose frontend to host machine via LoadBalancer

**Attributes**:
- name: `todo-frontend`
- type: LoadBalancer
- ports: 80 → 3000
- selector: app=todo-frontend

**Relationships**:
- Routes to: Frontend Deployment pods
- Exposed via: Minikube tunnel

**Validation Rules**:
- LoadBalancer IP assigned by minikube tunnel
- Accessible from host machine browser

---

### 7. ConfigMaps

#### PostgreSQL Init ConfigMap

**Entity**: Kubernetes ConfigMap with database initialization SQL
**Purpose**: Provide schema initialization script for PostgreSQL

**Attributes**:
- name: `todo-postgres-init`
- data:
  - init.sql: SQL script with CREATE TABLE statements

**Content Structure**:
```sql
-- Users table
CREATE TABLE IF NOT EXISTS users (...);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (...);

-- Conversations table
CREATE TABLE IF NOT EXISTS conversations (...);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (...);
```

**Relationships**:
- Used by: PostgreSQL StatefulSet (mounted as init script)

---

#### Backend ConfigMap

**Entity**: Kubernetes ConfigMap with backend configuration
**Purpose**: Provide non-sensitive configuration for backend

**Attributes**:
- name: `todo-backend-config`
- data:
  - FRONTEND_URL: http://todo-frontend
  - LOG_LEVEL: info
  - CORS_ORIGINS: http://localhost

**Relationships**:
- Used by: Backend Deployment

---

#### Frontend ConfigMap

**Entity**: Kubernetes ConfigMap with frontend configuration
**Purpose**: Provide non-sensitive configuration for frontend

**Attributes**:
- name: `todo-frontend-config`
- data:
  - NEXT_PUBLIC_API_URL: http://todo-backend:8000
  - NEXT_PUBLIC_CHATKIT_ENABLED: true

**Relationships**:
- Used by: Frontend Deployment

---

### 8. Secrets

#### PostgreSQL Secret

**Entity**: Kubernetes Secret with database credentials
**Purpose**: Securely store database authentication information

**Attributes**:
- name: `todo-postgres-secret`
- type: Opaque
- data (base64 encoded):
  - POSTGRES_USER: postgres
  - POSTGRES_PASSWORD: <generated>
  - POSTGRES_DB: todo_chatbot

**Relationships**:
- Used by: PostgreSQL StatefulSet
- Used by: Backend Deployment (for DATABASE_URL)

**Validation Rules**:
- Password must be strong (generated or provided)
- Must exist before StatefulSet starts

---

#### Backend Secret

**Entity**: Kubernetes Secret with backend sensitive configuration
**Purpose**: Securely store JWT secret and API keys

**Attributes**:
- name: `todo-backend-secret`
- type: Opaque
- data (base64 encoded):
  - JWT_SECRET: <generated>
  - OPENAI_API_KEY: <provided or placeholder>
  - DATABASE_URL: postgresql://user:pass@todo-postgres:5432/todo_chatbot

**Relationships**:
- Used by: Backend Deployment

**Validation Rules**:
- JWT_SECRET must be strong random string
- DATABASE_URL must reference PostgreSQL service

---

## Resource Dependencies

```
Namespace
  └─ PostgreSQL StatefulSet
      ├─ PersistentVolumeClaim (todo-postgres-data)
      ├─ Secret (todo-postgres-secret)
      ├─ ConfigMap (todo-postgres-init)
      └─ Service (todo-postgres, ClusterIP)

  └─ Backend Deployment
      ├─ ConfigMap (todo-backend-config)
      ├─ Secret (todo-backend-secret)
      ├─ Service (todo-backend, ClusterIP)
      └─ Depends on: PostgreSQL Service

  └─ Frontend Deployment
      ├─ ConfigMap (todo-frontend-config)
      ├─ Service (todo-frontend, LoadBalancer)
      └─ Depends on: Backend Service
```

## Deployment Order

1. **Namespace** - Create namespace first
2. **Secrets** - Create all secrets (postgres, backend)
3. **ConfigMaps** - Create all config maps (postgres-init, backend-config, frontend-config)
4. **PersistentVolumeClaim** - Create PVC for PostgreSQL
5. **PostgreSQL StatefulSet** - Deploy database (wait for Ready)
6. **PostgreSQL Service** - Expose database internally
7. **Backend Deployment** - Deploy backend (wait for Ready)
8. **Backend Service** - Expose backend internally
9. **Frontend Deployment** - Deploy frontend (wait for Ready)
10. **Frontend Service** - Expose frontend externally

## Helm Values Structure

All resources are parameterized via Helm values.yaml:

```yaml
global:
  namespace: todo-chatbot

postgres:
  enabled: true
  replicas: 1
  image: bitnami/postgresql:latest
  storage: 5Gi
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
  credentials:
    user: postgres
    password: <generated>
    database: todo_chatbot

backend:
  enabled: true
  replicas: 1
  image: todo-backend:local
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1000m
      memory: 2Gi
  config:
    jwtSecret: <generated>
    openaiApiKey: <provided>

frontend:
  enabled: true
  replicas: 1
  image: todo-frontend:local
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi
  service:
    type: LoadBalancer
    port: 80

healthProbes:
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3
  timeoutSeconds: 5
```

## Validation and Testing

### Resource Validation

- All pods reach Running status
- All services have endpoints
- PVC is bound to PV
- Secrets are created and mounted
- ConfigMaps are created and mounted

### Connectivity Testing

- Backend can connect to PostgreSQL
- Frontend can connect to Backend
- Host machine can access Frontend via LoadBalancer

### Health Check Testing

- All liveness probes succeed
- All readiness probes succeed
- Health endpoints return 200 OK

### Data Persistence Testing

- Data survives PostgreSQL pod restart
- PVC retains data after pod deletion
- Schema initialization runs on first start only
