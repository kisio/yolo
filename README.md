# YOLO E-commerce Application

A containerized full-stack e-commerce application built with React, Node.js, and MongoDB, deployed using Ansible and Vagrant.

## Features

- Product management (Add, View products)
- MongoDB persistence
- Containerized microservices architecture
- Secure container configuration with non-root users
- Automated deployment with Ansible
- Virtualized environment with Vagrant

## Prerequisites

- Vagrant (2.2.x or higher)
- VirtualBox (6.1.x or higher)
- Ansible (2.9.x or higher)
- Git

## Quick Start with Ansible and Vagrant

1. Clone the repository:
```bash
git clone https://github.com/kisio/yolo.git
cd yolo
```

2. Start the Vagrant VM and provision with Ansible:
```bash
vagrant up
```

3. Access the application:
- Frontend: http://localhost:8080
- Backend API: http://localhost:5000
- MongoDB: localhost:27017

4. To re-provision the VM (if needed):
```bash
vagrant provision
```

5. To SSH into the VM:
```bash
vagrant ssh
```

## Architecture

The application consists of three microservices:
1. Frontend (React) - Port 80 (mapped to 8080 on host)
2. Backend (Node.js/Express) - Port 5000
3. Database (MongoDB) - Port 27017

All services are connected through a custom bridge network and use Docker volumes for data persistence.

## Ansible Playbook Structure

The deployment is orchestrated using Ansible with the following roles:

1. **docker-install**: Installs Docker and its dependencies
2. **setup-mongodb**: Sets up MongoDB container and network
3. **backend-deployment**: Deploys the Node.js backend API
4. **frontend-deployment**: Deploys the React frontend

For detailed explanation of the playbook structure and execution order, see [explanation.md](explanation.md).

## Container Details

### Frontend Container:
- Base image: `derrickselempo/yolo-client:v1.0.0`
- Exposed port: 80
- Non-root user: appuser

### Backend Container:
- Base image: `derrickselempo/yolo-backend:v1.0.0`
- Exposed port: 5000
- Non-root user: appuser
- Environment variables: MongoDB connection string

### Database Container:
- Base image: `mongo`
- Exposed port: 27017
- Persistent volume: app-mongo-data

## API Endpoints

- GET /api/products: List all products
- POST /api/products: Add a product
- GET /api/products/:id: Get a specific product
- PUT /api/products/:id: Update a product
- DELETE /api/products/:id: Delete a product

## Development

To modify the application:

1. Make changes to the codebase
2. Rebuild Docker images if necessary
3. Update Ansible roles if needed
4. Re-provision the VM with `vagrant provision`

## Troubleshooting

If you encounter issues:

1. Check container logs:
```bash
vagrant ssh -c "sudo docker logs <container_name>"
```

2. Verify all containers are running:
```bash
vagrant ssh -c "sudo docker ps -a"
```

3. Restart containers if needed:
```bash
vagrant ssh -c "sudo docker restart <container_name>"
```

4. Check MongoDB connection:
```bash
vagrant ssh -c "sudo docker exec -it app-mongo mongo"
```

## License

MIT
