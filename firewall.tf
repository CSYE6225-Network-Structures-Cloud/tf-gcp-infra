#Allow ingress http port for api
resource "google_compute_firewall" "allow_ingrss_flask_port" {
  name    = "allow-ingress-flask-port"
  network = module.vpc.network_self_link
  project = var.project_id
  
  allow {
    protocol = "tcp"
    ports    = var.allowed_ingress_ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp"]
}

#Allow egress to webapp servers, priority is set to 999 to ensure it overrides the deny egress to db rule 
resource "google_compute_firewall" "allow_egress_webapp" {
  name    = "allow-egress-webapp"
  network = module.vpc.network_self_link
  project = var.project_id
  direction = "EGRESS"
  priority = 999
  
  allow {
    protocol = var.allowed_egress_protocol
  }

  destination_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp"]
}

# Block ssh port
resource "google_compute_firewall" "deny_ssh_rule" {
  name    = "block-firewall"
  network = module.vpc.network_self_link
  project = var.project_id 
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Deny egress to db instance by default for all the instances in the network
resource "google_compute_firewall" "deny_db_access" {
  name     = "deny-db-access"
  network  = module.vpc.network_self_link
  project  = var.project_id
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  destination_ranges = ["0.0.0.0/0"]
}