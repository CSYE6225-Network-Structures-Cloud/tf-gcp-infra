variable "key_ring_name" {
  description = "The id of the key ring created using cli"
  type        = string
  default     = "key_ring_webapp_new-2024-04-10T05-14-12Z"
}

variable "rotation_period" {
  description = "The rotation period of the key"
  type        = string
  default     = "2592000s"
}

variable "storge_svc_account" {
  description = "The storage service account"
  type        = string
  default     = "service-712481690114@gs-project-accounts.iam.gserviceaccount.com"
}

# data "google_kms_key_ring" "my_key_ring" {
#   name     = var.key_ring_name
#   location = var.region
#   project  = var.project_id
# }

resource "google_kms_key_ring" "key_ring" {
  name     = var.key_ring_name
  project  = var.project_id
  location = var.region
}

resource "google_kms_crypto_key" "server-key" {
  name             = "crypto-key-server"
  key_ring         = google_kms_key_ring.key_ring.id
  rotation_period  = var.rotation_period
  # lifecycle {
  #   prevent_destroy = false
  # }
}

resource "google_kms_crypto_key" "sql-key" {
  name             = "crypto-key-sql"
  key_ring         = google_kms_key_ring.key_ring.id
  rotation_period  = var.rotation_period
  # lifecycle {
  #   prevent_destroy = false
  # }
}

resource "google_kms_crypto_key" "bucket-key" {
  name             = "crypto-key-bucket"
  key_ring         = google_kms_key_ring.key_ring.id
  rotation_period  = var.rotation_period
  # lifecycle {
  #   prevent_destroy = false
  # }
}



#############################IAM Bindings for the KMS Crypto Keys############################################
resource "google_kms_crypto_key_iam_binding" "crypto_key" {
  crypto_key_id = "${google_kms_crypto_key.server-key.id}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${var.project_number}@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_sql" {
  crypto_key_id = "${google_kms_crypto_key.sql-key.id}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${var.project_number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"
  ]
}

resource "google_kms_crypto_key_iam_binding" "crypto_key_bucket" {
  crypto_key_id = "${google_kms_crypto_key.bucket-key.id}"
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com"
  ]
}


#############################Create Secrets To be accessed by the GitHub Actions for deployment############################################
resource "google_secret_manager_secret" "server-key" {
  secret_id = "server-key"
  project = var.project_id
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "server-key-version" {
  secret      = google_secret_manager_secret.server-key.id
  secret_data = google_kms_crypto_key.server-key.id
}