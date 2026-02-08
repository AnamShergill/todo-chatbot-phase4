---
description: "Task list for Phase IV - Full Local Kubernetes Deployment"
---

# Tasks: Phase IV - Full Local Kubernetes Deployment

**Input**: Design documents from `/specs/001-kubernetes-deployment/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by phase and user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US0, US1, US2)
- Include exact file paths and commands in descriptions

## Path Conventions

- **Kubernetes infrastructure**: `k8s/helm/`, `k8s/scripts/`
- **Existing application**: `backend/`, `frontend/`
- Paths shown below assume web app structure based on plan.md

---

## Phase 0: Containerization Verification (US0 - BLOCKING) 🚨

**Purpose**: Verify Docker images exist and work before Kubernetes deployment

**⚠️ CRITICAL**: No subsequent phases can begin until this phase is complete

- [ ] T001 [US0] Verify Docker is running and accessible
  - **Command**: `docker info`
  - **Test**: Should show Docker version and running status

- [ ] T002 [US0] Check if todo-frontend:local image exists
  - **Command**: `docker images | grep todo-frontend`
  - **Test**: Should show image with 'local' tag

- [ ] T003 [US0] Check if todo-backend:local image exists
  - **Command**: `docker images | grep todo-backend`
  - **Test**: Should show image with 'local' tag

- [ ] T004 [US0] If images missing, build frontend Docker image
  - **Command**: `cd frontend && docker build -t todo-frontend:local .`
  - **Test**: `docker images todo-frontend:local` shows image

- [ ] T005 [US0] If images missing, build backend Docker image
  - **Command**: `cd backend && docker build -t todo-backend:local .`
  - **Test**: `docker images todo-backend:local` shows image

- [ ] T006 [US0] Test frontend container standalone
  - **Command**: `docker run -d -p 3000:3000 --name test-frontend todo-frontend:local`
  - **Test**: `curl http://localhost:3000` returns 200 OK
  - **Cleanup**: `docker stop test-frontend && docker rm test-frontend`

- [ ] T007 [US0] Test backend container standalone
  - **Command**: `docker run -d -p 8000:8000 --name test-backend todo-backend:local`
  - **Test**: `curl http://localhost:8000/health` returns {"status":"ok"}
  - **Cleanup**: `docker stop test-backend && docker rm test-backend`

**Checkpoint**: At this point, both Docker images are verified and working standalone

---

## Phase 1: Minikube Setup (Foundational - BLOCKS all deployments)

**Purpose**: Initialize Kubernetes cluster with proper configuration

**⚠️ CRITICAL**: All deployment phases depend on this

- [ ] T008 [P] Verify Minikube is installed
  - **Command**: `minikube version`
  - **Test**: Should show version >= 1.30

- [ ] T009 [P] Verify kubectl is installed
  - **Command**: `kubectl version --client`
  - **Test**: Should show client version

- [ ] T010 [P] Verify Helm is installed
  - **Command**: `helm version`
  - **Test**: Should show version >= 3.0

- [ ] T011 Start Minikube cluster with proper resources
  - **Command**: `minikube start --profile=todo-chatbot --cpus=4 --memory=8192 --driver=docker`
  - **Test**: `minikube status --profile=todo-chatbot` shows "Running"

- [ ] T012 Enable ingress addon
  - **Command**: `minikube addons enable ingress --profile=todo-chatbot`
  - **Test**: `minikube addons list --profile=todo-chatbot | grep ingress` shows "enabled"

- [ ] T013 Enable metrics-server addon
  - **Command**: `minikube addons enable metrics-server --profile=todo-chatbot`
  - **Test**: `minikube addons list --profile=todo-chatbot | grep metrics-server` shows "enabled"

- [ ] T014 Wait for cluster to be ready
  - **Command**: `kubectl wait --for=condition=Ready nodes --all --timeout=300s`
  - **Test**: All nodes show "Ready" status

- [ ] T015 Set kubectl context to todo-chatbot
  - **Command**: `kubectl config use-context todo-chatbot`
  - **Test**: `kubectl config current-context` shows "todo-chatbot"

