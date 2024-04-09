variable "key_ring_name" {
  description = "The id of the key ring created using cli"
  type        = string
  default     = "key_ring_webapp"
}

variable "rotation_period" {
  description = "The rotation period of the key"
  type        = string
  default     = "2592000s"
}

data "google_kms_key_ring" "my_key_ring" {
  name     = var.key_ring_name
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "server-key" {
  name             = "crypto-key-server"
  key_ring        = data.google_kms_key_ring.my_key_ring.id
  rotation_period  = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "bucket-key" {
  name             = "crypto-key-bucket"
  key_ring        = data.google_kms_key_ring.my_key_ring.id
  rotation_period  = var.rotation_period

  lifecycle {
    prevent_destroy = false
  }
}