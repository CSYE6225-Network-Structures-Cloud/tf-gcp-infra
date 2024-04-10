resource "google_compute_firewall" "allow_ingrss_flask_port" {
  name    = "allow-ingress-flask-port"
  network = module.vpc.network_self_link
  project = var.project_id
  priority = 999
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = var.allowed_ingress_ports
  }
  source_ranges = [google_compute_global_forwarding_rule.default.ip_address, "130.211.0.0/22", "35.191.0.0/16"]
  target_tags = ["webapp"]
}

# Allow db only for webapp servers
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
  
  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# # Block database access
# resource "google_compute_firewall" "deny_db_access" {
#   name     = "deny-db-access"
#   network  = module.vpc.network_self_link
#   project  = var.project_id
#   direction = "EGRESS"

#   deny {
#     protocol = "tcp"
#     ports    = ["5432"]
#   }
#   destination_ranges = ["0.0.0.0/0"]
# }