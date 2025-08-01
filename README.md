# Full Stack User Management Application

A modern full-stack application built with React, Node.js, and PostgreSQL for managing users with profile images.

## Features

- ✅ User registration with name, age, and profile image
- ✅ Image upload and storage
- ✅ User listing with profile images
- ✅ User deletion
- ✅ Responsive design
- ✅ Docker containerization
- ✅ Kubernetes deployment ready
- ✅ Health checks and monitoring

## Tech Stack

### Frontend
- **React 18** - Modern React with hooks
- **Axios** - HTTP client for API calls
- **CSS3** - Modern styling with animations

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **Multer** - File upload handling
- **PostgreSQL** - Database
- **pg** - PostgreSQL client

### Infrastructure
- **Docker** - Containerization
- **Docker Compose** - Multi-container orchestration
- **Kubernetes** - Container orchestration
- **Nginx** - Web server (frontend)

## Project Structure

```
full_stack_app_deployment/
├── backend/                 # Node.js API server
│   ├── server.js           # Main server file
│   ├── package.json        # Backend dependencies
│   ├── Dockerfile          # Backend container
│   └── uploads/            # Image storage directory
├── frontend/               # React application
│   ├── src/               # React source code
│   ├── public/            # Static files
│   ├── package.json       # Frontend dependencies
│   ├── Dockerfile         # Frontend container
│   └── nginx.conf         # Nginx configuration
├── k8s/                   # Kubernetes manifests
│   ├── namespace.yaml     # Application namespace
│   ├── postgres-*.yaml    # Database resources
│   ├── backend-*.yaml     # Backend resources
│   ├── frontend-*.yaml    # Frontend resources
│   └── ingress.yaml       # Ingress configuration
├── docker-compose.yml     # Local development setup
├── package.json           # Root package.json
└── README.md             # This file
```

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Docker and Docker Compose
- PostgreSQL (for local development without Docker)

### Local Development

1. **Clone and install dependencies:**
   ```bash
   git clone <repository-url>
   cd full_stack_app_deployment
   npm run install-all
   ```

2. **Set up environment variables:**
   ```bash
   # Copy backend environment file
   cp backend/env.example backend/.env
   
   # Edit backend/.env with your database credentials
   ```

3. **Start PostgreSQL database:**
   ```bash
   # Option 1: Using Docker
   docker run -d --name postgres \
     -e POSTGRES_DB=userdb \
     -e POSTGRES_USER=postgres \
     -e POSTGRES_PASSWORD=password \
     -p 5432:5432 \
     postgres:15-alpine

   # Option 2: Local PostgreSQL installation
   # Create database 'userdb' and user 'postgres'
   ```

4. **Start the application:**
   ```bash
   # Start both frontend and backend
   npm run dev
   
   # Or start individually
   npm run server  # Backend on http://localhost:5000
   npm run client  # Frontend on http://localhost:3000
   ```

### Docker Development

1. **Build and start all services:**
   ```bash
   npm run docker-build
   npm run docker-up
   ```

2. **Access the application:**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:5000
   - Database: localhost:5432

3. **Stop services:**
   ```bash
   npm run docker-down
   ```

## Kubernetes Deployment

### Prerequisites

- Kubernetes cluster (Minikube, Docker Desktop, or cloud provider)
- kubectl CLI tool
- Docker images built and available

### Deploy to Kubernetes

1. **Build Docker images:**
   ```bash
   # Build backend image
   docker build -t userapp-backend:latest ./backend
   
   # Build frontend image
   docker build -t userapp-frontend:latest ./frontend
   ```

2. **Load images to cluster (if using Minikube):**
   ```bash
   minikube image load userapp-backend:latest
   minikube image load userapp-frontend:latest
   ```

3. **Deploy the application:**
   ```bash
   # Create namespace
   kubectl apply -f k8s/namespace.yaml
   
   # Deploy database
   kubectl apply -f k8s/postgres-configmap.yaml
   kubectl apply -f k8s/postgres-secret.yaml
   kubectl apply -f k8s/postgres-pvc.yaml
   kubectl apply -f k8s/postgres-deployment.yaml
   kubectl apply -f k8s/postgres-service.yaml
   
   # Deploy backend
   kubectl apply -f k8s/backend-configmap.yaml
   kubectl apply -f k8s/backend-deployment.yaml
   kubectl apply -f k8s/backend-service.yaml
   
   # Deploy frontend
   kubectl apply -f k8s/frontend-configmap.yaml
   kubectl apply -f k8s/frontend-deployment.yaml
   kubectl apply -f k8s/frontend-service.yaml
   
   # Deploy ingress (if available)
   kubectl apply -f k8s/ingress.yaml
   ```

4. **Access the application:**
   ```bash
   # Port forward to access services
   kubectl port-forward -n userapp svc/frontend-service 3000:3000
   kubectl port-forward -n userapp svc/backend-service 5000:5000
   
   # Or access via ingress (if configured)
   # Add userapp.local to your /etc/hosts file
   ```

5. **Check deployment status:**
   ```bash
   kubectl get all -n userapp
   kubectl get pods -n userapp
   kubectl logs -n userapp deployment/backend
   kubectl logs -n userapp deployment/frontend
   ```

### Cleanup

```bash
# Delete all resources
kubectl delete namespace userapp

# Or delete individually
kubectl delete -f k8s/
```

## API Endpoints

### Backend API (http://localhost:5000)

- `GET /api/health` - Health check
- `GET /api/users` - Get all users
- `POST /api/users` - Create new user (multipart form data)
- `DELETE /api/users/:id` - Delete user by ID
- `GET /uploads/:filename` - Serve uploaded images

### Request/Response Examples

**Create User:**
```bash
curl -X POST http://localhost:5000/api/users \
  -F "name=John Doe" \
  -F "age=30" \
  -F "image=@/path/to/image.jpg"
```

**Get Users:**
```bash
curl http://localhost:5000/api/users
```

## Environment Variables

### Backend (.env)
```env
DB_USER=postgres
DB_HOST=localhost
DB_NAME=userdb
DB_PASSWORD=password
DB_PORT=5432
PORT=5000
```

### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:5000
```

## Development Scripts

```bash
# Install all dependencies
npm run install-all

# Start development servers
npm run dev

# Start individual services
npm run server
npm run client

# Build frontend
npm run build

# Docker commands
npm run docker-build
npm run docker-up
npm run docker-down
```

## Troubleshooting

### Common Issues

1. **Database connection failed:**
   - Check if PostgreSQL is running
   - Verify database credentials in `.env`
   - Ensure database and user exist

2. **Image upload fails:**
   - Check if `uploads` directory exists
   - Verify file size (max 5MB)
   - Ensure file type is supported (JPG, PNG, GIF)

3. **Kubernetes pods not starting:**
   - Check pod logs: `kubectl logs -n userapp <pod-name>`
   - Verify image names and tags
   - Check resource limits and requests

4. **CORS errors:**
   - Ensure backend CORS is configured
   - Check API URL in frontend configuration

### Logs and Debugging

```bash
# Backend logs
kubectl logs -n userapp deployment/backend

# Frontend logs
kubectl logs -n userapp deployment/frontend

# Database logs
kubectl logs -n userapp deployment/postgres

# Check pod status
kubectl describe pod -n userapp <pod-name>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

MIT License - see LICENSE file for details 