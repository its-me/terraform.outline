resource "google_redis_instance" "main" {
  name           = "outline-redis"
  project        = var.project_id
  region         = var.region
  tier           = var.redis_tier
  memory_size_gb = var.redis_memory_size_gb

  authorized_network      = google_compute_network.main.id
  connect_mode            = "PRIVATE_SERVICE_ACCESS"
  redis_version           = "REDIS_7_2"
  transit_encryption_mode = "DISABLED"

  labels = var.labels

  depends_on = [google_service_networking_connection.private_service_connection]
}
