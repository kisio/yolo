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
