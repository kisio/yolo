#!/bin/bash

# Script to deploy YOLO e-commerce app to Minikube
# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deploying YOLO E-commerce Application to Minikube...${NC}"

# Create namespace
echo -e "${GREEN}Creating yolo namespace...${NC}"
kubectl create namespace yolo
kubectl config set-context --current --namespace=yolo

# Apply MongoDB StatefulSet
echo -e "${GREEN}Deploying MongoDB StatefulSet...${NC}"
kubectl apply -f mongodb-statefulset.yaml

# Wait for MongoDB to be ready
echo -e "${GREEN}Waiting for MongoDB to be ready...${NC}"
kubectl wait --for=condition=Ready pod/mongodb-0 --timeout=300s

# Apply Backend Deployment
echo -e "${GREEN}Deploying Backend service...${NC}"
kubectl apply -f backend-deployment.yaml

# Apply Frontend Deployment
echo -e "${GREEN}Deploying Frontend service...${NC}"
kubectl apply -f frontend-deployment.yaml

# Apply Ingress
echo -e "${GREEN}Deploying Ingress...${NC}"
kubectl apply -f ingress.yaml

# Enable Minikube Ingress addon if not already enabled
echo -e "${GREEN}Enabling Minikube Ingress addon...${NC}"
minikube addons enable ingress

# Get service URLs
echo -e "${GREEN}Deployment complete! Getting service URLs...${NC}"

echo -e "${GREEN}Backend service URL:${NC}"
minikube service backend-external --url -n yolo

echo -e "${GREEN}Frontend service URL:${NC}"
minikube service frontend-external --url -n yolo

echo -e "${GREEN}To access the application via Ingress, run:${NC}"
echo "minikube ip"
echo -e "Then add the IP to your /etc/hosts file as: <minikube-ip> yolo.local"
echo -e "And access the application at: http://yolo.local"
