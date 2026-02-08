# Research: Phase IV - Full Local Kubernetes Deployment

**Feature**: 001-kubernetes-deployment | **Date**: 2026-02-07
**Input**: Technical context from plan.md and specification requirements

## Overview

This research phase documents the key architectural decisions, technology choices, and best practices for deploying the Phase III AI Todo Chatbot to local Kubernetes using Minikube with AI-assisted tools.

## Key Decisions

### 1. Container Orchestration Platform

**Decision**: Use Minikube for local Kubernetes deployment

**Rationale**:
- Provides production-like Kubernetes environment on local machine
- Supports all standard Kubernetes features (pods, services, deployments, StatefulSets)
- Easy to set up and tear down for development/testing
- Integrates well with kubectl and Helm
- Sufficient for local development with 4 CPU/8GB RAM allocation
- Enables testing of cloud-native patterns before production deployment

**Alternatives Considered**:
- **Docker Compose**: Simpler but doesn't provide Kubernetes-native features (no pods, services, deployments). Rejected because goal is to test Kubernetes deployment patterns.
- **Kind (Kubernetes in Docker)**: Similar to Minikube but runs Kubernetes nodes as Docker containers. Rejected because Minikube has better tooling support and is more widely documented.
- **k3s**: Lightweight Kubernetes distribution. Rejected because Minikube is more standard for local development and has better integration with development tools.
- **MicroK8s**: Canonical's lightweight Kubernetes. Rejected because Minikube has broader community support and simpler setup.

### 2. Package Management and Deployment

**Decision**: Use Helm 3.x for packaging and deploying Kubernetes applications

**Rationale**:
- Industry-standard package manager for Kubernetes
- Provides templating for Kubernetes manifests with values.yaml for configuration
- Enables parameterized deployments (different environments, resource allocations)
- Supports dependency management between charts
- Simplifies rollback and upgrade operations
- Well-integrated with kubectl-ai for AI-assisted chart generation
- Bitnami provides production-ready PostgreSQL chart

**Alternatives Considered**:
- **Raw Kubernetes YAML**: More direct but lacks templating and parameterization. Rejected because it requires manual duplication for different configurations.
- **Kustomize**: Built into kubectl, provides overlay-based customization. Rejected because Helm's templating is more powerful and kubectl-ai has better Helm support.
- **Jsonnet**: Provides JSON templating for Kubernetes. Rejected because Helm is more widely adopted and has better tooling ecosystem.

### 3. AI Tool Integration Strategy

**Decision**: Use kubectl-ai (v0.0.29) for Helm chart generation with fallback to direct generation

**Rationale**:
- Automates Helm chart creation following best practices
- Reduces manual YAML writing and potential errors
- Generates proper Deployment, Service, ConfigMap, Secret manifests
- Supports natural language commands (e.g., "generate Helm chart for FastAPI backend with health probe")
- Aligns with spec-driven/agentic workflow principle
- Provides consistent structure across all charts

**Alternatives Considered**:
- **Manual Helm chart creation**: More control but time-consuming and error-prone. Rejected because it violates "No Manual Coding" principle.
- **Helm chart templates from repositories**: Faster but may not match specific requirements. Rejected because kubectl-ai can generate custom charts tailored to our needs.
- **Copilot/ChatGPT for generation**: Requires copy-paste workflow. Rejected because kubectl-ai integrates directly with kubectl CLI.

**Fallback Strategy**: If kubectl-ai unavailable, generate Helm charts directly following 2025-2026 best practices with proper structure, health probes, resource limits, and security configurations.

### 4. Database Deployment Approach

**Decision**: Use bitnami/postgresql Helm chart with initdb ConfigMap for schema initialization

**Rationale**:
- Production-ready chart with proper StatefulSet configuration
- Built-in support for persistent storage via PVC
- Native initdb mechanism for automatic schema initialization on first start
- Handles database credentials via Kubernetes Secrets
- Provides proper health checks and resource management
- Well-maintained and widely used in production
- Simpler than custom Job-based initialization

**Alternatives Considered**:
- **Custom PostgreSQL Deployment**: More control but requires manual StatefulSet, PVC, and initialization logic. Rejected because bitnami chart is production-tested.
- **Kubernetes Job for initialization**: Separate one-time task for schema setup. Rejected because bitnami's initdb is simpler and automatic.
- **Init Container in backend**: Couples schema initialization to backend deployment. Rejected because it creates unnecessary dependency and complicates backend startup.
- **Manual kubectl exec**: Requires manual intervention. Rejected because it's not automated and violates spec-driven principle.

### 5. Resource Allocation Strategy

**Decision**: Conservative allocation with balanced requests/limits

**Configuration**:
- **Frontend**: requests (250m CPU, 512Mi RAM), limits (500m CPU, 1Gi RAM)
- **Backend**: requests (500m CPU, 1Gi RAM), limits (1000m CPU, 2Gi RAM)
- **PostgreSQL**: requests (500m CPU, 1Gi RAM), limits (1000m CPU, 2Gi RAM)

