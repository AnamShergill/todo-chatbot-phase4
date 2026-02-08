# Implementation Plan: Phase IV - Full Local Kubernetes Deployment of AI Todo Chatbot

**Branch**: `001-kubernetes-deployment` | **Date**: 2026-02-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-kubernetes-deployment/spec.md`

**Note**: This template is filled in by the `/sp.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Deploy the Phase III AI Todo Chatbot (Next.js frontend + FastAPI backend + MCP server + OpenAI Agents) to local Kubernetes using Minikube with Helm charts and AI-assisted tools (Gordon, kubectl-ai, Kagent). The deployment includes containerized applications with optimized Docker images, PostgreSQL database with persistent storage, proper resource allocation, health probes, and LoadBalancer service exposure via minikube tunnel. All infrastructure is generated via AI tools following spec-driven approach with fallback to direct generation when tools are unavailable.

## Technical Context

**Language/Version**: JavaScript/TypeScript (Node 20) for frontend, Python 3.11-3.12 for backend
**Primary Dependencies**: Next.js (App Router), FastAPI, SQLModel, OpenAI SDK, MCP tools, bitnami/postgresql Helm chart, kubectl-ai v0.0.29, Kagent v0.7
**Storage**: PostgreSQL (local container) with 5Gi PersistentVolumeClaim for data persistence
**Testing**: Docker container health checks, Kubernetes liveness/readiness probes, end-to-end workflow verification
**Target Platform**: Kubernetes (Minikube) on local machine with minimum 4 CPUs and 8GB RAM
**Project Type**: Web application (frontend + backend + database)
**Performance Goals**: Complete deployment within 15 minutes, pod startup under 30 seconds, all pods Running within 5 minutes, health endpoints respond within 1 second
**Constraints**: Local-only deployment, resource limits (Frontend: 250m/512Mi requests, Backend: 500m/1Gi requests, PostgreSQL: 500m/1Gi requests), non-root containers, moderate health probe timing (30s initial delay, 10s period, 3 failures, 5s timeout)
**Scale/Scope**: Local development environment, 1-2 replicas per service, multi-user support via JWT authentication, AI chatbot with MCP tool integration

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Spec-Driven Only**: ✅ Complete specification exists with user stories, requirements, success criteria, and clarifications
- **Agentic Workflow**: ✅ Plan outlines phases, dependencies, AI tool integration, and risk mitigation strategies
- **No Manual Coding**: ✅ Primary approach uses AI tools (Gordon for Dockerfiles, kubectl-ai for Helm charts, Kagent for operations) with fallback to automated generation
- **Security & Best Practices**: ✅ Requirements include non-root containers, resource limits/requests, Kubernetes Secrets for sensitive data, least-privilege access
- **Tool Integration**: ✅ Explicit integration of Gordon (Docker AI Agent), kubectl-ai (Kubernetes manifest generation), Kagent (AIOps troubleshooting)
- **Technology Stack Constraints**: ✅ Aligns with Docker Desktop, Minikube, Helm Charts, and Phase III application stack (Next.js, FastAPI, PostgreSQL)

## Project Structure

### Documentation (this feature)

```text
specs/001-kubernetes-deployment/
├── plan.md              # This file (/sp.plan command output)
├── research.md          # Phase 0 output (/sp.plan command)
├── data-model.md        # Phase 1 output (/sp.plan command)
├── quickstart.md        # Phase 1 output (/sp.plan command)
├── contracts/           # Phase 1 output (/sp.plan command)
│   ├── helm-values-schema.yaml
│   ├── postgres-init-schema.sql
│   └── minikube-setup.sh
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)

```text
# Existing Phase III Application Structure
backend/
├── Dockerfile           # From spec 001-containerize-with-gordon
├── .dockerignore
├── src/
│   ├── models/          # SQLModel entities (users, tasks, conversations, messages)
│   ├── services/        # Business logic and MCP server
│   ├── api/             # FastAPI routes and Better Auth
│   └── main.py
├── requirements.txt
└── tests/

frontend/
├── Dockerfile           # From spec 001-containerize-with-gordon
├── .dockerignore
├── src/
│   ├── app/             # Next.js App Router pages
│   ├── components/      # React components including ChatKit
│   └── lib/             # API client and utilities
├── package.json
└── tests/

