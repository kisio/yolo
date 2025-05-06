# Stage 2: Terraform and Ansible Integration with Google Cloud Platform

This directory contains the implementation of Stage 2 of the DevOps Configuration Management project, which integrates Terraform for infrastructure provisioning with Ansible for configuration management using Google Cloud Platform (GCP).

## Overview

In this stage, we use:
- **Terraform** to provision GCP infrastructure (VPC network, subnet, firewall rules, Compute Engine instance)
- **Ansible** to orchestrate both the Terraform provisioning and the subsequent configuration of the provisioned infrastructure

This creates a seamless workflow where a single command can provision cloud infrastructure and deploy the complete application stack.

## Prerequisites

- Terraform (v1.2.0 or higher)
- Ansible (v2.9 or higher)
- Google Cloud SDK (gcloud CLI)
- GCP Project with billing enabled
- Service account with appropriate permissions
- SSH key pair for instance access

## Directory Structure

```
Stage_two/
├── inventory/
│   └── hosts                  # Ansible inventory file (populated by Terraform)
├── terraform/
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Terraform variables
│   ├── outputs.tf             # Terraform outputs
│   └── modules/               # Terraform modules
│       └── networking/        # Network infrastructure module
├── terraform_playbook.yml     # Ansible playbook for Terraform integration
└── README.md                  # This file
```

## How It Works

1. The Ansible playbook (`terraform_playbook.yml`) uses the Terraform command-line interface to:
   - Initialize Terraform
   - Plan the infrastructure changes
   - Apply the changes to provision the GCP resources

2. Terraform creates the infrastructure and uses a local-exec provisioner to:
   - Write the Compute Engine instance's IP address to the Ansible inventory file
   - Trigger the application deployment playbook

3. The application deployment playbook configures the Compute Engine instance with:
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

- `project_id`: GCP project ID
- `region`: GCP region to deploy resources (default: us-central1)
- `zone`: GCP zone for resources (default: us-central1-a)
- `subnet_cidr_block`: CIDR block for subnet (default: 10.0.1.0/24)
- `machine_type`: GCP machine type (default: e2-medium)
- `image`: Boot disk image (default: ubuntu-os-cloud/ubuntu-2004-lts)
- `ssh_public_key_path`: Path to SSH public key for instance access

### Ansible Variables

The Ansible configuration uses the same variables as Stage 1, defined in `../vars/main.yml`.

## Security Considerations

- The Terraform state file contains sensitive information and should not be committed to version control
- GCP credentials should be managed securely and not hardcoded in any files
- Firewall rules allow specific ports only (22, 80, 443, 5000, 27017)
- Consider restricting SSH access to your IP address only in a production environment
