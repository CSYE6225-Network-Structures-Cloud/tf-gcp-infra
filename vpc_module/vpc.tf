resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_name
  auto_create_subnetworks = var.auto_create_subnetworks
  routing_mode            = var.routing_mode
  delete_default_routes_on_create = var.delete_default_routes_on_create
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = var.webapp_subnet_name
  ip_cidr_range = var.webapp_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
  private_ip_google_access = var.private_ip_google_access
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = var.db_subnet_name
  ip_cidr_range = var.db_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_route" "webapp_route" {
  name        = var.webapp_route_name
  dest_range  = var.webapp_dest_range
  network     = google_compute_network.vpc_network.self_link
  next_hop_gateway = var.next_hop_gateway
  priority    = 1000
  tags = ["webapp"] 
}


# resource "google_compute_global_address" "default" {
#   provider     = google-beta
#   project      = google_compute_network.network.project
#   name         = "global-psconnect-ip"
#   address_type = "INTERNAL"
#   purpose      = "PRIVATE_SERVICE_CONNECT"
#   network      = google_compute_network.vpc_network.id
#   address      = "10.3.0.5"
# }
# # [END compute_internal_ip_private_access]

# # [START compute_forwarding_rule_private_access]
# resource "google_compute_global_forwarding_rule" "default" {
#   provider              = google-beta
#   project               = google_compute_network.network.project
#   name                  = "globalrule"
#   target                = "all-apis"
#   network               = google_compute_network.network.id
#   ip_address            = google_compute_global_address.default.id
#   load_balancing_scheme = ""
# }