# New Kubernetes/Helm Infrastructure (to be generated)
k8s/
├── helm/
│   ├── todo-postgres/   # PostgreSQL Helm chart (bitnami-based or custom)
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── statefulset.yaml
│   │       ├── service.yaml
│   │       ├── pvc.yaml
│   │       ├── secret.yaml
│   │       └── configmap.yaml (with init SQL)
│   ├── todo-backend/    # Backend Helm chart (generated via kubectl-ai)
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       ├── configmap.yaml
│   │       └── secret.yaml
│   └── todo-frontend/   # Frontend Helm chart (generated via kubectl-ai)
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml (LoadBalancer)
│           └── configmap.yaml
├── scripts/
│   ├── setup-minikube.sh      # Initialize Minikube cluster
│   ├── deploy-all.sh           # Deploy all components in order
│   ├── verify-deployment.sh    # Check pod status and health
│   └── cleanup.sh              # Teardown and cleanup
└── README.md                   # Deployment instructions
```

**Structure Decision**: Following web application structure with existing frontend/backend from Phase III. Adding new k8s/ directory for Kubernetes infrastructure including Helm charts (generated via kubectl-ai), deployment scripts, and configuration. Helm charts are organized by component (postgres, backend, frontend) with standard chart structure (Chart.yaml, values.yaml, templates/). Scripts provide automation for Minikube setup, deployment, verification, and cleanup.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No violations detected. All constitution principles are satisfied:
- Spec-driven approach with complete specification
- Agentic workflow with AI tool integration
- No manual coding (automated generation via AI tools)
- Security best practices enforced
- Proper tool integration (Gordon, kubectl-ai, Kagent)
- Technology stack constraints aligned

---

## Phase 0: Research (Complete)

**Status**: ✅ Complete
**Output**: `research.md`

**Key Decisions Documented**:
1. Container orchestration platform (Minikube)
2. Package management (Helm 3.x)
3. AI tool integration strategy (kubectl-ai with fallback)
4. Database deployment approach (bitnami/postgresql with initdb)
5. Resource allocation strategy (conservative balanced)
6. Service exposure method (minikube tunnel + LoadBalancer)
7. Health probe configuration (moderate timing)
8. Persistent storage configuration (5Gi PVC)
9. Security configuration (multi-layered)
10. AI operations integration (Kagent)

**Alternatives Evaluated**: 10 major decisions with 3-4 alternatives each
**Best Practices Applied**: Kubernetes, Helm, and container best practices documented
**Risk Mitigation**: 5 major risks with mitigation strategies

---

## Phase 1: Design & Contracts (Complete)

**Status**: ✅ Complete
**Outputs**:
- `data-model.md` - Kubernetes resource model and relationships
- `contracts/helm-values-schema.yaml` - Helm values structure
- `contracts/postgres-init-schema.sql` - Database initialization script
- `contracts/minikube-setup.sh` - Cluster setup automation
- `quickstart.md` - Deployment guide

**Data Model Entities**:
- Namespace (todo-chatbot)
- PostgreSQL StatefulSet (1 replica, 5Gi PVC)
- Backend Deployment (1-2 replicas, FastAPI + MCP)
- Frontend Deployment (1-2 replicas, Next.js)
- Services (ClusterIP for internal, LoadBalancer for external)
- ConfigMaps (postgres-init, backend-config, frontend-config)
- Secrets (postgres-secret, backend-secret)
- PersistentVolumeClaim (5Gi for PostgreSQL)

**Deployment Order**: 10 steps with proper dependency management
**Resource Dependencies**: Complete dependency graph documented

---

## Constitution Check (Post-Design Re-evaluation)

*GATE: Final check after Phase 1 design completion.*

- **Spec-Driven Only**: ✅ All artifacts generated from specification requirements
- **Agentic Workflow**: ✅ Research phase documented all decisions with rationale and alternatives
- **No Manual Coding**: ✅ Contracts provide automation scripts and configuration templates
- **Security & Best Practices**: ✅ Data model enforces non-root containers, Secrets for sensitive data, resource limits, health probes
- **Tool Integration**: ✅ Helm values schema supports kubectl-ai generation, Kagent analysis
- **Technology Stack Constraints**: ✅ All components align with Docker, Minikube, Helm, Phase III stack

**Final Assessment**: ✅ **PASS** - All constitution principles satisfied. Ready for task generation (`/sp.tasks`).

---

## Next Steps

1. **Generate Tasks**: Run `/sp.tasks` to create detailed task breakdown
2. **Implement**: Execute tasks in order (containerization verification → Minikube setup → database → backend → frontend → verification)
3. **Verify**: Test end-to-end workflows and data persistence
4. **Optimize**: Use Kagent for cluster analysis and optimization

---

## Artifacts Summary

| Artifact | Path | Status | Purpose |
|----------|------|--------|---------|
| Implementation Plan | `plan.md` | ✅ Complete | This file - overall architecture and phases |
| Research | `research.md` | ✅ Complete | Key decisions, rationale, alternatives |
| Data Model | `data-model.md` | ✅ Complete | Kubernetes resource model and relationships |
| Helm Values Schema | `contracts/helm-values-schema.yaml` | ✅ Complete | Configuration structure for all charts |
| Database Init Script | `contracts/postgres-init-schema.sql` | ✅ Complete | PostgreSQL schema initialization |
| Minikube Setup Script | `contracts/minikube-setup.sh` | ✅ Complete | Cluster initialization automation |
| Quickstart Guide | `quickstart.md` | ✅ Complete | Step-by-step deployment instructions |
| Tasks | `tasks.md` | ⏳ Pending | To be generated via `/sp.tasks` |
