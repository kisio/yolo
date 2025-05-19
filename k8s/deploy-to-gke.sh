#!/bin/bash

# Script to deploy YOLO e-commerce app to GKE
# Make sure you have gcloud CLI installed and configured

# Set your GKE project and cluster details
PROJECT_ID="yolo-ecommerce-project"
CLUSTER_NAME="yolo-cluster"
ZONE="us-central1-a"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deploying YOLO E-commerce Application to GKE...${NC}"

# Connect to GKE cluster
echo -e "${GREEN}Connecting to GKE cluster...${NC}"
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT_ID

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

# Get service URLs
echo -e "${GREEN}Deployment complete! Getting service URLs...${NC}"
echo -e "${YELLOW}It may take a few minutes for the LoadBalancer IP addresses to be assigned${NC}"

echo -e "${GREEN}Backend service URL:${NC}"
kubectl get service backend-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ":5000"

echo -e "${GREEN}Frontend service URL:${NC}"
kubectl get service frontend-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ":80"

echo -e "${GREEN}Ingress URL (may take several minutes to provision):${NC}"
kubectl get ingress yolo-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
