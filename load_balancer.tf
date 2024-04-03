variable "health_check_name" {
  description = "The name of the health check"
  default     = "https-health-check"
}

variable "timeout_sec" {
  description = "The timeout in seconds"
  default     = 1
}

variable "check_interval_sec" {
  description = "The check interval in seconds"
  default     = 1
}

variable "healthy_threshold" {
  description = "The healthy threshold"
  default     = 4
}

variable "unhealthy_threshold" {
  description = "The unhealthy threshold"
  default     = 5
}

variable "port_name" {
  description = "The port name"
  default     = "webapp"
}

variable "port" {
  description = "The port"
  default     = 8080
  
}

variable "port_specification" {
  description = "The port specification"
  default     = "USE_NAMED_PORT"
}

# variable "host" {
#   description = "The host"
#   default     = "1.2.3.4"
# }

variable "request_path" {
  description = "The request path"
  default     = "/mypath"
}

variable "proxy_header" {
  description = "The proxy header"
  default     = "NONE"
}

variable "response" {
  description = "The response"
  default     = "I AM HEALTHY"
}

variable "log_config_enable" {
  description = "Whether to enable log config"
  default     = true
}

variable "instance_manager_name" {
  description = "The name of the instance manager"
  default     = "webapp-instance-manager"
}

variable "base_instance_name" {
  description = "The base instance name"
  default     = "webapp-instance"
  
}

variable "backend_service_name" {
  description = "The name of the backend service"
  default     = "webapp-backend-service"
}

variable "protocol" {
  description = "The protocol"
  default     = "HTTPS"
  
}

variable "load_balancing_scheme" {
  description = "The load balancing scheme"
  default     = "EXTERNAL"
}

resource "google_compute_health_check" "https-health-check" {
  name        = var.health_check_name
  description = "Health check via https for web app"
  project = var.project_id

  timeout_sec         = var.timeout_sec
  check_interval_sec  = var.check_interval_sec
  healthy_threshold   = var.healthy_threshold
  unhealthy_threshold = var.unhealthy_threshold

  https_health_check {
    port_name          = var.port_name
    port_specification = var.port_specification
    request_path       = var.request_path
    proxy_header       = var.proxy_header
    response           = var.response
  }

  log_config {
    enable     = var.log_config_enable
  }
}

resource "google_compute_region_instance_group_manager" "default" {
  name               = var.instance_manager_name 
  base_instance_name = var.base_instance_name
  region             = var.region
  project = var.project_id

  named_port {
    name = var.port_name
    port = var.port
  }

version {
    instance_template = google_compute_instance_template.default.self_link
  }

}

resource "google_compute_region_backend_service" "default" {
  name             = var.backend_service_name
  region           = var.region
  protocol         = var.protocol
  project          = var.project_id
  timeout_sec      = 10
  load_balancing_scheme = var.load_balancing_scheme
#   session_affinity = "NONE"

  backend {
    group = google_compute_region_instance_group_manager.default.instance_group
  }

  health_checks = [google_compute_health_check.https-health-check.self_link]
}