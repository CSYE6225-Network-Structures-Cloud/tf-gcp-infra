variable "pubsub_topic_name" {
  description = "The name of the topic"
  type        = string
  default     = "verify_topic"
}

variable "pubsub_topic_retention_duration" {
  description = "The name of the topic"
  type        = string
  default     = "604800s"
}

variable "service_account_cf_id" {
  type = string
  default = "service-account-cf-id"
}

variable "service_account_cf_name" {
  type = string
  default = "service-account-cf-name"
}

variable "function_name" {
  description = "The name of the function"
  type        = string
  default     = "verify_cf"
}

variable "entry_point_function" {
  description = "The entry point of the function"
  type        = string
  default     = "hello_pubsub"
}

variable "cloud_function_runtime" {
  description = "The entry point of the function"
  type        = string
  default     = "python39"
}

variable "max_instance_count" {
  description = "Maximum number of instances for the Cloud Function"
  type        = number
  default     = 1
}

variable "available_memory" {
  description = "Available memory for the Cloud Function (e.g., '256M')"
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "Timeout for the Cloud Function in seconds"
  type        = number
  default     = 60
}

#####################################Pub/Sub##################################################################
resource "google_pubsub_topic" "verify_topic" {
  name = var.pubsub_topic_name
  project = var.project_id
  message_retention_duration = var.pubsub_topic_retention_duration
}


#####################################Cloud Function Source Bucket#############################################
resource "google_storage_bucket" "lambda_source_bucket" {
  name     = "${var.project_id}-gcf-source"  # Every bucket name must be globally unique
  location = "US"
  project = var.project_id
  uniform_bucket_level_access = true
}

# resource "google_storage_bucket_object" "lambda_source_object" {
#   name   = "function-source.zip"
#   bucket = google_storage_bucket.lambda_source_bucket.name
#   source = "function-source.zip"  # Add path to the zipped function source code
# }


###################################Service account and bindings###############################################
resource "google_service_account" "service_account_cf" {
  account_id   = var.service_account_cf_id
  display_name = var.service_account_cf_name
  project      = var.project_id
}

resource "google_project_iam_binding" "pub_sub_subscriber" {
  project = var.project_id
  role    = "roles/pubsub.subscriber"

  members = [
   "serviceAccount:${google_service_account.service_account_cf.email}"
  ]
}

resource "google_project_iam_binding" "cloud_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"

  members = [
   "serviceAccount:${google_service_account.service_account_cf.email}"
  ]
}
####################################Cloud Function############################################################
resource "google_cloudfunctions2_function" "function" {
  name                  = var.function_name
  project               = var.project_id
  location               = var.region

  build_config {
    runtime = var.cloud_function_runtime
    entry_point = var.entry_point_function
    source {
      storage_source {
        bucket = google_storage_bucket.lambda_source_bucket.name
        object = "function-source.zip"
      }
    }
  }
  event_trigger {
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.verify_topic.id

  }

  service_config {
    max_instance_count  = var.max_instance_count
    available_memory    = var.available_memory
    timeout_seconds     = var.timeout_seconds
    service_account_email = google_service_account.service_account_cf.email
  }

}