- [ ] T016 Configure Docker to use Minikube's daemon
  - **Command**: `eval $(minikube docker-env --profile=todo-chatbot)` (Linux/Mac) or `& minikube -p todo-chatbot docker-env --shell powershell | Invoke-Expression` (Windows)
  - **Test**: `docker images` shows Minikube's images

- [ ] T017 Rebuild images in Minikube's Docker daemon
  - **Command**: `cd frontend && docker build -t todo-frontend:local . && cd ../backend && docker build -t todo-backend:local .`
  - **Test**: `docker images | grep todo` shows both images

- [ ] T018 Create todo-chatbot namespace
  - **Command**: `kubectl create namespace todo-chatbot`
  - **Test**: `kubectl get namespace todo-chatbot` shows "Active"

**Checkpoint**: Minikube cluster is ready, images are available in cluster

---

## Phase 2: Database Deployment (US2)

**Purpose**: Deploy PostgreSQL with persistent storage and schema initialization

- [ ] T019 [US2] Create k8s/helm/todo-postgres directory structure
  - **Command**: `mkdir -p k8s/helm/todo-postgres/templates`
  - **Test**: Directory exists

- [ ] T020 [US2] Generate PostgreSQL Helm chart using kubectl-ai
  - **Command**: `kubectl-ai "generate Helm chart for PostgreSQL StatefulSet with 5Gi PVC, initdb ConfigMap, and Secret for credentials"`
  - **Fallback**: Copy bitnami/postgresql chart structure or create manually
  - **Test**: Chart.yaml, values.yaml, templates/ exist

- [ ] T021 [US2] Create postgres init SQL ConfigMap from contract
  - **Command**: `kubectl create configmap todo-postgres-init --from-file=init.sql=specs/001-kubernetes-deployment/contracts/postgres-init-schema.sql -n todo-chatbot`
  - **Test**: `kubectl get configmap todo-postgres-init -n todo-chatbot` exists

- [ ] T022 [US2] Generate strong database password
  - **Command**: `openssl rand -base64 32`
  - **Test**: Save password for next step

- [ ] T023 [US2] Create postgres Secret with credentials
  - **Command**: `kubectl create secret generic todo-postgres-secret --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=<generated> --from-literal=POSTGRES_DB=todo_chatbot -n todo-chatbot`
  - **Test**: `kubectl get secret todo-postgres-secret -n todo-chatbot` exists

- [ ] T024 [US2] Update postgres Helm values with resource limits
  - **File**: `k8s/helm/todo-postgres/values.yaml`
  - **Values**: requests (500m CPU, 1Gi RAM), limits (1000m CPU, 2Gi RAM), storage 5Gi
  - **Test**: Values file contains correct resource specifications

- [ ] T025 [US2] Deploy PostgreSQL via Helm
  - **Command**: `helm install todo-postgres k8s/helm/todo-postgres --namespace todo-chatbot`
  - **Test**: `helm list -n todo-chatbot` shows todo-postgres

- [ ] T026 [US2] Wait for PostgreSQL pod to be ready
  - **Command**: `kubectl wait --for=condition=Ready pod -l app=todo-postgres -n todo-chatbot --timeout=300s`
  - **Test**: `kubectl get pods -l app=todo-postgres -n todo-chatbot` shows "Running"

- [ ] T027 [US2] Verify PVC is bound
  - **Command**: `kubectl get pvc -n todo-chatbot`
  - **Test**: PVC shows "Bound" status with 5Gi

- [ ] T028 [US2] Verify database initialization completed
  - **Command**: `kubectl logs -l app=todo-postgres -n todo-chatbot | grep "Database schema initialized"`
  - **Test**: Logs show successful initialization

- [ ] T029 [US2] Test database connectivity from within cluster
  - **Command**: `kubectl run -it --rm psql-test --image=postgres:latest --restart=Never -n todo-chatbot -- psql -h todo-postgres -U postgres -d todo_chatbot -c "\dt"`
  - **Test**: Shows tables: users, tasks, conversations, messages

