variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "yolo-ecommerce-project"
}

variable "region" {
  description = "GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "GCP machine type for compute instance"
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Boot disk image for compute instance"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key for instance access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
