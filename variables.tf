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

variable "db_instance_name" {
  description = "Name of the shared Cloud SQL instance (see terraform.module.postgresql). Must match the value used by every other app sharing this instance."
  type        = string
  default     = "postgres"
}

variable "db_name" {
  description = "Postgres database name (matches the database in DATABASE_URL)."
  type        = string
  default     = "outline"
}

variable "db_user" {
  description = "Postgres user (matches the user in DATABASE_URL)."
  type        = string
  default     = "outline"
}

variable "redis_tier" {
  description = "Memorystore Redis service tier: BASIC (single node) or STANDARD_HA (replica + failover)."
  type        = string
  default     = "BASIC"
}

variable "redis_memory_size_gb" {
  description = "Memorystore Redis instance memory size in GB."
  type        = number
  default     = 1
}

variable "server_cpu" {
  description = "vCPUs allocated to the server Cloud Run container."
  type        = string
  default     = "1"
}

variable "server_memory" {
  description = "Memory allocated to the server Cloud Run container."
  type        = string
  default     = "1Gi"
}

variable "server_min_instance_count" {
  description = "Minimum number of server instances. Kept at 1 so websocket connections for real-time collaboration stay warm."
  type        = number
  default     = 1
}

variable "server_max_instance_count" {
  description = "Maximum number of server instances."
  type        = number
  default     = 3
}

variable "storage_bucket_location" {
  description = "Location for the GCS bucket backing Outline's file storage. Defaults to `region` if unset."
  type        = string
  default     = null
}

variable "auth_env" {
  description = "Third-party sign-in provider credentials (e.g. GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, SLACK_CLIENT_ID, OIDC_CLIENT_SECRET). At least one provider's credentials are required for Outline to have a working sign-in option. Each entry is stored as its own Secret Manager secret and exposed to the container under the given env var name. See https://docs.getoutline.com for supported providers."
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