**Checkpoint**: PostgreSQL is running with initialized schema and persistent storage

---

## Phase 3: Backend Deployment (US1)

**Purpose**: Deploy FastAPI backend with MCP server and database connectivity

- [ ] T030 [US1] Create k8s/helm/todo-backend directory structure
  - **Command**: `mkdir -p k8s/helm/todo-backend/templates`
  - **Test**: Directory exists

- [ ] T031 [US1] Generate backend Helm chart using kubectl-ai
  - **Command**: `kubectl-ai "generate Helm chart for FastAPI backend Deployment with health probe on port 8000, ClusterIP service, ConfigMap and Secret"`
  - **Fallback**: Create manually following data-model.md specifications
  - **Test**: Chart.yaml, values.yaml, templates/ exist

- [ ] T032 [US1] Create backend ConfigMap with non-sensitive config
  - **Command**: `kubectl create configmap todo-backend-config --from-literal=FRONTEND_URL=http://todo-frontend --from-literal=LOG_LEVEL=info --from-literal=CORS_ORIGINS=http://localhost -n todo-chatbot`
  - **Test**: `kubectl get configmap todo-backend-config -n todo-chatbot` exists

- [ ] T033 [US1] Generate JWT secret
  - **Command**: `openssl rand -base64 32`
  - **Test**: Save secret for next step

- [ ] T034 [US1] Create backend Secret with sensitive config
  - **Command**: `kubectl create secret generic todo-backend-secret --from-literal=JWT_SECRET=<generated> --from-literal=OPENAI_API_KEY=<provided-or-placeholder> --from-literal=DATABASE_URL=postgresql://postgres:<password>@todo-postgres:5432/todo_chatbot -n todo-chatbot`
  - **Test**: `kubectl get secret todo-backend-secret -n todo-chatbot` exists

- [ ] T035 [US1] Update backend Helm values with resource limits and probes
  - **File**: `k8s/helm/todo-backend/values.yaml`
  - **Values**: requests (500m CPU, 1Gi RAM), limits (1000m CPU, 2Gi RAM), probes (30s delay, 10s period, 3 failures)
  - **Test**: Values file contains correct specifications

- [ ] T036 [US1] Deploy backend via Helm
  - **Command**: `helm install todo-backend k8s/helm/todo-backend --namespace todo-chatbot`
  - **Test**: `helm list -n todo-chatbot` shows todo-backend

- [ ] T037 [US1] Wait for backend pod to be ready
  - **Command**: `kubectl wait --for=condition=Ready pod -l app=todo-backend -n todo-chatbot --timeout=300s`
  - **Test**: `kubectl get pods -l app=todo-backend -n todo-chatbot` shows "Running"

- [ ] T038 [US1] Verify backend health endpoint
  - **Command**: `kubectl exec -it deployment/todo-backend -n todo-chatbot -- curl http://localhost:8000/health`
  - **Test**: Returns {"status":"ok"}

- [ ] T039 [US1] Verify backend can connect to database
  - **Command**: `kubectl logs -l app=todo-backend -n todo-chatbot | grep -i "database\|postgres"`
  - **Test**: Logs show successful database connection

**Checkpoint**: Backend is running and connected to database

---

## Phase 4: Frontend Deployment (US1)

**Purpose**: Deploy Next.js frontend with LoadBalancer service

- [ ] T040 [US1] Create k8s/helm/todo-frontend directory structure
  - **Command**: `mkdir -p k8s/helm/todo-frontend/templates`
  - **Test**: Directory exists

- [ ] T041 [US1] Generate frontend Helm chart using kubectl-ai
  - **Command**: `kubectl-ai "generate Helm chart for Next.js frontend Deployment with LoadBalancer service on port 80 to 3000, ConfigMap for API URL"`
  - **Fallback**: Create manually following data-model.md specifications
  - **Test**: Chart.yaml, values.yaml, templates/ exist

