variable "project_id" {
  description = "GCP project ID to deploy Outline into."
  type        = string
}

variable "region" {
  description = "GCP region for all resources."
  type        = string
}

variable "domain" {
  description = "Custom domain Outline will be served on (e.g. docs.example.com). Used for the Cloud Run domain mapping and URL."
  type        = string
}

variable "network_name" {
  description = "Name prefix of the shared VPC network/subnet/connector (see terraform.module.network). Must match the value used by every other app sharing this VPC."
  type        = string
  default     = "tools"
}

variable "image_tag" {
  description = "Tag of the outlinewiki/outline image to deploy (matches TAG in docker-compose.yaml)."
  type        = string
  default     = "latest"
}

variable "postgresql_instance_name" {
  description = "Name of the shared Cloud SQL instance (see terraform.module.postgresql). Must match the value used by every other app sharing this instance."
  type        = string
  default     = "postgresql0"
}

variable "postgresql_name" {
  description = "Postgres database name (matches the database in DATABASE_URL)."
  type        = string
  default     = "outline"
}

variable "postgresql_user" {
  description = "Postgres user (matches the user in DATABASE_URL)."
  type        = string
  default     = "outline"
}

variable "redis_instance_name" {
  description = "Name of the shared Memorystore Redis instance (see terraform.module.redis). Must match the value used by every other app sharing this instance."
  type        = string
  default     = "redis0"
}

variable "redis_db" {
  description = "Redis logical DB index (0-15) this app uses to isolate its keys on the shared instance."
  type        = number
  default     = 1
}

variable "server_port" {
  description = "Port the server container listens on (PORT is set automatically by Cloud Run to match this)."
  type        = number
  default     = 3000
}

variable "server_cpu" {
  description = "vCPUs allocated to the server Cloud Run container. Must be >= 1: below that, Cloud Run silently caps max_instance_request_concurrency at 1 (vs. 80 for cpu >= 1), which with only 1 instance allowed (server_max_instance_count) limits the whole service to one in-flight request at a time and causes bursty page loads (many JS chunks/API calls fired in parallel) to 429 instead of queuing."
  type        = string
  default     = "1"
}

variable "server_memory" {
  description = "Memory allocated to the server Cloud Run container. Cloud Run requires at least 512Mi when cpu < 1."
  type        = string
  default     = "512Mi"
}

variable "server_min_instance_count" {
  description = "Minimum number of server instances. Kept at 1 so websocket connections for real-time collaboration stay warm and there's always an instance available -- at 0, a busy/cold-starting single instance combined with server_max_instance_count = 1 left no capacity for concurrent requests, surfacing as \"no available instance\" rejections (e.g. \"Upload failed\" on import)."
  type        = number
  default     = 1
}

variable "server_max_instance_count" {
  description = "Maximum number of server instances. Kept above 1 so a busy instance (e.g. processing a workspace import) doesn't leave the whole service with no capacity to burst to, which surfaced as \"no available instance\" rejections (e.g. \"Upload failed\" on import) even with server_min_instance_count = 1."
  type        = number
  default     = 2
}

variable "storage_bucket_location" {
  description = "Location for the GCS bucket backing Outline's file storage. Defaults to `region` if unset."
  type        = string
  default     = null
}

variable "file_storage_upload_max_size" {
  description = "Maximum allowed size, in bytes, for an uploaded attachment (FILE_STORAGE_UPLOAD_MAX_SIZE)."
  type        = number
  default     = 262144000
}

variable "default_language" {
  description = "Default interface language (DEFAULT_LANGUAGE). See translate.getoutline.com for available language codes."
  type        = string
  default     = "en_US"
}

variable "enable_updates" {
  description = "Whether to check for updates by sending anonymized statistics to the Outline maintainers (ENABLE_UPDATES)."
  type        = bool
  default     = true
}

variable "auth_env" {
  description = "Third-party sign-in provider credentials (e.g. GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, SLACK_CLIENT_ID, OIDC_CLIENT_SECRET). At least one provider's credentials are required for Outline to have a working sign-in option. Each entry is stored as its own Secret Manager secret and exposed to the container under the given env var name. See https://docs.getoutline.com for supported providers."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "smtp_env" {
  description = "SMTP settings for outgoing transactional email (e.g. SMTP_SERVICE, SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM_EMAIL). Optional -- if unset, Outline sends no email. Each entry is stored as its own Secret Manager secret and exposed to the container under the given env var name. See https://docs.getoutline.com/s/hosting/doc/smtp-cqCJyZGMIB."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "labels" {
  description = "Labels applied to all resources that support them."
  type        = map(string)
  default = {
    app        = "outline"
    managed-by = "terraform"
  }
}
