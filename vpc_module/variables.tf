variable "region" {
  description = "The region where the subnet will be created"
  type        = string
  default     = "us-central1"
}

variable "project_id" {
  description = "The project ID where the VPC will be created"
  type        = string
  default     = "csye6225-414117" 
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "app-vpc"
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