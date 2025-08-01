# UserApp Helm Chart

A Helm chart for deploying the full-stack UserApp application on Kubernetes.

## Overview

This Helm chart deploys a complete full-stack application consisting of:

- **Frontend**: React application served by Nginx
- **Backend**: Node.js API server
- **Database**: PostgreSQL database
- **Ingress**: Nginx ingress controller for external access

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Nginx Ingress Controller (if using ingress)
- Storage class (for persistent volumes)

## Installation

### Quick Start

```bash
# Add the chart repository (if using a repository)
helm repo add userapp https://your-repo.com/charts

# Install the chart with default values
helm install userapp ./helm

# Install with custom values file
helm install userapp ./helm -f values-production.yaml

# Install in a specific namespace
helm install userapp ./helm --namespace userapp --create-namespace
```

### Development Installation

```bash
# Install for development with NodePort services
helm install userapp-dev ./helm -f values-development.yaml
```

### Production Installation

```bash
# Install for production with proper ingress and TLS
helm install userapp-prod ./helm -f values-production.yaml
```

## Configuration

The following table lists the configurable parameters of the userapp chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `""` |
| `global.imagePullSecrets` | Global Docker registry secret names | `[]` |
| `namespace.create` | Create a new namespace | `true` |
| `namespace.name` | Name of the namespace | `userapp` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | `[]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |
| `frontend.enabled` | Enable frontend deployment | `true` |
| `frontend.image.repository` | Frontend image repository | `userapp-frontend` |
| `frontend.image.tag` | Frontend image tag | `latest` |
| `frontend.image.pullPolicy` | Frontend image pull policy | `Never` |
| `frontend.replicaCount` | Number of frontend replicas | `2` |
| `frontend.service.type` | Frontend service type | `ClusterIP` |
| `frontend.service.port` | Frontend service port | `3000` |
| `frontend.resources` | Frontend resource limits/requests | `{}` |
| `frontend.config` | Frontend environment variables | `{}` |
| `backend.enabled` | Enable backend deployment | `true` |
| `backend.image.repository` | Backend image repository | `userapp-backend` |
| `backend.image.tag` | Backend image tag | `latest` |
| `backend.image.pullPolicy` | Backend image pull policy | `Never` |
| `backend.replicaCount` | Number of backend replicas | `2` |
| `backend.service.type` | Backend service type | `ClusterIP` |
| `backend.service.port` | Backend service port | `5000` |
| `backend.resources` | Backend resource limits/requests | `{}` |
| `backend.config` | Backend environment variables | `{}` |
| `backend.uploads.storage.type` | Backend uploads storage type | `emptyDir` |
| `postgres.enabled` | Enable PostgreSQL deployment | `true` |
| `postgres.image.repository` | PostgreSQL image repository | `postgres` |
| `postgres.image.tag` | PostgreSQL image tag | `15-alpine` |
| `postgres.image.pullPolicy` | PostgreSQL image pull policy | `IfNotPresent` |
| `postgres.replicaCount` | Number of PostgreSQL replicas | `1` |
| `postgres.service.type` | PostgreSQL service type | `ClusterIP` |
| `postgres.service.port` | PostgreSQL service port | `5432` |
| `postgres.resources` | PostgreSQL resource limits/requests | `{}` |
| `postgres.config` | PostgreSQL environment variables | `{}` |
| `postgres.secret` | PostgreSQL secrets | `{}` |
| `postgres.persistence.enabled` | Enable PostgreSQL persistence | `true` |
| `postgres.persistence.storageClass` | PostgreSQL storage class | `""` |
| `postgres.persistence.size` | PostgreSQL storage size | `8Gi` |
| `postgres.persistence.accessMode` | PostgreSQL access mode | `ReadWriteOnce` |

## Usage

### Accessing the Application

After installation, you can access the application using the following methods:

#### With Ingress (Production)
```bash
# Get the ingress host
kubectl get ingress -n userapp

# Access via the configured host
curl http://your-app.com
```

#### With NodePort (Development)
```bash
# Get the NodePort for frontend
kubectl get svc -n userapp userapp-frontend-service

# Access via NodePort
curl http://<node-ip>:<nodeport>
```

#### With Port Forwarding
```bash
# Port forward to frontend
kubectl port-forward -n userapp svc/userapp-frontend-service 8080:3000

# Port forward to backend
kubectl port-forward -n userapp svc/userapp-backend-service 5000:5000

# Access locally
curl http://localhost:8080
curl http://localhost:5000/api/health
```

### Scaling

```bash
# Scale frontend replicas
kubectl scale deployment userapp-frontend -n userapp --replicas=3

# Scale backend replicas
kubectl scale deployment userapp-backend -n userapp --replicas=3
```

### Updating the Application

```bash
# Update with new values
helm upgrade userapp ./helm -f values-production.yaml

# Rollback to previous version
helm rollback userapp 1
```

### Uninstalling

```bash
# Uninstall the release
helm uninstall userapp

# Delete the namespace (if created by the chart)
kubectl delete namespace userapp
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n userapp
kubectl describe pod <pod-name> -n userapp
```

### Check Logs
```bash
# Frontend logs
kubectl logs -n userapp -l app.kubernetes.io/name=userapp-frontend

# Backend logs
kubectl logs -n userapp -l app.kubernetes.io/name=userapp-backend

# PostgreSQL logs
kubectl logs -n userapp -l app.kubernetes.io/name=userapp-postgres
```

### Check Services
```bash
kubectl get svc -n userapp
kubectl describe svc <service-name> -n userapp
```

### Check Ingress
```bash
kubectl get ingress -n userapp
kubectl describe ingress <ingress-name> -n userapp
```

## Security Considerations

1. **Secrets**: Always use Kubernetes secrets for sensitive data like database passwords
2. **Network Policies**: Consider implementing network policies to restrict pod-to-pod communication
3. **RBAC**: Use appropriate RBAC roles and service accounts
4. **TLS**: Enable TLS for production deployments
5. **Image Security**: Use signed images and scan for vulnerabilities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the chart
5. Submit a pull request

## License

This project is licensed under the MIT License. 