**Rationale**:
- Ensures reliable pod scheduling on 4 CPU/8GB Minikube cluster
- Leaves headroom for system overhead and multiple replicas (1-2 per service)
- Backend gets more resources due to MCP server and AI agent processing
- Limits prevent resource exhaustion and OOM kills
- Requests guarantee minimum resources for stable operation
- Total requests: ~1.25 CPU, ~2.5Gi RAM (allows 2 replicas with headroom)

**Alternatives Considered**:
- **Minimal allocation** (Frontend: 100m/256Mi, Backend: 200m/512Mi): Rejected because it may cause OOM issues and slow performance, especially for AI processing.
- **Generous allocation** (Frontend: 500m/1Gi, Backend: 1000m/2Gi): Rejected because it may exceed Minikube capacity when running multiple replicas.
- **No limits**: Rejected because it allows resource exhaustion and impacts cluster stability.

### 6. Service Exposure Method

**Decision**: Minikube tunnel with LoadBalancer service as primary access method

**Rationale**:
- Most production-like experience (LoadBalancer is standard in cloud)
- Provides clean localhost URLs without high ports
- Automatic IP assignment via tunnel
- Simple to use: `minikube tunnel` runs in background
- Enables testing of LoadBalancer patterns before cloud deployment
- Better UX than NodePort (no port lookup needed)

**Alternatives Considered**:
- **NodePort**: Exposes on high port (30000-32767), requires minikube ip lookup. Rejected because URLs are less intuitive and require port management.
- **Ingress with hostname**: More complex, requires /etc/hosts entry. Rejected because it adds unnecessary complexity for local development.
- **minikube service command**: Simplest but temporary and session-specific. Rejected because it doesn't persist across sessions and requires manual browser opening.
- **Port forwarding**: Direct kubectl port-forward. Rejected because it's not production-like and requires keeping terminal open.

### 7. Health Probe Configuration

**Decision**: Moderate timing with startup consideration

**Configuration**:
- initialDelaySeconds: 30
- periodSeconds: 10
- failureThreshold: 3
- timeoutSeconds: 5

**Rationale**:
- 30s initial delay allows sufficient time for application startup and database connection
- 10s period provides reasonable failure detection without excessive API calls
- 3 failures before restart prevents premature pod termination
- 5s timeout accommodates network latency and slow responses
- Balances quick failure detection with stability during startup
- Suitable for backend connecting to database and frontend loading assets

**Alternatives Considered**:
- **Aggressive timing** (10s delay, 5s period, 2 failures): Rejected because it may cause premature restarts during slow startup or database connection delays.
- **Conservative timing** (60s delay, 15s period, 5 failures): Rejected because it delays failure detection and prolongs unhealthy pod exposure.
- **No initial delay**: Rejected because applications need time to start before health checks succeed.

### 8. Persistent Storage Configuration

**Decision**: 5Gi PersistentVolumeClaim for PostgreSQL

**Rationale**:
- Adequate space for multi-user testing with tasks, conversations, and message history
- Reasonable for local Minikube storage without excessive disk usage
- Allows for growth during extended testing periods
- Sufficient for development/testing workload (not production scale)
- Balances capacity with local machine constraints

**Alternatives Considered**:
- **2Gi volume**: Rejected because it may fill quickly with conversation history and multiple users.
- **10Gi volume**: Rejected because it's excessive for local development and wastes disk space.
- **EmptyDir (no persistence)**: Rejected because data loss on pod restart is unacceptable for database.

### 9. Security Configuration

**Decision**: Multi-layered security approach

**Implementations**:
- Non-root containers (security context in Deployments)
- Kubernetes Secrets for sensitive data (JWT secret, DB credentials, OpenAI API key)
- Resource limits to prevent resource exhaustion attacks
- Health probes to detect and restart compromised pods
- Least-privilege service accounts (default, no special permissions)

**Rationale**:
- Non-root prevents privilege escalation attacks
- Secrets provide base64 encoding and access control
- Resource limits prevent DoS via resource exhaustion
- Health probes enable automatic recovery from failures
- Follows Kubernetes security best practices for local development

**Alternatives Considered**:
- **Root containers**: Rejected because it violates security best practices and increases attack surface.
- **ConfigMaps for secrets**: Rejected because ConfigMaps are not designed for sensitive data and lack proper access controls.
- **No resource limits**: Rejected because it allows resource exhaustion and impacts cluster stability.
- **Pod Security Policies**: Rejected because PSPs are deprecated in Kubernetes 1.25+ and out of scope for local development.

### 10. AI Operations Integration

**Decision**: Use Kagent (v0.7) for post-deployment analysis and troubleshooting

**Rationale**:
- Provides AI-powered cluster health analysis
- Automates diagnosis of common Kubernetes issues
- Offers resource optimization recommendations
- Reduces time to resolution for deployment problems
- Complements kubectl-ai for end-to-end AI-assisted workflow

