variable "db_instance_name" {
  description = "The name of the database instance"
  type        = string
  default     = "webapp-db"
}



variable "database_version" {
  description = "The database version to use"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier_db" {
  description = "The tier of the database"
  type        = string
  default     = "db-f1-micro"
}

variable "deletion_protection_db" {
  description = "Whether to enable deletion protection for the database instance"
  type        = bool
  default     = false
}

variable "availability_type_db" {
  description = "The availability type of the database"
  type        = string
  default     = "REGIONAL"
}

variable "disk_type_db" {
  description = "The disk type of the database"
  type        = string
  default     = "PD_SSD"
}

variable "disk_size_db" {
  description = "The disk size of the database"
  type        = number
  default     = 100
}

variable "ipv4_enabled_db" {
  description = "value of ipv4_enabled"
  type        = bool
  default     = false
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "webapp"
}

variable "db_user" {
  description = "The user of the database"
  type        = string
  default     = "webapp"  
}

variable "private_ip_address_name" {
  description = "The name of the private IP address"
  type        = string
  default     = "private-ip"
}


resource "google_compute_global_address" "private_ip_address" {
  project = var.project_id
  name          = var.private_ip_address_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  network       = module.vpc.network_self_link
  prefix_length = 16
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on = [google_compute_global_address.private_ip_address]
}


# locals {
#   webapp_ip = google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip
# }


resource "google_sql_database_instance" "instance" {
  name                = var.db_instance_name
  region              = var.region
  database_version    = var.database_version
  deletion_protection = var.deletion_protection_db
  project             = var.project_id  
  depends_on = [ google_service_networking_connection.private_vpc_connection ]
  settings {
    tier              = var.tier_db
    availability_type = var.availability_type_db
    disk_type         = var.disk_type_db
    disk_size         = var.disk_size_db
    ip_configuration {
      ipv4_enabled                                  = var.ipv4_enabled_db
      private_network                               = module.vpc.network_self_link
      # authorized_networks {
      #   name = "private-ip-address"
      #   value = "35.209.255.148"
      # }
    }
  }
}

resource "google_sql_database" "database" {
  name     = var.db_name
  project = var.project_id
  instance = google_sql_database_instance.instance.name
}

resource random_password "password" {
  length  = 16
  special = false
}

resource "google_sql_user" "user" {
  project = var.project_id
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_password.password.result
}


output "db_host" {
  value = google_sql_database_instance.instance.ip_address[0]
  description = "The IP address of the database host."
}