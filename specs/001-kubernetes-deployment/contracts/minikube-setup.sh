#!/bin/bash
# Minikube Setup Script for Todo Chatbot Kubernetes Deployment
# This script initializes a Minikube cluster with proper configuration

set -e  # Exit on error
set -u  # Exit on undefined variable

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="todo-chatbot"
CPUS=4
MEMORY=8192  # MB
DRIVER="docker"  # or "virtualbox", "hyperkit", etc.

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_info "Checking prerequisites..."

if ! command_exists minikube; then
    print_error "Minikube is not installed. Please install it first."
    print_info "Visit: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

if ! command_exists kubectl; then
    print_error "kubectl is not installed. Please install it first."
    print_info "Visit: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

if ! command_exists helm; then
    print_error "Helm is not installed. Please install it first."
    print_info "Visit: https://helm.sh/docs/intro/install/"
    exit 1
fi

if ! command_exists docker; then
    print_error "Docker is not installed. Please install it first."
    print_info "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

print_success "All prerequisites are installed"

# Check if Minikube is already running
if minikube status --profile="$CLUSTER_NAME" >/dev/null 2>&1; then
    print_warning "Minikube cluster '$CLUSTER_NAME' is already running"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deleting existing cluster..."
        minikube delete --profile="$CLUSTER_NAME"
    else
        print_info "Using existing cluster"
        exit 0
    fi
fi

# Start Minikube cluster
print_info "Starting Minikube cluster with $CPUS CPUs and ${MEMORY}MB memory..."
minikube start \
    --profile="$CLUSTER_NAME" \
    --cpus="$CPUS" \
    --memory="$MEMORY" \
    --driver="$DRIVER" \
    --kubernetes-version=stable

print_success "Minikube cluster started successfully"

# Enable required addons
print_info "Enabling required addons..."

print_info "Enabling ingress addon..."
minikube addons enable ingress --profile="$CLUSTER_NAME"

print_info "Enabling metrics-server addon..."
minikube addons enable metrics-server --profile="$CLUSTER_NAME"

print_success "Addons enabled successfully"

# Wait for cluster to be ready
print_info "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

print_success "Cluster is ready"

# Display cluster information
print_info "Cluster Information:"
echo "-----------------------------------"
minikube profile list
echo "-----------------------------------"
kubectl cluster-info
echo "-----------------------------------"
kubectl get nodes
echo "-----------------------------------"

# Set kubectl context
print_info "Setting kubectl context to '$CLUSTER_NAME'..."
kubectl config use-context "$CLUSTER_NAME"

print_success "kubectl context set to '$CLUSTER_NAME'"

# Display Docker environment info
print_info "Docker Environment:"
echo "-----------------------------------"
echo "To use local Docker images in Minikube, run:"
echo "  eval \$(minikube docker-env --profile=$CLUSTER_NAME)"
echo ""
echo "Or on Windows PowerShell:"
echo "  & minikube -p $CLUSTER_NAME docker-env --shell powershell | Invoke-Expression"
echo "-----------------------------------"

# Display next steps
print_success "Minikube setup complete!"
echo ""
print_info "Next Steps:"
echo "  1. Verify Docker images are available:"
echo "     docker images | grep todo"
echo ""
echo "  2. Deploy the application:"
echo "     ./scripts/deploy-all.sh"
echo ""
echo "  3. Start minikube tunnel (in a separate terminal):"
echo "     minikube tunnel --profile=$CLUSTER_NAME"
echo ""
echo "  4. Access the application:"
echo "     kubectl get svc todo-frontend -n todo-chatbot"
echo ""
print_info "To stop the cluster:"
echo "  minikube stop --profile=$CLUSTER_NAME"
echo ""
print_info "To delete the cluster:"
echo "  minikube delete --profile=$CLUSTER_NAME"
