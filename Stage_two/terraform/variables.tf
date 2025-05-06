variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_ami" {
  description = "AMI ID for EC2 instance (Ubuntu 20.04)"
  type        = string
  default     = "ami-0261755bbcb8c4a84" # Ubuntu 20.04 LTS in us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "yolo-key"
}
