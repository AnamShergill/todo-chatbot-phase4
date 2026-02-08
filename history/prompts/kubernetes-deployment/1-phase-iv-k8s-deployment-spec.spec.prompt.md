---
id: 1
title: Phase IV Kubernetes Deployment Spec
stage: spec
date: 2026-02-07
surface: agent
model: claude-sonnet-4-5-20250929
feature: kubernetes-deployment
branch: 001-kubernetes-deployment
user: Bruno
command: /sp.specify
labels: ["kubernetes", "minikube", "helm", "deployment", "phase-iv", "ai-tools"]
links:
  spec: specs/001-kubernetes-deployment/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/001-kubernetes-deployment/spec.md
  - specs/001-kubernetes-deployment/checklists/requirements.md
tests:
  - Specification quality validation checklist
---

## Prompt

Previous progress: Containerization spec 001 was in progress (25 tasks planned across 6 phases: Setup, Foundational, Frontend, Backend, Optimization, Polish). Phase 1 (Gordon check + .dockerignore) partially done or complete; images may be built/tested locally (todo-frontend:local, todo-backend:local). Quota issue interrupted the workflow. Resume from there or regenerate full master plan if needed, incorporating existing 001 artifacts where possible (e.g., reference plan.md, tasks.md, quickstart.md, research.md, data-model.md from specs/001-containerize-with-gordon).

# Master Spec: Phase IV – Full Local Kubernetes Deployment of AI Todo Chatbot (Consolidated)

## Project Context & Status
We are executing Phase IV as a single consolidated spec to deploy the Phase III AI Todo Chatbot (Next.js frontend + FastAPI backend + MCP server + OpenAI Agents/ChatKit) on local Minikube using Helm charts and AI-assisted tools.

Current progress: Containerization spec (001-containerize-with-gordon) is in progress/completed (25 tasks across phases: Setup, Foundational, Frontend, Backend, Optimization, Polish). Images should be: todo-frontend:local and todo-backend:local (or similar tags). If not fully done yet, include as Phase 1 with verification tasks.

## Overall Objective
Achieve a fully working local cloud-native deployment:
- Multi-user todo management via web UI (JWT auth).
- Natural language task ops via AI chatbot (MCP tools calling backend).
- All running in Minikube pods, with Helm packaging and AI-tool assistance.

## Full Requirements (Cover EVERYTHING from original doc)
1. **Containerization** (build on existing 001 if applicable):
   - Prefer Gordon (Ask Gordon / Docker AI Agent) for Dockerfiles, .dockerignore, builds.
   - Multi-stage, non-root (e.g., node user for frontend, appuser for backend), slim bases (node:20/22-slim, python:3.12-slim).
   - Optimized images (<200–300MB targets), health endpoints (/health).
   - Local test (docker run or simple compose, no DB yet).
2. **Minikube Setup**:
   - Start cluster (minikube start --cpus=4 --memory=8g if laptop allows).
   - Enable addons: ingress, metrics-server (for Kagent).
3. **Local PostgreSQL**:
   - Deploy via Helm (bitnami/postgresql or custom) as StatefulSet + PersistentVolumeClaim.
   - Init DB schema from Phase III (tables for users/tasks/conversations).
4. **Helm Charts** (generate via kubectl-ai):
   - Charts for: postgres, backend (FastAPI + uvicorn + MCP), frontend (Next.js server).
   - Include: Deployments (1–2 replicas), Services (ClusterIP), ConfigMaps/Secrets (env vars: JWT secret, OpenAI key placeholders, DB creds), liveness/readiness probes.
   - Optional umbrella chart.
5. **Deployment & Exposure**:
   - helm install commands.
   - Access: minikube service, minikube tunnel, or ingress hostname.
6. **AI-Assisted Operations**:
   - kubectl-ai for generating charts/manifests, deploy/scale/troubleshoot (e.g. kubectl-ai "generate Helm chart for FastAPI backend with health probe").
   - Kagent for post-deploy: cluster health analysis, resource optimization, pod failure diagnosis (e.g. kagent "analyze why backend pods are crashing").
7. **Verification & End-to-End**:
   - Pods running, logs clean.
   - Web UI login + task CRUD.
   - Chatbot conversation → MCP tool calls → DB updates.
   - Cleanup/teardown script.

