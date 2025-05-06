terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

module "networking" {
  source = "./modules/networking"
  
  prefix           = "yolo"
  region           = var.region
  zone             = var.zone
  subnet_cidr_block = var.subnet_cidr_block
}

resource "google_compute_instance" "yolo_server" {
  name         = "yolo-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = 20
    }
  }

  network_interface {
    network    = module.networking.network_id
    subnetwork = module.networking.subnet_id
    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

  tags = ["yolo-server", "http-server", "https-server"]

  provisioner "local-exec" {
    command = "echo ${self.network_interface[0].access_config[0].nat_ip} > ../inventory/hosts"
  }

  provisioner "local-exec" {
    command = "sleep 60 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../inventory/hosts ../playbook.yml"
  }
}

output "server_public_ip" {
  value = google_compute_instance.yolo_server.network_interface[0].access_config[0].nat_ip
}

output "server_id" {
  value = google_compute_instance.yolo_server.id
}
