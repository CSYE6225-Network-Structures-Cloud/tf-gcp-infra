locals {
  db_host = google_sql_database_instance.instance.ip_address[0].ip_address
  env_file_path =  "/home/${var.packer_ssh_username}/flaskapp.env"
}

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

######################################################Service Account##########################################################################
resource "google_service_account" "service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
  project      = var.project_id
}

resource "google_project_iam_binding" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"

  members = [
   "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

resource "google_project_iam_binding" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.service_account.email}"
  ]
}

###############################################################Compute Instance##################################################################
resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = var.machine_type
  project      = var.project_id
  zone         = var.zone
  allow_stopping_for_update = var.allow_webapp_stop_for_update

  service_account {
    email  = google_service_account.service_account.email
    scopes = var.scopes
  }

  tags = ["webapp"]
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
    metadata_startup_script = <<EOF
    #!/bin/bash
    touch ${local.env_file_path}
    echo "DB_HOST=${local.db_host}" >> ${local.env_file_path}
    echo "DB_PORT=5432" >> ${local.env_file_path}
    echo "DB_NAME=${var.db_name}" >> ${local.env_file_path}
    echo "DB_USER=${var.db_user}" >> ${local.env_file_path}
    echo "DB_PASSWORD=${random_password.password.result}" >> ${local.env_file_path}
    echo "LOG_FILE_PATH=${var.log_file_path}" >> ${local.env_file_path}
    echo "PROJECT_ID=${var.project_id}" >> ${local.env_file_path}
    echo "PUBSUB_TOPIC_ID=${var.pubsub_topic_name}" >> ${local.env_file_path}
    echo "ENVIRONMENT=${var.app_env}" >> ${local.env_file_path}
    sudo chown csye6225:csye6225 /home/packer/flaskapp.env
    sudo chmod 644 /home/packer/flaskapp.env
    sudo systemctl daemon-reload
    sudo systemctl restart flaskapp
    EOF
}

output "instance_external_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

resource "google_dns_record_set" "webapp" {
  name = var.domain_name
  type = "A"
  ttl  = 300
  managed_zone = var.managed_zone_name
  rrdatas = [google_compute_instance.default.network_interface.0.access_config.0.nat_ip]
  project  = var.project_id
  depends_on = [ google_compute_instance.default ]
}