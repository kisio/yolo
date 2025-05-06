output "server_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.yolo_server.public_ip
}

output "server_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.yolo_server.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.yolo_vpc.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.yolo_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.yolo_sg.id
}
