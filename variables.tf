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
  default     = 100
}

variable "boot_disk_type" {
  description = "Type of the boot disk"
  type        = string
  default     = "pd-balanced"
}

variable "network" {
  description = "Name of the network"
  type        = string
  default     = "app-vpc-assignment7"
}

variable "gce_subnet" {
  description = "Name of the subnet"
  type        = string
  default     = "webapp"
}

variable "network_tier" {
  description = "The network tier of the machine"
  type        = string
  default     = "STANDARD"
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

variable "region" {
  description = "The region where the subnet will be created"
  type        = string
  default     = "us-central1"
}


variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "app-vpc-assignment8"
}

variable "routing_mode" {
  description = "The routing mode of the VPC"
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "Whether to automatically create subnetworks for the VPC"
  type        = bool
  default     = false
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default route on create"
  type        = bool
  default     = true
}

variable "webapp_subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "webapp"
}

variable "db_subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "db"
}

variable "webapp_cidr_range" {
  description = "The IP CIDR range of the subnet"
  type        = string
  default     = "10.0.1.0/24"
}


variable "db_cidr_range" {
  description = "The IP CIDR range of the subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "webapp_route_name" {
  description = "The name of the route"
  type        = string
  default     = "webapp-route"
  
}

variable "next_hop_gateway" {
  description = "The next hop gateway of the route"
  type        = string
  default     = "default-internet-gateway"  
}

variable "webapp_dest_range" {
  description = "The destination range of the route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "packer_ssh_username" {
  description = "The username for the packer image"
  type        = string
  default     = "packer"
}

variable "allowed_ingress_ports" {
  description = "The allowed ingress ports"
  type        = list(string)
  default     = ["8080"]
}

variable "allowed_egress_protocol" {
  description = "The allowed egress protocol"
  type        = string
  default     = "all"
}

variable "domain_name" {
  description = "The domain name"
  type        = string
  default     = "snehilaryan32.store."
}

variable "managed_zone_name" {
  description = "The name of the managed zone"
  type        = string
  default     = "myzone"
}

variable "service_account_id" {
  description = "The id of the service account"
  type        = string
  default     = "service-account-webapp-id"
}

variable "service_account_name" {
  description = "The name of the service account"
  type        = string
  default     = "service-account-webapp"
}

variable "scopes" {
  description = "The scopes for the service account"
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/logging.admin", "https://www.googleapis.com/auth/pubsub"]
}

variable "log_file_path" {
  description = "The path of the log file"
  type        = string
  default     = "/var/log/my-app/record.log"
}

variable "allow_webapp_stop_for_update" {
  type = bool
  default = true
}

variable "app_env" {
  description = "The environment of the app"
  type        = string
  default     = "production"
}