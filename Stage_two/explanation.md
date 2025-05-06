# Stage 2: Terraform and Ansible Integration Explanation

## Architecture Overview

Stage 2 implements an integrated Infrastructure as Code (IaC) solution that combines:
- **Terraform** for infrastructure provisioning
- **Ansible** for configuration management and application deployment

This integration creates a seamless workflow where a single command can provision cloud infrastructure and deploy the complete application stack.

## Terraform and Ansible Integration Approach

### 1. Integration Method

We've implemented a bidirectional integration between Terraform and Ansible:

1. **Ansible Orchestrating Terraform**:
   - Ansible playbook executes Terraform commands
   - Handles initialization, planning, and applying infrastructure changes
   - Parses Terraform outputs for use in subsequent tasks

2. **Terraform Triggering Ansible**:
   - Terraform's local-exec provisioner updates Ansible inventory
   - Triggers the application deployment playbook after infrastructure is ready

This approach provides the benefits of both tools:
- Terraform's declarative infrastructure definition
- Ansible's procedural configuration management

## Terraform Implementation

### 1. Resource Provisioning

The Terraform configuration creates the following AWS resources:

- **VPC**: Isolated network environment
- **Subnet**: Network segment within the VPC
- **Internet Gateway**: Provides internet access
- **Route Table**: Directs traffic between subnet and internet
- **Security Group**: Firewall rules for the EC2 instance
- **EC2 Instance**: Ubuntu 20.04 server to host the application

### 2. Variables Management

Variables are centralized in `variables.tf` for easy customization:

- **AWS Region**: Geographic location for resources
- **Network Configuration**: CIDR blocks, availability zone
- **Instance Configuration**: AMI, instance type, key name

### 3. Output Management

Outputs are defined in `outputs.tf` to expose important resource information:

- **Server Public IP**: For accessing the application
- **Resource IDs**: For reference and management

### 4. Provisioners

Terraform uses local-exec provisioners to:

1. Update the Ansible inventory with the EC2 instance's IP
2. Trigger the Ansible playbook for application deployment

## Ansible Implementation

### 1. Terraform Orchestration

The `terraform_playbook.yml` handles the infrastructure provisioning:

- **Validation**: Checks if Terraform is installed
- **Initialization**: Sets up the Terraform working directory
- **Planning**: Creates an execution plan
- **Application**: Applies the planned changes
- **Output Parsing**: Extracts and displays resource information

### 2. Application Deployment

After infrastructure provisioning, Ansible:

1. Waits for the EC2 instance to become reachable
2. Updates the system packages
3. Clones the application repository
4. Executes the roles from Stage 1:
   - docker-install
   - setup-mongodb
   - backend-deployment
   - frontend-deployment

### 3. Role Reuse

Stage 2 reuses the roles from Stage 1, demonstrating the modularity and reusability of Ansible roles across different environments.

## Security Considerations

1. **State Management**:
   - Terraform state contains sensitive information
   - State file is included in the repository with placeholders
   - Real credentials are excluded via .gitignore

2. **Network Security**:
   - Security group restricts access to necessary ports only
   - SSH access can be limited to specific IP addresses

3. **Credential Management**:
   - AWS credentials are managed externally
   - No hardcoded secrets in the repository

## Best Practices Implemented

1. **Modular Design**:
   - Separation of infrastructure and configuration code
   - Reusable Ansible roles

2. **Variable Abstraction**:
   - Customizable deployment through variables
   - Environment-specific configurations

3. **Error Handling**:
   - Validation of prerequisites
   - Waiting for resources to be ready

4. **Documentation**:
   - Comprehensive README
   - Detailed explanation of architecture and implementation

5. **Security**:
   - Proper management of sensitive information
   - Restricted network access

## Execution Flow

1. User runs `ansible-playbook terraform_playbook.yml`
2. Ansible executes Terraform to provision infrastructure
3. Terraform creates AWS resources and updates inventory
4. Ansible waits for the EC2 instance to be accessible
5. Ansible configures the instance with Docker
6. Ansible deploys the application containers
7. Application is accessible via the EC2 instance's public IP
