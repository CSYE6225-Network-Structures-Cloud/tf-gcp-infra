module "vpc" {
    source = "./vpc_module"
}

variable "machine_name" {
  description = "Name of the machine"
  type        = string
  default     = "instance-1"
}

variable "machine_type" {
  description = "Type of the machine"
  type        = string
  default     = "e2-small"
}

variable "zone" {
  description = "Zone of the machine"
  type        = string
  default     = "us-central1-a"
}

variable "boot_image" {
  description = "Name of the image"
  type        = string
  default     = "flask-app"
}

variable "boot_disk_size" {
  description = "Size of the boot disk"
  type        = string
  default     = 20
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-standard"
}

variable "network" {
  description = "Name of the network"
  type        = string
  default     = "default"
}

variable "auto_delete_boot_disk" {
  description = "Auto delete the instance"
  type        = bool
  default     = true
}

variable "project_id" {
  description = "Name of the project"
  type        = string
  default     = "csye6225-414117"
}

resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  boot_disk {
    auto_delete = var.auto_delete_boot_disk
    initialize_params {
      image = var.boot_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }
  network_interface {
    network = var.network
    access_config {
      network_tier = "STANDARD"
    }
  }
  tags = ["http-server"]
}


