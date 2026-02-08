---
id: 2
title: Create Containerization Spec
stage: spec
date: 2026-02-07
surface: agent
model: claude-sonnet-4-5-20250929
feature: 001-containerize-with-gordon
branch: 001-containerize-with-gordon
user: Bruno
command: sp.specify
labels: [spec, containerization, docker, gordon]
links:
  spec: specs/001-containerize-with-gordon/spec.md
  ticket: null
  adr: null
  pr: null
files:
 - specs/001-containerize-with-gordon/spec.md
 - specs/001-containerize-with-gordon/checklists/requirements.md
tests:
 - none
---

## Prompt

```text
# Phase IV Spec – Part 1: Containerization with Gordon (Docker AI Agent)

## Project Context
We are in Phase IV: Local Kubernetes Deployment of the AI-powered Todo Chatbot (built in Phase III).

- Frontend: Next.js (App Router), uses OpenAI ChatKit widget, authenticates users via JWT from backend
- Backend: FastAPI (Python), exposes REST APIs for tasks + hosts MCP server/tools for AI agents, uses SQLModel + Neon PostgreSQL (but for local K8s we will use a Postgres container later), Better Auth (JWT)
- AI Layer: OpenAI Agents SDK + MCP tools (add/list/update/complete/delete tasks), conversation history in DB
- Goal for this spec: Produce production-grade Dockerfiles and build instructions for both frontend and backend using **Gordon (Docker AI Agent)** wherever possible. No manual Dockerfile writing — generate via AI-assisted commands or direct generation.

## Requirements
1. Use multi-stage builds for both images (small final size, secure, fast).
2. Frontend (Next.js):
   - Build for production (`next build && next start`)
   - Use Node 20-alpine or slim base
   - Expose port 3000
   - Include .env variables (NEXT_PUBLIC_*, etc.)
   - Optimize: static export if possible, but since ChatKit is dynamic → server needed
3. Backend (FastAPI):
   - Use Python 3.11-slim or 3.12-slim
   - Multi-stage: builder installs deps (uv/pip/poetry), runtime copies only venv + code
   - Expose port 8000 (or 80)
   - Include uvicorn --host 0.0.0.0 --port 8000
   - Dependencies: fastapi, uvicorn, sqlmodel, pydantic, better-auth (and whatever auth lib), openai, any MCP libs
   - Health endpoint: /health → {"status": "ok"}
4. Security:
   - Non-root user in final stage
   - No unnecessary packages
   - .dockerignore excludes node_modules, __pycache__, .git, etc.
5. Gordon-first approach:
   - Prefer commands like: docker ai "Generate a secure multi-stage Dockerfile for a production Next.js app using App Router"
   - Or: docker ai "Create optimized Dockerfile for FastAPI with SQLModel and OpenAI dependencies, multi-stage, non-root"
   - If Gordon not available/unresponsive, fall back to generating the Dockerfile yourself following best 2025–2026 practices.
6. Outputs expected:
   - Separate Dockerfiles for frontend and backend
   - .dockerignore for each
   - Build commands (using Gordon if possible, e.g. docker ai "build this Dockerfile and tag as todo-frontend:v1")
   - Simple docker run / compose snippet to test locally (standalone, no DB yet — backend can mock or fail gracefully)
   - Image size & layer optimization n
```

## Response snapshot

Created a comprehensive specification for containerizing the AI-powered Todo Chatbot with Docker using Gordon. The specification includes:

- User scenarios for containerizing both frontend and backend applications
- Functional requirements for multi-stage Dockerfiles, security practices, and health endpoints
- Success criteria with measurable outcomes for build times, image sizes, and startup performance
- Edge cases and risk considerations

The spec follows the template structure with all mandatory sections completed and is ready for planning phase.

## Outcome

- ✅ Impact: Created complete specification for Phase IV containerization feature
- 🧪 Tests: none
- 📁 Files: Created spec.md and requirements checklist in specs/001-containerize-with-gordon/
- 🔁 Next prompts: Proceed with planning phase (/sp.plan)
- 🧠 Reflection: Specification successfully created following template requirements with proper user scenarios and measurable outcomes

## Evaluation notes (flywheel)

- Failure modes observed: none
- Graders run and results (PASS/FAIL): PASS
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): N/A