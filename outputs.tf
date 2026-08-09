output "load_balancer_ip" {
  description = "Global external IP of the load balancer. Point an A record for var.domain at this."
  value       = google_compute_global_address.server_lb_ip.address
}

output "cloud_run_url" {
  description = "Auto-generated Cloud Run URL for the server (works immediately, before DNS/SSL cert provisioning finishes)."
  value       = google_cloud_run_v2_service.server.uri
}

output "domain" {
  description = "Custom domain to create a DNS A record for, pointing at load_balancer_ip."
  value       = var.domain
}

output "db_instance_connection_name" {
  description = "Cloud SQL instance connection name."
  value       = google_sql_database_instance.main.connection_name
}

output "db_private_ip" {
  description = "Private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.main.private_ip_address
}

output "redis_host" {
  description = "Private IP address of the Memorystore Redis instance."
  value       = google_redis_instance.main.host
}

output "storage_bucket" {
  description = "GCS bucket backing Outline's file storage."
  value       = google_storage_bucket.outline_files.name
}
