# Data Model: Phase IV Containerization

## Overview
Data model for containerized applications (frontend and backend) in the Todo Chatbot system.

## Container Configuration Entities

### Frontend Container
**Description**: Represents the Next.js application container configuration
**Attributes**:
- container_name: String (todo-frontend)
- base_image: String (node:20-alpine)
- exposed_port: Integer (3000)
- environment_variables: Map (NEXT_PUBLIC_* variables)
- build_context: String (./frontend)
- user_id: Integer (non-root user ID)
- health_check: String (curl http://localhost:3000 or similar)
- volumes: List (for static assets if needed)

### Backend Container
**Description**: Represents the FastAPI application container configuration
**Attributes**:
- container_name: String (todo-backend)
- base_image: String (python:3.11-slim)
- exposed_port: Integer (8000)
- environment_variables: Map (database URLs, API keys, etc.)
- build_context: String (./backend)
- user_id: Integer (non-root user ID)
- health_endpoint: String (/health)
- health_response: Object ({"status": "ok"})
- volumes: List (for logs, uploads if needed)

## Container Relationships
- The frontend and backend containers are independent but designed to work together in the same network
- The frontend makes API calls to the backend container
- In future phases, both containers will connect to a PostgreSQL container

## Container States
**Frontend Container States**:
- build_pending: Awaiting Docker build process
- building: Currently building the image
- built: Image successfully built
- starting: Container starting up
- running: Container serving requests
- stopped: Container stopped

**Backend Container States**:
- build_pending: Awaiting Docker build process
- building: Currently building the image
- built: Image successfully built
- starting: Container starting up
- running: Container serving requests and MCP tools
- stopped: Container stopped

## Container Validation Rules
1. Base images must be from official sources (Docker Hub)
2. Exposed ports must be in the allowed range
3. Non-root user ID must be greater than 100
4. Health checks must return success within 30 seconds
5. Environment variables with secrets must not be logged
6. Image sizes must comply with specified limits (200MB frontend, 300MB backend)

## Deployment Configuration
### Docker Compose Configuration
**Services**:
- frontend: Next.js application with port 3000 exposed
- backend: FastAPI application with port 8000 exposed
- (Future) postgres: PostgreSQL database service

### Network Configuration
- Default bridge network for local development
- Dedicated custom network for production scenarios
- Internal communication between services
- External access through published ports

## Build Configuration
### Frontend Build Requirements
- Node.js 20.x
- npm/yarn for dependency management
- Next.js build process (next build)
- Production start command (next start)
- Static asset optimization

### Backend Build Requirements
- Python 3.11.x
- pip for dependency management
- Virtual environment setup
- FastAPI application startup
- Uvicorn server configuration