- [ ] T042 [US1] Create frontend ConfigMap with API URL
  - **Command**: `kubectl create configmap todo-frontend-config --from-literal=NEXT_PUBLIC_API_URL=http://todo-backend:8000 --from-literal=NEXT_PUBLIC_CHATKIT_ENABLED=true -n todo-chatbot`
  - **Test**: `kubectl get configmap todo-frontend-config -n todo-chatbot` exists

- [ ] T043 [US1] Update frontend Helm values with resource limits and probes
  - **File**: `k8s/helm/todo-frontend/values.yaml`
  - **Values**: requests (250m CPU, 512Mi RAM), limits (500m CPU, 1Gi RAM), service type LoadBalancer
  - **Test**: Values file contains correct specifications

- [ ] T044 [US1] Deploy frontend via Helm
  - **Command**: `helm install todo-frontend k8s/helm/todo-frontend --namespace todo-chatbot`
  - **Test**: `helm list -n todo-chatbot` shows todo-frontend

- [ ] T045 [US1] Wait for frontend pod to be ready
  - **Command**: `kubectl wait --for=condition=Ready pod -l app=todo-frontend -n todo-chatbot --timeout=300s`
  - **Test**: `kubectl get pods -l app=todo-frontend -n todo-chatbot` shows "Running"

- [ ] T046 [US1] Start minikube tunnel in background
  - **Command**: `minikube tunnel --profile=todo-chatbot &` (Linux/Mac) or start in separate terminal (Windows)
  - **Test**: Tunnel process is running

- [ ] T047 [US1] Wait for LoadBalancer IP assignment
  - **Command**: `kubectl get svc todo-frontend -n todo-chatbot -w` (wait for EXTERNAL-IP)
  - **Test**: EXTERNAL-IP shows 127.0.0.1 or similar

- [ ] T048 [US1] Verify frontend UI is accessible from host
  - **Command**: `curl http://127.0.0.1` or open in browser
  - **Test**: Returns HTML page with Next.js app

- [ ] T049 [US1] Verify frontend can reach backend API
  - **Command**: Check browser console or `kubectl logs -l app=todo-frontend -n todo-chatbot`
  - **Test**: No CORS errors, API calls succeed

**Checkpoint**: All three components (database, backend, frontend) are deployed and accessible

---

## Phase 5: Integration & Verification (US5)

**Purpose**: Test end-to-end functionality and data persistence

- [ ] T050 [US5] Verify all pods are running
  - **Command**: `kubectl get pods -n todo-chatbot`
  - **Test**: All pods show "Running" status with 1/1 Ready

- [ ] T051 [US5] Verify all services have endpoints
  - **Command**: `kubectl get svc -n todo-chatbot`
  - **Test**: All services show proper ports and IPs

- [ ] T052 [US5] Test user registration via web UI
  - **Action**: Open http://127.0.0.1 in browser, register new user
  - **Test**: Registration succeeds, user can log in

- [ ] T053 [US5] Test task creation via web UI
  - **Action**: Create a new task through UI
  - **Test**: Task appears in task list

- [ ] T054 [US5] Test AI chatbot task creation
  - **Action**: Use chatbot to create task via natural language
  - **Test**: Task is created and appears in database

- [ ] T055 [US5] Test data persistence by restarting PostgreSQL pod
  - **Command**: `kubectl delete pod -l app=todo-postgres -n todo-chatbot`
  - **Wait**: `kubectl wait --for=condition=Ready pod -l app=todo-postgres -n todo-chatbot --timeout=300s`
  - **Test**: Previously created tasks still exist after restart

- [ ] T056 [US5] Test backend scaling
  - **Command**: `kubectl scale deployment todo-backend --replicas=2 -n todo-chatbot`
  - **Test**: `kubectl get pods -l app=todo-backend -n todo-chatbot` shows 2 pods

- [ ] T057 [US5] Verify load balancing across backend replicas
  - **Command**: Multiple API calls, check logs from both pods
  - **Test**: Both backend pods receive requests

**Checkpoint**: End-to-end functionality verified, data persists, scaling works

---

## Phase 6: AI-Assisted Operations & Documentation (US3, US4)

