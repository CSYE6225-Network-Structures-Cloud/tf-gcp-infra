output "network_self_link" {
  description = "The self link of the VPC network"
  value       = google_compute_network.vpc_network.self_link
}

output "subnet_self_link" {
  description = "The self link of the subnet"
  value       = google_compute_subnetwork.webapp_subnet.self_link
}