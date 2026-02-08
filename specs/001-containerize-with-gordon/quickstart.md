# Quickstart Guide: Phase IV Containerization

## Prerequisites
- Docker Desktop installed and running
- Gordon (Docker AI Agent) available in your environment
- Node.js 20.x (for local development, not in container)
- Python 3.11.x (for local development, not in container)

## Getting Started with Containerization

### 1. Generate Dockerfiles using Gordon

#### Frontend (Next.js) Container
Run Gordon to generate the Dockerfile for the frontend application:

```bash
cd frontend
docker ai "Generate a secure multi-stage Dockerfile for a production Next.js 14+ App Router application using Node 20-alpine, with non-root user, optimized for size and build time, exposing port 3000"
```

#### Backend (FastAPI) Container
Run Gordon to generate the Dockerfile for the backend application:

```bash
cd backend
docker ai "Create an optimized multi-stage Dockerfile for a FastAPI application with Python 3.11-slim, SQLModel, Better Auth, OpenAI SDK, and MCP tools, using non-root user, exposing port 8000, include health endpoint"
```

### 2. Build Container Images

#### Build Frontend Image
```bash
cd frontend
docker build -t todo-frontend:local .
```

#### Build Backend Image
```bash
cd backend
docker build -t todo-backend:local .
```

### 3. Test Container Locally (Without Database)

#### Test Frontend Container
```bash
docker run -p 3000:3000 todo-frontend:local
```

#### Test Backend Container
```bash
docker run -p 8000:8000 todo-backend:local
```

### 4. Alternative: Docker Compose for Local Testing
Create a docker-compose.yml file to run both containers together:

```yaml
version: '3.8'
services:
  frontend:
    build: ./frontend
    image: todo-frontend:local
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000
    restart: unless-stopped

  backend:
    build: ./backend
    image: todo-backend:local
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=sqlite:///./test.db  # Mock for local testing
    restart: unless-stopped
```

Run with:
```bash
docker-compose up
```

### 5. Verify Container Health

#### Check Frontend Health
Once the frontend container is running, visit: `http://localhost:3000`

#### Check Backend Health
Once the backend container is running, visit: `http://localhost:8000/health`
Expected response: `{"status": "ok"}`

### 6. Monitor Image Sizes
Check the size of your built images:
```bash
docker images | grep todo-
```

Ensure the sizes are within the target limits:
- Frontend: Under 200MB
- Backend: Under 300MB

### 7. Troubleshooting
- If Gordon is unavailable, manually create the Dockerfiles following multi-stage patterns
- Ensure your Docker daemon is running
- Check that all required ports (3000, 8000) are available
- Verify environment variables are properly set for container execution