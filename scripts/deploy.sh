#!/bin/bash

# Full Stack App Kubernetes Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="userapp"
BACKEND_IMAGE="userapp-backend:latest"
FRONTEND_IMAGE="userapp-frontend:latest"

echo -e "${BLUE}🚀 Starting Full Stack App Deployment${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

print_status "Prerequisites check passed"

# Build Docker images
print_status "Building Docker images..."

echo "Building backend image..."
docker build -t $BACKEND_IMAGE ./backend

echo "Building frontend image..."
docker build -t $FRONTEND_IMAGE ./frontend

print_status "Docker images built successfully"

# Load images to cluster (for Minikube)
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
    print_status "Loading images to Minikube cluster..."
    minikube image load $BACKEND_IMAGE
    minikube image load $FRONTEND_IMAGE
    print_status "Images loaded to Minikube"
fi

# Create namespace
print_status "Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Deploy PostgreSQL
print_status "Deploying PostgreSQL database..."
kubectl apply -f k8s/postgres-configmap.yaml
kubectl apply -f k8s/postgres-secret.yaml
kubectl apply -f k8s/postgres-pvc.yaml
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/postgres-service.yaml

# Wait for PostgreSQL to be ready
print_status "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s

# Deploy Backend
print_status "Deploying backend API..."
kubectl apply -f k8s/backend-configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

# Wait for backend to be ready
print_status "Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend -n $NAMESPACE --timeout=300s

# Deploy Frontend
print_status "Deploying frontend application..."
kubectl apply -f k8s/frontend-configmap.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Wait for frontend to be ready
print_status "Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n $NAMESPACE --timeout=300s

# Deploy Ingress (if available)
if kubectl get ingressclass &> /dev/null; then
    print_status "Deploying ingress..."
    kubectl apply -f k8s/ingress.yaml
else
    print_warning "No ingress controller found. Skipping ingress deployment."
fi

# Show deployment status
print_status "Deployment completed! Checking status..."

echo ""
echo -e "${BLUE}📊 Deployment Status:${NC}"
kubectl get all -n $NAMESPACE

echo ""
echo -e "${BLUE}🔍 Pod Status:${NC}"
kubectl get pods -n $NAMESPACE

echo ""
echo -e "${BLUE}🌐 Services:${NC}"
kubectl get svc -n $NAMESPACE

# Show access information
echo ""
echo -e "${GREEN}🎉 Deployment successful!${NC}"
echo ""
echo -e "${BLUE}📱 Access Information:${NC}"
echo "To access the application, you can:"
echo ""
echo "1. Port forward the services:"
echo "   kubectl port-forward -n $NAMESPACE svc/frontend-service 3000:3000"
echo "   kubectl port-forward -n $NAMESPACE svc/backend-service 5000:5000"
echo ""
echo "2. Then open your browser to:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:5000"
echo ""
echo "3. Or check if ingress is available:"
echo "   kubectl get ingress -n $NAMESPACE"
echo ""
echo -e "${YELLOW}💡 Useful commands:${NC}"
echo "   kubectl logs -n $NAMESPACE deployment/backend"
echo "   kubectl logs -n $NAMESPACE deployment/frontend"
echo "   kubectl describe pod -n $NAMESPACE <pod-name>"
echo ""
echo -e "${YELLOW}🧹 To cleanup:${NC}"
echo "   kubectl delete namespace $NAMESPACE" 