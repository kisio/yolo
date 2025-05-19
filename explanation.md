# Docker Implementation Explanation

## 1. Base Image Selection
- **Frontend (React)**: Using `node:alpine` as base image to minimize size while providing necessary Node.js runtime
- **Backend (Node.js)**: Using `node:alpine` for minimal size with required functionality
- **Database**: Using official `mongo` image as it's optimized for production use

Rationale: Alpine-based images were chosen for the Node.js applications because they provide the smallest possible footprint while containing all necessary tools. This results in faster builds, smaller storage requirements, and reduced attack surface.

## 2. Dockerfile Directives
### Frontend Dockerfile
- `WORKDIR /app`: Sets working directory
- `COPY package*.json ./`: Copies package files first to leverage Docker cache
- `RUN npm install`: Installs dependencies
- `COPY . .`: Copies source code
- `EXPOSE 3000`: Documents the port
- `CMD ["npm", "start"]`: Runs the React development server

### Backend Dockerfile
- Similar structure to frontend but exposes port 5000
- Uses multi-stage build to keep final image small
- Separates dependency installation from code copying for better caching

## 3. Docker-compose Networking
- Created custom bridge network `app-net` for container communication
- Port mappings:
  - Frontend: 3000:3000
  - Backend: 5000:5000
  - MongoDB: 27017:27017
- Internal container communication uses service names as hostnames

## 4. Volume Configuration
- MongoDB data persistence using named volume `app-mongo-data`
- Volume mounted to `/data/db` in MongoDB container
- Ensures data survives container restarts/removals

## 5. Git Workflow
1. Initial setup and basic Dockerfile creation
2. Backend containerization
3. Frontend containerization
4. MongoDB integration
5. Network configuration
6. Volume setup for persistence
7. Docker-compose orchestration
8. Testing and debugging
9. Documentation
10. Final optimizations

## Best Practices Implemented
1. Used specific version tags for all images
2. Implemented health checks
3. Used multi-stage builds where beneficial
4. Minimized number of layers
5. Proper security considerations (no root users)
6. Clear documentation and comments

# Ansible Playbook Implementation Explanation

## Playbook Structure and Execution Order

The Ansible playbook is designed to provision a complete e-commerce application environment using Docker containers. The execution order is carefully planned to ensure dependencies are met before dependent services are deployed.

### 1. Docker Installation (First Role)
- **Role**: `docker-install`
- **Purpose**: Install Docker and its dependencies on the target machine
- **Execution Order**: Must run first as all subsequent roles depend on Docker
- **Key Tasks**:
  - Install Docker dependencies
  - Add Docker GPG key
  - Add Docker repository
  - Install Docker CE
  - Ensure Docker service is running
- **Ansible Modules Used**:
  - `apt`: For package management
  - `apt_key`: To add Docker's GPG key
  - `apt_repository`: To add Docker's repository
  - `service`: To ensure Docker is running

### 2. MongoDB Setup (Second Role)
- **Role**: `setup-mongodb`
- **Purpose**: Create Docker network and deploy MongoDB container
- **Execution Order**: Must run after Docker installation but before application containers
- **Key Tasks**:
  - Create Docker network for application components
  - Run MongoDB container with proper volume mounting
- **Ansible Modules Used**:
  - `docker_network`: To create the application network
  - `docker_container`: To run the MongoDB container
- **Variables Used**:
  - `mongo_image`: MongoDB Docker image
  - `mongo_container`: Container name
  - `mongo_port`: Port mapping
  - `app_network`: Network name
  - `mongo_volume`: Volume mapping for data persistence

### 3. Backend Deployment (Third Role)
- **Role**: `backend-deployment`
- **Purpose**: Deploy the Node.js backend API container
- **Execution Order**: Must run after MongoDB as it depends on the database
- **Key Tasks**:
  - Pull backend image from repository
  - Create backend container with proper network and environment variables
- **Ansible Modules Used**:
  - `docker_image`: To pull the backend image
  - `docker_container`: To run the backend container
- **Variables Used**:
  - `backend_image`: Backend Docker image
  - `backend_container`: Container name
  - `backend_port`: Port mapping
  - `app_network`: Network name
- **Environment Variables**:
  - `MONGODB_URI`: Connection string for MongoDB Atlas

### 4. Frontend Deployment (Fourth Role)
- **Role**: `frontend-deployment`
- **Purpose**: Deploy the React frontend container
- **Execution Order**: Runs after backend to ensure API is available
- **Key Tasks**:
  - Pull frontend image from repository
  - Create frontend container with proper network
- **Ansible Modules Used**:
  - `docker_image`: To pull the frontend image
  - `docker_container`: To run the frontend container
- **Variables Used**:
  - `frontend_image`: Frontend Docker image
  - `frontend_container`: Container name
  - `frontend_port`: Port mapping
  - `app_network`: Network name

### 5. Repository Cloning (Final Task)
- **Purpose**: Clone the application repository for reference
- **Execution Order**: Runs last as it's not critical for application functionality
- **Ansible Modules Used**:
  - `git`: To clone the repository

## Variable Management

Variables are centralized in `vars/main.yml` for easy maintenance and configuration:

- **Docker Images**: Configurable image names and versions
- **Container Names**: Consistent naming for all containers
- **Network Configuration**: Network name and port mappings
- **Volume Configuration**: MongoDB data persistence

## Tags Implementation

Tags are used throughout the playbook to allow selective execution:

- `docker`: For Docker installation tasks
- `mongodb`: For MongoDB setup tasks
- `backend`: For backend deployment tasks
- `frontend`: For frontend deployment tasks
- `app`: For all application-related tasks

## Best Practices Implemented