**Purpose**: Use AI tools for optimization and create operational documentation

- [ ] T058 [US3] [US4] Use Kagent to analyze cluster health
  - **Command**: `kagent "analyze cluster health and resource utilization for todo-chatbot namespace"`
  - **Test**: Kagent provides insights on resource usage

- [ ] T059 [US3] [US4] Use Kagent to check for optimization opportunities
  - **Command**: `kagent "recommend resource optimizations for todo-chatbot deployments"`
  - **Test**: Kagent suggests improvements if any

- [ ] T060 [US3] Create deployment automation script
  - **File**: `k8s/scripts/deploy-all.sh`
  - **Content**: Script that deploys all components in order with waits
  - **Test**: Script runs successfully and deploys all components

- [ ] T061 [US3] Create verification script
  - **File**: `k8s/scripts/verify-deployment.sh`
  - **Content**: Script that checks pod status, health endpoints, connectivity
  - **Test**: Script runs and reports all checks passing

- [ ] T062 [US3] Create cleanup script
  - **File**: `k8s/scripts/cleanup.sh`
  - **Content**: Script that uninstalls Helm releases, deletes namespace, optionally stops Minikube
  - **Test**: Script runs and removes all resources

- [ ] T063 [US4] Document troubleshooting procedures
  - **File**: `k8s/TROUBLESHOOTING.md`
  - **Content**: Common issues and solutions based on testing
  - **Test**: Document covers pod failures, connectivity issues, resource problems

- [ ] T064 [US3] [US4] Create README for k8s directory
  - **File**: `k8s/README.md`
  - **Content**: Overview, prerequisites, deployment steps, references to quickstart.md
  - **Test**: README provides clear deployment instructions

**Checkpoint**: Operational tooling complete, documentation in place

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 0 (US0)**: No dependencies - MUST complete first (BLOCKING)
- **Phase 1**: Depends on Phase 0 completion - BLOCKS all deployments
- **Phase 2 (US2)**: Depends on Phase 1 completion
- **Phase 3 (US1)**: Depends on Phase 2 completion (needs database)
- **Phase 4 (US1)**: Depends on Phase 3 completion (needs backend API)
- **Phase 5 (US5)**: Depends on Phases 2, 3, 4 completion
- **Phase 6 (US3, US4)**: Depends on Phase 5 completion

### Parallel Opportunities

- **Phase 0**: T002 and T003 can run in parallel
- **Phase 1**: T008, T009, T010 can run in parallel (prerequisite checks)
- **Phase 2**: T019 and T022 can run in parallel
- **Phase 3**: T030 and T033 can run in parallel
- **Phase 4**: T040 can start while Phase 3 is completing
- **Phase 6**: T058, T059 can run in parallel; T060, T061, T062 can be created in parallel

### Critical Path

1. Phase 0 (T001-T007) → 2. Phase 1 (T008-T018) → 3. Phase 2 (T019-T029) → 4. Phase 3 (T030-T039) → 5. Phase 4 (T040-T049) → 6. Phase 5 (T050-T057) → 7. Phase 6 (T058-T064)

---

## Implementation Strategy

### MVP First (Minimum Viable Deployment)

1. Complete Phase 0: Containerization Verification
2. Complete Phase 1: Minikube Setup
3. Complete Phase 2: Database Deployment
4. Complete Phase 3: Backend Deployment
5. Complete Phase 4: Frontend Deployment
6. **STOP and VALIDATE**: Test basic functionality
7. Proceed to Phase 5 and 6 for full verification and tooling

### Incremental Delivery

- After Phase 4: Basic deployment working, can demo
- After Phase 5: Full functionality verified, production-ready
- After Phase 6: Operational tooling complete, documented

---

## Notes

- Total tasks: 64 (within 40-70 range)
- [P] tasks = can run in parallel
- [Story] label maps task to specific user story
- Each task includes command/action and test/validation
- kubectl-ai commands included where applicable
- Kagent commands included for analysis tasks
- Stop at any checkpoint to validate independently
