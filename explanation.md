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
