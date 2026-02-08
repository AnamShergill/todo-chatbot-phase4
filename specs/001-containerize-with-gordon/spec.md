# Feature Specification: Phase IV Containerization with Gordon

**Feature Branch**: `001-containerize-with-gordon`
**Created**: 2026-02-07
**Status**: Draft
**Input**: User description: "# Phase IV Spec – Part 1: Containerization with Gordon (Docker AI Agent)

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
   - Health endpoint: /health → {\"status\": \"ok\"}
4. Security:
   - Non-root user in final stage
   - No unnecessary packages
   - .dockerignore excludes node_modules, __pycache__, .git, etc.
5. Gordon-first approach:
   - Prefer commands like: docker ai \"Generate a secure multi-stage Dockerfile for a production Next.js app using App Router\"
   - Or: docker ai \"Create optimized Dockerfile for FastAPI with SQLModel and OpenAI dependencies, multi-stage, non-root\"
   - If Gordon not available/unresponsive, fall back to generating the Dockerfile yourself following best 2025–2026 practices.
6. Outputs expected:
   - Separate Dockerfiles for frontend and backend
   - .dockerignore for each
   - Build commands (using Gordon if possible, e.g. docker ai \"build this Dockerfile and tag as todo-frontend:v1\")
   - Simple docker run / compose snippet to test locally (standalone, no DB yet — backend can mock or fail gracefully)
   - Image size & layer optimization n"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Containerize Frontend Application (Priority: P1)

As a developer, I want to containerize the Next.js frontend application so that it can be deployed consistently across environments. The container should be optimized for production use with minimal attack surface and fast startup times.

**Why this priority**: This is critical for the deployment pipeline as the frontend serves the user interface for the Todo Chatbot and must be reliably deployable in the Kubernetes environment.

**Independent Test**: Can be fully tested by building the Docker image using Gordon and running the container to verify it serves the Next.js application on port 3000.

**Acceptance Scenarios**:

1. **Given** a Next.js codebase, **When** Gordon generates a multi-stage Dockerfile, **Then** the resulting image should be production-optimized with a small footprint
2. **Given** a containerized Next.js application, **When** the container starts, **Then** it should serve the application on port 3000
3. **Given** environment variables prefixed with NEXT_PUBLIC_, **When** the container starts, **Then** these variables should be available to the application

---

### User Story 2 - Containerize Backend Application (Priority: P1)

As a developer, I want to containerize the FastAPI backend application so that it can be deployed consistently with security best practices. The container should support the MCP server and AI tools integration while maintaining security.

**Why this priority**: The backend is essential for providing the REST APIs and hosting the MCP server for AI agents, making it a critical component of the system.

**Independent Test**: Can be fully tested by building the Docker image using Gordon and verifying it starts the FastAPI application on port 8000 with the health endpoint available.

**Acceptance Scenarios**:

1. **Given** a FastAPI codebase with MCP tools, **When** Gordon generates a multi-stage Dockerfile, **Then** the resulting image should be production-optimized and include all required dependencies
2. **Given** a containerized FastAPI application, **When** the container starts, **Then** it should serve the application on port 8000
3. **Given** the health endpoint, **When** an HTTP request is made to /health, **Then** it should return {"status": "ok"}

---

### User Story 3 - Generate Production-Ready Dockerfiles via AI Agent (Priority: P2)

As a development team member, I want to leverage Gordon (Docker AI Agent) to generate production-grade Dockerfiles rather than manually writing them, ensuring best practices are followed.

**Why this priority**: This supports the development workflow efficiency and ensures Dockerfiles follow security and performance best practices as defined by AI-generated recommendations.

**Independent Test**: Can be tested by comparing AI-generated Dockerfiles with manually crafted ones and verifying they meet security and optimization requirements.

**Acceptance Scenarios**:

1. **Given** a Next.js application structure, **When** Gordon generates a Dockerfile, **Then** it should include multi-stage build, non-root user, and proper dependencies
2. **Given** a FastAPI application structure, **When** Gordon generates a Dockerfile, **Then** it should include multi-stage build, security best practices, and proper dependency management

---

### Edge Cases

- What happens when Gordon is unavailable or unresponsive?
- How does the system handle dependency conflicts during Docker build?
- What occurs when the containerized application encounters runtime environment issues?
- How does the container behave with insufficient resources allocated?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST generate multi-stage Dockerfiles for both Next.js frontend and FastAPI backend applications
- **FR-002**: Frontend Dockerfile MUST use Node 20-alpine or slim base image for optimized size and security
- **FR-003**: Backend Dockerfile MUST use Python 3.11-slim or 3.12-slim base image with multi-stage build approach
- **FR-004**: System MUST run applications as non-root user in the final Docker image stage for security
- **FR-005**: Frontend application MUST expose port 3000 for serving the Next.js application
- **FR-006**: Backend application MUST expose port 8000 for serving the FastAPI application
- **FR-007**: System MUST exclude unnecessary files and directories (node_modules, __pycache__, .git) via .dockerignore
- **FR-008**: Backend application MUST provide a health endpoint at /health returning {"status": "ok"}
- **FR-009**: System MUST include all required dependencies (fastapi, uvicorn, sqlmodel, pydantic, better-auth, openai, MCP libraries) in the backend image
- **FR-010**: Docker images MUST be optimized for size and build time using multi-stage approach

### Key Entities *(include if feature involves data)*

- **Frontend Container**: Represents the Next.js application container with optimized build process and security features
- **Backend Container**: Represents the FastAPI application container with MCP tools and AI agent integration capabilities

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Docker images for both frontend and backend complete building in under 5 minutes on standard CI infrastructure
- **SC-002**: Final Docker images are under 200MB for frontend and 300MB for backend (after multi-stage optimization)
- **SC-003**: Both containers successfully start and serve their respective applications within 30 seconds of container initialization
- **SC-004**: Health endpoints return status OK in both containers within 10 seconds of container startup
- **SC-005**: Gordon successfully generates both Dockerfiles with minimal human intervention (less than 10% manual corrections needed)
- **SC-006**: Both containers run as non-root users and pass container security scanning with no high-severity vulnerabilities