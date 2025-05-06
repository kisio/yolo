# Stage 2: Terraform and Ansible Integration

This directory contains the implementation of Stage 2 of the DevOps Configuration Management project, which integrates Terraform for infrastructure provisioning with Ansible for configuration management.

## Overview

In this stage, we use:
- **Terraform** to provision AWS infrastructure (VPC, subnet, security group, EC2 instance)
- **Ansible** to orchestrate both the Terraform provisioning and the subsequent configuration of the provisioned infrastructure

This creates a seamless workflow where a single command can provision and configure the entire application stack.

## Prerequisites

- Terraform (v1.2.0 or higher)
- Ansible (v2.9 or higher)
- AWS CLI configured with appropriate credentials
- SSH key pair named "yolo-key" registered in your AWS account

## Directory Structure

```
Stage_two/
├── inventory/
│   └── hosts                  # Ansible inventory file (populated by Terraform)
├── terraform/
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Terraform variables
│   └── outputs.tf             # Terraform outputs
├── terraform_playbook.yml     # Ansible playbook for Terraform integration
└── README.md                  # This file
```

## How It Works

1. The Ansible playbook (`terraform_playbook.yml`) uses the Terraform command-line interface to:
   - Initialize Terraform
   - Plan the infrastructure changes
   - Apply the changes to provision the AWS resources

2. Terraform creates the infrastructure and uses a local-exec provisioner to:
   - Write the EC2 instance's IP address to the Ansible inventory file
   - Trigger the application deployment playbook

3. The application deployment playbook configures the EC2 instance with:
   - Docker and its dependencies
   - MongoDB container
   - Backend API container
   - Frontend container

## Usage

To deploy the entire stack (infrastructure and application):

```bash
cd Stage_two
ansible-playbook terraform_playbook.yml
```

To destroy the infrastructure when you're done:

```bash
cd Stage_two/terraform
terraform destroy -auto-approve
```

## Variables

### Terraform Variables

You can customize the deployment by modifying the variables in `terraform/variables.tf` or by creating a `terraform.tfvars` file with your own values:

- `aws_region`: AWS region to deploy resources (default: us-east-1)
- `vpc_cidr_block`: CIDR block for VPC (default: 10.0.0.0/16)
- `subnet_cidr_block`: CIDR block for subnet (default: 10.0.1.0/24)
- `availability_zone`: Availability zone for subnet (default: us-east-1a)
- `instance_ami`: AMI ID for EC2 instance (default: Ubuntu 20.04 LTS in us-east-1)
- `instance_type`: EC2 instance type (default: t2.micro)
- `key_name`: Name of the SSH key pair (default: yolo-key)

### Ansible Variables

The Ansible configuration uses the same variables as Stage 1, defined in `../vars/main.yml`.

## Security Considerations

- The Terraform state file contains sensitive information and should not be committed to version control
- AWS credentials should be managed securely and not hardcoded in any files
- The security group allows specific ports only (22, 80, 443, 5000, 27017)
- Consider restricting SSH access to your IP address only in a production environment
