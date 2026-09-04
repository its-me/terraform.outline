output "cloud_run_url" {
  description = "Auto-generated Cloud Run URL for the server (works immediately, before DNS/SSL cert provisioning finishes)."
  value       = google_cloud_run_v2_service.server.uri
}

output "domain" {
  description = "Custom domain to create a DNS A record for. Points at the shared load balancer's IP (see terraform.infrastructure's load_balancer_ip output)."
  value       = var.domain
}

output "postgresql_instance_name" {
  description = "Name of the shared Cloud SQL instance."
  value       = module.postgresql.instance_name
}

output "postgresql_private_ip" {
  description = "Private IP address of the Cloud SQL instance."
  value       = module.postgresql.instance_private_ip
}

output "postgresql_port" {
  description = "Port the Cloud SQL Postgres instance listens on."
  value       = module.postgresql.port
}

output "postgresql_instance_connection_name" {
  description = "Cloud SQL instance connection name."
  value       = module.postgresql.instance_connection_name
}

output "redis_instance_name" {
  description = "Name of the shared Memorystore Redis instance."
  value       = module.redis.instance_name
}

output "redis_host" {
  description = "Private IP address of the Memorystore Redis instance."
  value       = module.redis.host
}

output "redis_port" {
  description = "Port the Memorystore Redis instance listens on."
  value       = module.redis.port
}

output "storage_bucket" {
  description = "GCS bucket backing Outline's file storage."
  value       = google_storage_bucket.outline_files.name
}
