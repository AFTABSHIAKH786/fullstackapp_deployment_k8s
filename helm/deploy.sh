#!/bin/bash

# UserApp Helm Chart Deployment Script
# This script helps deploy the UserApp using Helm

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
RELEASE_NAME="userapp"
NAMESPACE="userapp"
VALUES_FILE=""
ENVIRONMENT="default"

# Function to print colored output
print_status() {
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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] COMMAND"
    echo ""
    echo "Commands:"
    echo "  install     Install the UserApp"
    echo "  upgrade     Upgrade the UserApp"
    echo "  uninstall   Uninstall the UserApp"
    echo "  status      Show status of the UserApp"
    echo "  logs        Show logs of the UserApp"
    echo "  test        Test the Helm chart"
    echo ""
    echo "Options:"
    echo "  -n, --namespace NAME    Kubernetes namespace (default: userapp)"
    echo "  -r, --release NAME      Helm release name (default: userapp)"
    echo "  -f, --values FILE       Values file to use"
    echo "  -e, --environment ENV   Environment (dev, staging, prod)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install -e dev"
    echo "  $0 install -f values-production.yaml"
    echo "  $0 upgrade -e prod"
    echo "  $0 status"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if kubectl is installed
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    
    # Check if helm is installed
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    
    # Check if we can connect to Kubernetes cluster
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to determine values file based on environment
get_values_file() {
    if [[ -n "$VALUES_FILE" ]]; then
        echo "$VALUES_FILE"
    elif [[ "$ENVIRONMENT" == "dev" ]]; then
        echo "values-development.yaml"
    elif [[ "$ENVIRONMENT" == "prod" ]]; then
        echo "values-production.yaml"
    else
        echo "values.yaml"
    fi
}

# Function to install the application
install_app() {
    print_status "Installing UserApp..."
    
    VALUES_FILE_PATH=$(get_values_file)
    
    if [[ ! -f "$VALUES_FILE_PATH" ]]; then
        print_error "Values file $VALUES_FILE_PATH not found"
        exit 1
    fi
    
    # Create namespace if it doesn't exist
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_status "Creating namespace $NAMESPACE..."
        kubectl create namespace "$NAMESPACE"
    fi
    
    # Install the chart
    print_status "Installing Helm chart with values file: $VALUES_FILE_PATH"
    helm install "$RELEASE_NAME" . \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE_PATH" \
        --wait \
        --timeout 10m
    
    print_success "UserApp installed successfully!"
    print_status "Release name: $RELEASE_NAME"
    print_status "Namespace: $NAMESPACE"
    
    # Show status
    show_status
}

# Function to upgrade the application
upgrade_app() {
    print_status "Upgrading UserApp..."
    
    VALUES_FILE_PATH=$(get_values_file)
    
    if [[ ! -f "$VALUES_FILE_PATH" ]]; then
        print_error "Values file $VALUES_FILE_PATH not found"
        exit 1
    fi
    
    # Upgrade the chart
    print_status "Upgrading Helm chart with values file: $VALUES_FILE_PATH"
    helm upgrade "$RELEASE_NAME" . \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE_PATH" \
        --wait \
        --timeout 10m
    
    print_success "UserApp upgraded successfully!"
    
    # Show status
    show_status
}

# Function to uninstall the application
uninstall_app() {
    print_warning "Uninstalling UserApp..."
    
    # Uninstall the chart
    helm uninstall "$RELEASE_NAME" --namespace "$NAMESPACE"
    
    print_success "UserApp uninstalled successfully!"
    
    # Ask if user wants to delete namespace
    read -p "Do you want to delete the namespace $NAMESPACE? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete namespace "$NAMESPACE"
        print_success "Namespace $NAMESPACE deleted"
    fi
}

# Function to show status
show_status() {
    print_status "Checking UserApp status..."
    
    echo ""
    echo "=== Helm Release Status ==="
    helm status "$RELEASE_NAME" --namespace "$NAMESPACE"
    
    echo ""
    echo "=== Pod Status ==="
    kubectl get pods --namespace "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    echo ""
    echo "=== Service Status ==="
    kubectl get services --namespace "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME"
    
    echo ""
    echo "=== Ingress Status ==="
    kubectl get ingress --namespace "$NAMESPACE" -l "app.kubernetes.io/instance=$RELEASE_NAME" 2>/dev/null || echo "No ingress found"
}

# Function to show logs
show_logs() {
    print_status "Showing UserApp logs..."
    
    echo ""
    echo "=== Frontend Logs ==="
    kubectl logs --namespace "$NAMESPACE" -l "app.kubernetes.io/name=userapp-frontend,app.kubernetes.io/instance=$RELEASE_NAME" --tail=50 || echo "No frontend logs found"
    
    echo ""
    echo "=== Backend Logs ==="
    kubectl logs --namespace "$NAMESPACE" -l "app.kubernetes.io/name=userapp-backend,app.kubernetes.io/instance=$RELEASE_NAME" --tail=50 || echo "No backend logs found"
    
    echo ""
    echo "=== PostgreSQL Logs ==="
    kubectl logs --namespace "$NAMESPACE" -l "app.kubernetes.io/name=userapp-postgres,app.kubernetes.io/instance=$RELEASE_NAME" --tail=50 || echo "No postgres logs found"
}

# Function to test the chart
test_chart() {
    print_status "Testing Helm chart..."
    
    # Lint the chart
    print_status "Linting chart..."
    helm lint .
    
    # Template the chart
    print_status "Templating chart..."
    helm template "$RELEASE_NAME" . --values "$(get_values_file)" > /tmp/userapp-template.yaml
    
    print_success "Chart test completed successfully!"
    print_status "Template saved to /tmp/userapp-template.yaml"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        install|upgrade|uninstall|status|logs|test)
            COMMAND="$1"
            shift
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -f|--values)
            VALUES_FILE="$2"
            shift 2
            ;;
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Check if command is provided
if [[ -z "$COMMAND" ]]; then
    print_error "No command specified"
    show_usage
    exit 1
fi

# Execute command
case "$COMMAND" in
    install)
        check_prerequisites
        install_app
        ;;
    upgrade)
        check_prerequisites
        upgrade_app
        ;;
    uninstall)
        check_prerequisites
        uninstall_app
        ;;
    status)
        check_prerequisites
        show_status
        ;;
    logs)
        check_prerequisites
        show_logs
        ;;
    test)
        test_chart
        ;;
    *)
        print_error "Unknown command: $COMMAND"
        show_usage
        exit 1
        ;;
esac 