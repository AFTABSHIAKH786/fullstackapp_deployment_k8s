# Helm Chart Structure

This document describes the structure of the UserApp Helm chart.

## Directory Structure

```
helm/
├── Chart.yaml                 # Chart metadata and version information
├── values.yaml               # Default configuration values
├── values-development.yaml   # Development environment values
├── values-production.yaml    # Production environment values
├── .helmignore              # Files to ignore when packaging
├── README.md                # Chart documentation
├── deploy.sh                # Deployment script
├── CHART_STRUCTURE.md       # This file
└── templates/               # Kubernetes manifest templates
    ├── _helpers.tpl         # Common template functions
    ├── namespace.yaml       # Namespace template
    ├── frontend-configmap.yaml
    ├── backend-configmap.yaml
    ├── postgres-configmap.yaml
    ├── postgres-secret.yaml
    ├── postgres-pvc.yaml
    ├── frontend-deployment.yaml
    ├── backend-deployment.yaml
    ├── postgres-deployment.yaml
    ├── frontend-service.yaml
    ├── backend-service.yaml
    ├── postgres-service.yaml
    ├── ingress.yaml
    └── NOTES.txt            # Post-installation notes
```

## Key Features

### 1. Modular Design
- Each component (frontend, backend, postgres) can be enabled/disabled independently
- Configurable resources, replicas, and settings for each component
- Environment-specific values files

### 2. Security
- Secrets management for database passwords
- ConfigMaps for non-sensitive configuration
- Proper RBAC labels and annotations

### 3. Scalability
- Configurable replica counts
- Resource limits and requests
- Horizontal Pod Autoscaler ready

### 4. Storage
- Configurable storage classes
- Persistent volume support for database
- Upload storage options (emptyDir or PVC)

### 5. Networking
- Configurable service types (ClusterIP, NodePort, LoadBalancer)
- Ingress support with TLS
- CORS configuration

## Usage Examples

### Development Deployment
```bash
# Using the deployment script
./deploy.sh install -e dev

# Or using Helm directly
helm install userapp-dev . -f values-development.yaml
```

### Production Deployment
```bash
# Using the deployment script
./deploy.sh install -e prod

# Or using Helm directly
helm install userapp-prod . -f values-production.yaml
```

### Custom Configuration
```bash
# Install with custom values
helm install userapp . --set frontend.replicaCount=3 --set backend.replicaCount=3

# Install with custom values file
helm install userapp . -f custom-values.yaml
```

## Configuration Options

### Global Settings
- `global.imageRegistry`: Global Docker registry prefix
- `global.imagePullSecrets`: Global image pull secrets
- `global.storageClass`: Global storage class

### Component Settings
Each component (frontend, backend, postgres) supports:
- `enabled`: Enable/disable the component
- `image.repository`: Docker image repository
- `image.tag`: Docker image tag
- `image.pullPolicy`: Image pull policy
- `replicaCount`: Number of replicas
- `resources`: CPU and memory limits/requests
- `service.type`: Service type (ClusterIP, NodePort, LoadBalancer)
- `service.port`: Service port

### Environment-Specific Configurations

#### Development (`values-development.yaml`)
- Single replica deployments
- NodePort services for easy access
- Disabled ingress
- EmptyDir storage for database
- Local image references

#### Production (`values-production.yaml`)
- Multiple replica deployments
- ClusterIP services with ingress
- Persistent storage for database
- Registry image references
- TLS configuration
- Higher resource limits

## Best Practices

1. **Version Management**: Always specify image tags, avoid using `latest`
2. **Resource Limits**: Set appropriate CPU and memory limits
3. **Security**: Use secrets for sensitive data, never hardcode passwords
4. **Monitoring**: Add appropriate labels and annotations for monitoring
5. **Backup**: Configure database backups for production
6. **Testing**: Use `helm lint` and `helm template` to validate charts

## Troubleshooting

### Common Issues

1. **Image Pull Errors**: Check image registry credentials and image names
2. **Storage Issues**: Verify storage class exists and has sufficient capacity
3. **Network Issues**: Check service and ingress configurations
4. **Resource Issues**: Monitor resource usage and adjust limits

### Debugging Commands

```bash
# Check chart syntax
helm lint .

# Generate templates
helm template userapp . > templates.yaml

# Check release status
helm status userapp

# View logs
kubectl logs -l app.kubernetes.io/instance=userapp

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

## Future Enhancements

1. **Monitoring**: Add Prometheus and Grafana configurations
2. **Logging**: Add centralized logging (ELK stack)
3. **Backup**: Add database backup configurations
4. **Security**: Add network policies and pod security policies
5. **CI/CD**: Add GitHub Actions or GitLab CI configurations
6. **Testing**: Add Helm chart testing framework 