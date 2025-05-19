# YOLO E-commerce Application

A containerized full-stack e-commerce application built with React, Node.js, and MongoDB, deployed using Kubernetes on Google Kubernetes Engine (GKE).

## Features

- Product management (Add, View products)
- MongoDB persistence with StatefulSets
- Containerized microservices architecture
- Secure container configuration with non-root users
- Kubernetes orchestration with GKE
- Persistent storage for database data

## Prerequisites

- Google Cloud Platform account with GKE enabled
- Google Cloud SDK (gcloud CLI)
- kubectl command-line tool
- Git

## Quick Start with Google Kubernetes Engine (GKE)

1. Clone the repository:
```bash
git clone https://github.com/kisio/yolo.git
cd yolo
```

2. Update the GKE project details in the deployment script:
```bash
vim k8s/deploy-to-gke.sh
# Update PROJECT_ID, CLUSTER_NAME, and ZONE variables
```

3. Make the deployment script executable and run it:
```bash
chmod +x k8s/deploy-to-gke.sh
./k8s/deploy-to-gke.sh
```

4. Access the application:
- The script will output the LoadBalancer IP addresses for both frontend and backend services
- Frontend: http://<FRONTEND_IP>
- Backend API: http://<BACKEND_IP>:5000

5. To view the deployed resources:
```bash
kubectl get all -n yolo
```

6. To check MongoDB persistence (after adding items to cart):
```bash
# Delete the MongoDB pod
kubectl delete pod mongodb-0 -n yolo
# Verify that after the pod restarts, your cart items are still available
```

## Architecture

The application is deployed on Google Kubernetes Engine with the following architecture:

1. **Frontend (React)**
   - Deployed as a Kubernetes Deployment with 2 replicas
   - Exposed via LoadBalancer Service and Ingress
   - Container port 80

2. **Backend (Node.js/Express)**
   - Deployed as a Kubernetes Deployment with 2 replicas
   - Exposed via LoadBalancer Service and Ingress
   - Container port 5000
   - Configured with environment variables via ConfigMap

3. **Database (MongoDB)**
   - Deployed as a StatefulSet for data persistence
   - Uses PersistentVolumeClaims for storage
   - Exposed internally via ClusterIP and Headless Services
   - Container port 27017
   - Configured with secrets for authentication

All services are deployed in a dedicated Kubernetes namespace and communicate through Kubernetes Services. The MongoDB data is persisted using GKE's standard storage class.

## Kubernetes Manifest Structure

The deployment is orchestrated using Kubernetes manifests in the `k8s` directory:

1. **mongodb-statefulset.yaml**: Defines the MongoDB StatefulSet, Services, ConfigMap, and Secret
2. **backend-deployment.yaml**: Defines the Backend Deployment, Services, and ConfigMap
3. **frontend-deployment.yaml**: Defines the Frontend Deployment, Services, and ConfigMap
4. **ingress.yaml**: Defines the Ingress resource for external access
5. **deploy-to-gke.sh**: Script to automate deployment to GKE

For detailed explanation of the Kubernetes implementation choices, see [explanation.md](explanation.md).

## Kubernetes Resource Details

### Frontend Deployment:
- Image: `derrickselempo/yolo-client:v1.0.0`
- Replicas: 2
- Resource limits: 256Mi memory, 500m CPU
- Exposed via LoadBalancer Service (port 80)
- Health checks: Liveness and readiness probes

### Backend Deployment:
- Image: `derrickselempo/yolo-backend:v1.0.0`
- Replicas: 2
- Resource limits: 256Mi memory, 500m CPU
- Exposed via LoadBalancer Service (port 5000)
- Environment variables: MongoDB connection string via ConfigMap
- Health checks: Liveness and readiness probes

### MongoDB StatefulSet:
- Image: `mongo:4.4`
- Replicas: 1 (can be scaled for production)
- Resource limits: 512Mi memory, 500m CPU
- Persistent storage: 1Gi per pod using PersistentVolumeClaim
- Authentication: Username/password via Kubernetes Secret
- Exposed internally via Headless Service
- Health checks: Liveness and readiness probes using MongoDB commands

## API Endpoints

- GET /api/products: List all products
- POST /api/products: Add a product
- GET /api/products/:id: Get a specific product
- PUT /api/products/:id: Update a product
- DELETE /api/products/:id: Delete a product

## Development

To modify the application for Kubernetes deployment:

1. Make changes to the codebase
2. Rebuild Docker images if necessary
3. Push updated images to Docker Hub
4. Update Kubernetes manifests in the `k8s` directory
5. Apply changes with `kubectl apply -f k8s/<updated-file>.yaml`

## Troubleshooting

If you encounter issues with the Kubernetes deployment:

1. Check pod status and logs:
```bash
# Check pod status
kubectl get pods -n yolo

# View logs for a specific pod
kubectl logs <pod-name> -n yolo
```

2. Verify all resources are running:
```bash
kubectl get all -n yolo
```

3. Check persistent volume claims:
```bash
kubectl get pvc -n yolo
```

4. Describe resources for detailed information:
```bash
kubectl describe pod <pod-name> -n yolo
kubectl describe statefulset mongodb -n yolo
```

5. Check MongoDB connection from within the backend pod:
```bash
kubectl exec -it <backend-pod-name> -n yolo -- curl -v mongodb:27017
```

6. Access MongoDB shell for debugging:
```bash
kubectl exec -it mongodb-0 -n yolo -- mongo -u derrick -p derrickdevopstest --authenticationDatabase admin
```

## License

MIT