**Alternatives Considered**:
- **Manual kubectl commands**: More control but time-consuming and requires deep Kubernetes knowledge. Rejected because Kagent automates common troubleshooting patterns.
- **Prometheus + Grafana**: Production-grade monitoring but excessive for local development. Rejected because it's out of scope and adds complexity.
- **Lens IDE**: GUI-based Kubernetes management. Rejected because it's not CLI-based and doesn't align with agentic workflow.

## Best Practices Applied

### Kubernetes Deployment Patterns

1. **StatefulSet for Database**: Ensures stable network identity and ordered deployment/scaling
2. **Deployment for Stateless Apps**: Frontend and backend use Deployments for easy scaling and rolling updates
3. **Service Discovery**: ClusterIP services for internal communication, LoadBalancer for external access
4. **ConfigMaps for Configuration**: Non-sensitive config separated from container images
5. **Secrets for Sensitive Data**: Database credentials, JWT secrets, API keys stored securely
6. **Health Probes**: Liveness and readiness probes for automatic failure detection and recovery
7. **Resource Management**: Requests and limits for proper scheduling and stability
8. **Labels and Annotations**: Proper labeling for service discovery and management

### Helm Chart Best Practices

1. **Parameterization**: Use values.yaml for all configurable parameters
2. **Template Functions**: Use Helm template functions for dynamic values
3. **Dependencies**: Declare chart dependencies in Chart.yaml
4. **Documentation**: Include README.md with usage instructions
5. **Versioning**: Semantic versioning for chart releases
6. **Testing**: Helm lint and dry-run before installation

### Container Best Practices

1. **Multi-stage Builds**: Separate build and runtime stages for smaller images
2. **Non-root Users**: Run containers as non-root for security
3. **Health Endpoints**: Expose /health endpoints for probes
4. **Minimal Base Images**: Use alpine or slim variants
5. **Layer Optimization**: Order Dockerfile commands to maximize cache hits
6. **Security Scanning**: Scan images for vulnerabilities (out of scope but recommended)

## Risk Mitigation Strategies

### Risk: AI Tools Unavailable

**Mitigation**: Fallback to direct generation following 2025-2026 best practices
- Maintain templates for Helm charts
- Document manual generation procedures
- Ensure all requirements can be met without AI tools

### Risk: Insufficient Local Resources

**Mitigation**: Conservative resource allocation and monitoring
- Document minimum requirements (4 CPU, 8GB RAM)
- Provide resource optimization guidance
- Monitor cluster resource usage with kubectl top

### Risk: Database Initialization Failures

**Mitigation**: Idempotent initialization and manual fallback
- Use bitnami's initdb for automatic setup
- Provide manual schema application scripts
- Ensure SQL scripts are idempotent (IF NOT EXISTS)

### Risk: Inter-service Connectivity Issues

**Mitigation**: Service discovery patterns and debugging tools
- Use Kubernetes DNS for service discovery
- Document service naming conventions
- Provide kubectl debugging commands

### Risk: Persistent Volume Binding Failures

**Mitigation**: PV/PVC troubleshooting and manual provisioning
- Document PV/PVC status checking
- Provide manual PV creation if needed
- Use Minikube's default storage class

## Technology Stack Summary

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Container Runtime | Docker Desktop | Latest | Build and run containers |
| Orchestration | Minikube | Latest | Local Kubernetes cluster |
| Package Manager | Helm | 3.x | Kubernetes application packaging |
| Database | PostgreSQL | Latest (bitnami) | Data persistence |
| Frontend | Next.js | Phase III version | Web UI |
| Backend | FastAPI | Phase III version | REST API + MCP server |
| AI Tools | kubectl-ai | v0.0.29 | Helm chart generation |
| AI Tools | Kagent | v0.7 | Cluster analysis |
| AI Tools | Gordon | Beta (post-4.50.0) | Docker operations |

## Implementation Phases

1. **Phase 0: Containerization Verification** - Verify Docker images exist and work standalone
2. **Phase 1: Minikube Setup** - Initialize cluster with proper resources and addons
3. **Phase 2: Database Deployment** - Deploy PostgreSQL with persistent storage and schema
4. **Phase 3: Backend Deployment** - Deploy FastAPI backend with MCP server
5. **Phase 4: Frontend Deployment** - Deploy Next.js frontend with LoadBalancer
6. **Phase 5: Integration & Verification** - Test end-to-end workflows
7. **Phase 6: AI-Assisted Operations** - Use Kagent for optimization and troubleshooting

## References

- Kubernetes Documentation: https://kubernetes.io/docs/
- Helm Documentation: https://helm.sh/docs/
- Minikube Documentation: https://minikube.sigs.k8s.io/docs/
- Bitnami PostgreSQL Chart: https://github.com/bitnami/charts/tree/main/bitnami/postgresql
- kubectl-ai Repository: https://github.com/sozercan/kubectl-ai
- Kagent Documentation: https://github.com/kubetoolsio/kagent
- Kubernetes Best Practices: https://kubernetes.io/docs/concepts/configuration/overview/
