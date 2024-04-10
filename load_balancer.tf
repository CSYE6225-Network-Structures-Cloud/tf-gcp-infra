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
  default     = 30
}

variable "healthy_threshold" {
  description = "The healthy threshold"
  default     = 2
}

variable "unhealthy_threshold" {
  description = "The unhealthy threshold"
  default     = 5
}

variable "port_name" {
  description = "The port name"
  default     = "http"
}

variable "port" {
  description = "The port"
  default     = 8080
}

variable "port_specification" {
  description = "The port specification"
  default     = "USE_NAMED_PORT"
}

variable "request_path" {
  description = "The request path"
  default     = "/healthz"
}

variable "proxy_header" {
  description = "The proxy header"
  default     = "NONE"
}

variable "log_config_enable" {
  description = "Whether to enable log config"
  default     = true
}

variable "sample_rate_log" {
  description = "The sample rate for the log"
  default     = 1.0
}

variable "instance_manager_name" {
  description = "The name of the instance manager"
  default     = "webapp-instance-manager"
}

variable "base_instance_name" {
  description = "The base instance name"
  default     = "vm"
  
}

variable "backend_service_name" {
  description = "The name of the backend service"
  default     = "webapp-backend-service"
}

variable "protocol" {
  description = "The protocol"
  default     = "HTTP"
}

variable "load_balancing_scheme" {
  description = "The load balancing scheme"
  default     = "EXTERNAL"
}

variable "connection_draining_timeout_sec" {
  description = "The connection draining timeout in seconds"
  default     = 0
}

variable "balancing_mode" {
  description = "The balancing mode"
  default     = "UTILIZATION"
}

variable "cert_domains" {
    type       = list(string)
    description = "The certificate domains"
    default     = ["snehilaryan32.store."]
}

variable "cert_name" {
    description = "The name of the vert"
    default     = "webapp-cert"
}

variable "ip_version" {
    description = "The ip version"
    default     = "IPV4"
}

variable "timeout_sec_backend_service" {
    description = "The timeout in seconds for the backend service"
    default     = 30
}

variable "session_affinity" {
    description = "The session affinity"
    default     = "NONE"
}

variable "forwarding_rule_port_range" {
    description = "The forwarding rule port range"
    default     = "443"
}

variable "capacity_scaler" {
    description = "The capacity scaler"
    default     = 1.0
}

variable "min_replicas" {
    description = "The minimum number of replicas"
    default     = 3
}

variable "max_replicas" {
    description = "The maximum number of replicas"
    default     = 6
}

variable "cpu_utilization" {
    description = "The cpu utilization"
    default     = 0.05
}

variable "health_check_timeout_sec" {
    description = "The health check timeout in seconds"
    default     = 30
}

variable "auto_healing_delay_sec" {
    description = "The auto healing delay in seconds"
    default     = 180
}

variable "cooldown_period" {
    description = "The cooldown period"
    default     = 100
}


resource "google_compute_managed_ssl_certificate" "default" {
  project = var.project_id
  name = var.cert_name
  managed {
    domains = var.cert_domains
  }
}


resource "google_compute_global_address" "default" {
  project = var.project_id
  name       = "lb-ipv4-1"
  ip_version = var.ip_version
}

resource "google_compute_health_check" "default" {
  project = var.project_id  
  name               = "http-basic-check"
  check_interval_sec = var.check_interval_sec
  healthy_threshold  = var.healthy_threshold
  http_health_check {
    # port_name          = var.port_name
    # port_specification = var.port_specification
    port               = var.port
    request_path       = var.request_path
    # proxy_header       = var.proxy_header
    # response           = var.response
  }

  log_config {
    enable     = var.log_config_enable
  }
  timeout_sec         = var.health_check_timeout_sec
  unhealthy_threshold = 2
}

resource "google_compute_region_instance_group_manager" "default" {
  project = var.project_id
  name               = var.instance_manager_name 
  region             = var.region
  base_instance_name = var.base_instance_name

  named_port {
    name = var.port_name
    port = var.port
  }
  version {
    instance_template = google_compute_region_instance_template.default.self_link
    name = "primary"
  }
  auto_healing_policies {
    health_check = google_compute_health_check.default.self_link
    initial_delay_sec = var.auto_healing_delay_sec
  }
}

resource "google_compute_backend_service" "default" {
  project                         = var.project_id
  name                            = var.backend_service_name
  connection_draining_timeout_sec = 0
  health_checks                   = [google_compute_health_check.default.self_link]
  load_balancing_scheme           = var.load_balancing_scheme
  port_name                       = var.port_name
  protocol                        = var.protocol
  session_affinity                = var.session_affinity  
  timeout_sec                     = var.timeout_sec_backend_service
  
  backend {
    group           = google_compute_region_instance_group_manager.default.instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = var.capacity_scaler
  }

  log_config {
    enable = var.log_config_enable
   sample_rate =var.sample_rate_log
  }
}

resource "google_compute_url_map" "default" {
  project = var.project_id
  name            = "web-map-http"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_https_proxy" "default" {
  project = var.project_id
  name    = "https-lb-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
}


resource "google_compute_global_forwarding_rule" "default" {
  project = var.project_id
  name                  = "l7-xlb-forwarding-rule"
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.forwarding_rule_port_range
  target                = google_compute_target_https_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}



resource "google_compute_region_autoscaler" "autoscaler" {
  project     = var.project_id
  region      = var.region
  name        = "autoscaler"
  target      = google_compute_region_instance_group_manager.default.self_link
  autoscaling_policy {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    cooldown_period = var.cooldown_period
    cpu_utilization {
      target = var.cpu_utilization
    }
  }
}

resource "google_dns_record_set" "webapp" {
  name = var.domain_name
  type = "A"
  ttl  = 300
  managed_zone = var.managed_zone_name
  rrdatas = [google_compute_global_address.default.address]
  project  = var.project_id
  depends_on = [google_compute_global_address.default]
}









