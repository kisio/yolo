terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "yolo_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "yolo-vpc"
  }
}

resource "aws_subnet" "yolo_subnet" {
  vpc_id                  = aws_vpc.yolo_vpc.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "yolo-subnet"
  }
}

resource "aws_internet_gateway" "yolo_igw" {
  vpc_id = aws_vpc.yolo_vpc.id
  tags = {
    Name = "yolo-igw"
  }
}

resource "aws_route_table" "yolo_rtb" {
  vpc_id = aws_vpc.yolo_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yolo_igw.id
  }
  tags = {
    Name = "yolo-rtb"
  }
}

resource "aws_route_table_association" "yolo_rtb_assoc" {
  subnet_id      = aws_subnet.yolo_subnet.id
  route_table_id = aws_route_table.yolo_rtb.id
}

resource "aws_security_group" "yolo_sg" {
  name        = "yolo-security-group"
  description = "Allow HTTP, HTTPS, SSH, and application ports"
  vpc_id      = aws_vpc.yolo_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Backend API"
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "MongoDB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "yolo-security-group"
  }
}

resource "aws_instance" "yolo_server" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.yolo_sg.id]
  subnet_id              = aws_subnet.yolo_subnet.id
  
  tags = {
    Name = "yolo-server"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ../inventory/hosts"
  }

  provisioner "local-exec" {
    command = "sleep 60 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../inventory/hosts ../playbook.yml"
  }
}

output "server_public_ip" {
  value = aws_instance.yolo_server.public_ip
}

output "server_id" {
  value = aws_instance.yolo_server.id
}
