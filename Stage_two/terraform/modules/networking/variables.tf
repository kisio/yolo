variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "yolo"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
}

variable "zone" {
  description = "GCP zone for resources"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
}