## Constraints & Tool Status (Feb 2026)
- Spec-driven/agentic only: generate everything via Claude blueprints or AI tools — no manual edits.
- Prefer: Gordon (beta, post-4.50.0 fixed DockerDash vuln; requires user confirmation for tools; fallback to direct generation if unavailable).
- kubectl-ai (v0.0.29 Jan 2026): primary for Helm/K8s generation.
- Kagent (CNCF Sandbox, v0.7 recent): for advanced troubleshooting/optimization.
- Local-only: Minikube, secrets via Helm values/Secrets, no cloud Neon (use local Postgres).
- Security: non-root containers, resource limits/requests, least-privilege.
- Monorepo: paths like /frontend, /backend.

## Workflow for Claude (Strict Constitution)
1. **Generate Detailed Master Plan**:
   - Numbered sub

## Response snapshot

Created comprehensive Phase IV Kubernetes deployment specification for AI Todo Chatbot with the following key components:

**Specification Structure**:
- Project context documenting Phase III application architecture (Next.js frontend, FastAPI backend, MCP server, OpenAI integration)
- Dependency on containerization spec 001-containerize-with-gordon
- Clear objective: local cloud-native deployment on Minikube

**User Stories** (6 total, prioritized P0-P3):
- US0 (P0): Verify containerization prerequisites - blocking requirement
- US1 (P1): Deploy applications to Minikube
- US2 (P1): Deploy PostgreSQL with persistent storage
- US3 (P2): Generate Helm charts via kubectl-ai
- US4 (P2): Enable AI-assisted operations with Kagent
- US5 (P3): End-to-end functionality verification

**Requirements** (45 functional requirements):
- FR-001 to FR-007: Containerization prerequisites
- FR-008 to FR-011: Minikube setup
- FR-012 to FR-016: PostgreSQL database
- FR-017 to FR-025: Helm charts
- FR-026 to FR-030: Deployment & exposure
- FR-031 to FR-035: AI-assisted operations
- FR-036 to FR-041: Verification & end-to-end
- FR-042 to FR-045: Cleanup & teardown

**Non-Functional Requirements** (25 NFRs):
- Performance: 15-minute deployment, <30s pod startup
- Reliability: 95% uptime, zero data loss
- Scalability: 2-3 replica support
- Security: non-root containers, secrets management
- Maintainability: parameterized Helm charts
- Observability: health endpoints, metrics collection

**Success Criteria** (15 measurable outcomes):
- Time-based metrics (deployment <15 min, pod startup <5 min)
- Reliability metrics (95% uptime over 24 hours)
- Functionality verification (end-to-end workflows)
- AI tool effectiveness (90% manifest generation success)
- Resource utilization (<80% of limits)

**Additional Sections**:
- Constraints & Dependencies: tool versions, resource requirements
- Assumptions: environment prerequisites
- Out of Scope: 14 explicitly excluded items (cloud deployment, production hardening, etc.)
- Workflow Guidance: 7-phase implementation structure
- Risk Mitigation: strategies for AI tool failures, resource constraints
- Related Documentation: links to relevant specs and external docs

**Quality Validation**:
- Created requirements.md checklist with all items passing
- Verified no [NEEDS CLARIFICATION] markers
- Confirmed all requirements are testable and measurable
- Validated success criteria are technology-agnostic
- Status: ✅ READY FOR PLANNING

## Outcome

- ✅ Impact: Comprehensive specification created for Phase IV Kubernetes deployment covering all requirements from containerization through end-to-end verification
- 🧪 Tests: Specification quality checklist created and validated - all items pass
- 📁 Files: specs/001-kubernetes-deployment/spec.md (enhanced), specs/001-kubernetes-deployment/checklists/requirements.md (created)
- 🔁 Next prompts: `/sp.clarify` (if any ambiguities found) or `/sp.plan` (to create implementation plan)
- 🧠 Reflection: Specification successfully integrates containerization prerequisites, AI tool usage (Gordon, kubectl-ai, Kagent), and comprehensive Kubernetes deployment requirements with clear prioritization and measurable success criteria

## Evaluation notes (flywheel)

- Failure modes observed: None - specification completed successfully with all validation checks passing
- Graders run and results (PASS/FAIL): Specification quality checklist - PASS (all 14 items validated)
- Prompt variant (if applicable): Standard /sp.specify workflow with comprehensive input covering all Phase IV requirements
- Next experiment (smallest change to try): Proceed to planning phase with `/sp.plan` to generate detailed implementation plan and tasks