1. **Role-Based Organization**: Separating concerns into distinct roles
2. **Variable Centralization**: Using a central variable file
3. **Dependency Management**: Proper execution order
4. **Idempotence**: Ensuring playbook can be run multiple times safely
5. **Environment Variable Management**: Secure handling of connection strings
6. **Network Isolation**: Using a dedicated Docker network
7. **Data Persistence**: Volume mounting for MongoDB data

# Kubernetes Implementation Explanation

## 1. Choice of Kubernetes Objects Used for Deployment

### MongoDB StatefulSet Implementation
I chose to implement MongoDB using a StatefulSet rather than a Deployment for the following reasons:

- **Stable Network Identities**: StatefulSets provide stable, unique network identifiers (mongodb-0, mongodb-1, etc.) which are critical for database clustering and replication.
- **Ordered Deployment and Scaling**: StatefulSets guarantee ordered deployment, scaling, and deletion, which is essential for database operations to prevent data corruption.
- **Stable Persistent Storage**: Each Pod in a StatefulSet has its own persistent volume claim that remains associated with it even if the Pod is rescheduled, ensuring data persistence.
- **Predictable Pod Names**: StatefulSets maintain a predictable naming pattern, making it easier to identify and manage database instances.

The MongoDB StatefulSet is configured with:
- A headless service (`mongodb-headless`) for direct Pod addressing
- PersistentVolumeClaims using the `volumeClaimTemplates` feature
- Proper liveness and readiness probes to ensure database health

### Backend and Frontend Deployments
For the application tiers (backend and frontend), I chose to use Deployments because:

- **Stateless Nature**: These components are stateless and don't require stable network identities or ordered deployment.
- **Rolling Updates**: Deployments support rolling updates and rollbacks, which are ideal for application code changes.
- **Horizontal Scaling**: Deployments make it easy to scale the number of replicas based on load.
- **Self-healing**: Deployments automatically replace failed Pods, ensuring application availability.

Both Deployments are configured with:
- Multiple replicas for high availability
- Resource limits and requests for proper cluster resource allocation
- Health probes to ensure application responsiveness
- ConfigMaps for environment-specific configuration

## 2. Method Used to Expose Pods to Internet Traffic

I implemented a multi-layered approach to expose the application to internet traffic:

### Internal Service Layer
- **ClusterIP Services**: Created for internal communication between components (backend to MongoDB)
- **Headless Service**: For StatefulSet stable network identity

### External Access Layer
- **LoadBalancer Services**: For direct external access to both frontend and backend
  - This provides dedicated external IPs for each service
  - Simplifies debugging and testing during development
  - Allows for independent scaling of ingress resources

### Ingress Resource
- Implemented an Ingress controller to provide HTTP routing
- Path-based routing to direct traffic to appropriate services:
  - `/api/*` routes to the backend service
  - `/*` routes to the frontend service
- This provides a single entry point with intelligent routing

This approach offers flexibility in how the application is accessed:
- Direct access to individual services via LoadBalancer IPs
- Unified access through the Ingress for a production-like experience

## 3. Use of Persistent Storage

### Implementation of Persistent Storage
I implemented persistent storage for MongoDB using:

- **StatefulSet volumeClaimTemplates**: This feature automatically creates PersistentVolumeClaims for each Pod in the StatefulSet
- **ReadWriteOnce Access Mode**: Appropriate for database workloads where a single node needs write access
- **Standard Storage Class**: Using GKE's default storage class for dynamic provisioning
- **1Gi Storage Size**: Allocated sufficient space for the application data while being mindful of cloud resource costs

### Benefits of the Implemented Storage Solution
- **Data Persistence**: MongoDB data survives Pod restarts, rescheduling, and even node failures
- **Pod Identity Preservation**: If a Pod is rescheduled, it reconnects to the same persistent volume
- **Independent Storage Scaling**: Storage can be resized independently of compute resources
- **Automatic Provisioning**: The storage is dynamically provisioned by GKE, reducing operational overhead

The implementation ensures that when a MongoDB Pod is deleted, the data remains intact, and when the Pod is recreated, it reattaches to the same persistent volume. This guarantees that items added to the cart will persist across Pod restarts or rescheduling events.

## 4. Git Workflow Used to Achieve the Task

For this Kubernetes implementation, I followed a structured Git workflow:

1. **Feature Branch Creation**: Created a new branch `feature/k8s-deployment` from main
2. **Component-wise Implementation**:
   - Started with the database layer (MongoDB StatefulSet)
   - Followed by the backend service
   - Then the frontend service
   - Finally, the ingress configuration
3. **Iterative Testing**: Committed changes after testing each component
4. **Documentation**: Added detailed comments in YAML files and updated explanation.md
5. **Pull Request**: Created a PR with the complete implementation for review
6. **Merge to Main**: After review and testing, merged to the main branch

This workflow ensured:
- Isolation of changes during development
- Incremental testing of each component
- Clear documentation of implementation decisions
- Proper review before production deployment

## 5. Best Practices Implemented

- **Resource Limits and Requests**: Specified for all containers to ensure proper scheduling and prevent resource starvation
- **Health Probes**: Implemented liveness and readiness probes for all services
- **ConfigMaps and Secrets**: Used for configuration and sensitive data
- **Non-root Users**: Containers run as non-root users for security
- **StatefulSet for Databases**: Used appropriate controller types for each workload
- **Headless Services**: Implemented for StatefulSets to provide stable network identities
- **Ingress for Unified Access**: Simplified external access pattern
- **Descriptive Labels and Annotations**: Used throughout for better organization and filtering
- **Namespace Isolation**: Deployed all resources to a dedicated namespace for better organization
- **Consistent Naming Convention**: Applied throughout all resources for clarity
