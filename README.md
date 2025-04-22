# YOLO E-commerce Application

A containerized full-stack e-commerce application built with React, Node.js, and MongoDB.

## Features

- Product management (Add, View products)
- MongoDB persistence
- Containerized microservices architecture
- Secure container configuration with non-root users

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/kisio/yolo.git
cd yolo
```

2. Start the application:
```bash
docker-compose up -d
```

3. Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- MongoDB: localhost:27017

## Architecture

The application consists of three microservices:
1. Frontend (React) - Port 3000
2. Backend (Node.js/Express) - Port 5000
3. Database (MongoDB) - Port 27017

All services are connected through a custom bridge network and use Docker volumes for data persistence.

## Container Details

- Frontend Container:
  - Base image: node:13.12.0 (build), nginx:alpine (production)
  - Exposed port: 3000
  - Non-root user: appuser

- Backend Container:
  - Base image: node:13.12.0
  - Exposed port: 5000
  - Non-root user: appuser

- Database Container:
  - Base image: mongo:5.0.9
  - Exposed port: 27017
  - Persistent volume: app-mongo-data

## Security Features

- Non-root users in all containers
- Minimal base images
- Volume permissions properly configured
- Health checks implemented

## Environment Variables

The backend requires the following environment variables (can be set in a `.env` file or via Docker Compose):
- `MONGODB_URI`: MongoDB connection string
- `PORT`: Backend server port (default: 5000)

The frontend can be configured with:
- `REACT_APP_API_URL`: URL of the backend API

## DockerHub

Images are available at: https://hub.docker.com/u/kisio

## Contribution Guidelines

1. Fork the repository
2. Create a new branch for your feature or fix
3. Commit your changes with descriptive messages
4. Open a pull request

## API Endpoints

- `GET /api/products`: List all products
- `POST /api/products`: Add a product
- `PUT /api/products/:id`: Edit a product
- `DELETE /api/products/:id`: Delete a product

## Development

The application is containerized using Docker and orchestrated with Docker Compose. Each service runs in its own container with proper isolation and networking.
