module "vpc" {
  source = "./vpc_module"
  vpc_name = var.vpc_name
  project_id = var.project_id
  region = var.region
  routing_mode = var.routing_mode
  auto_create_subnetworks = var.auto_create_subnetworks
  delete_default_routes_on_create = var.delete_default_routes_on_create
  webapp_subnet_name = var.webapp_subnet_name
  webapp_cidr_range = var.webapp_cidr_range
  webapp_route_name = var.webapp_route_name
  webapp_dest_range = var.webapp_dest_range
  db_subnet_name = var.db_subnet_name
  db_cidr_range = var.db_cidr_range
  next_hop_gateway = var.next_hop_gateway
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-firewall"
  network = module.vpc.network_self_link
  project = var.project_id
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp"]
}

resource "google_compute_firewall" "deny_ssh_rule" {
  name    = "block-firewall"
  network = module.vpc.network_self_link
  project = var.project_id 
  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["webapp"]
  source_ranges = ["0.0.0.0/0"]
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
    network = module.vpc.network_self_link
    subnetwork = module.vpc.subnet_self_link
    access_config {
      network_tier = var.network_tier
    }
  }
  tags = ["webapp"]
}


