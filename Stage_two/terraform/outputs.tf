output "server_public_ip" {
  description = "Public IP address of the GCP instance"
  value       = google_compute_instance.yolo_server.network_interface[0].access_config[0].nat_ip
}

output "server_id" {
  description = "ID of the GCP instance"
  value       = google_compute_instance.yolo_server.id
}

output "network_id" {
  description = "ID of the VPC network"
  value       = module.networking.network_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.networking.subnet_id
}
