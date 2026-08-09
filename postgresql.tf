resource "random_password" "db" {
  length  = 32
  special = false
}

resource "google_sql_database_instance" "main" {
  name             = "outline-postgres"
  project          = var.project_id
  region           = var.region
  database_version = "POSTGRES_16"

  deletion_protection = true

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_size         = var.db_disk_size_gb
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false
      private_network = module.network.network_id
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    user_labels = var.labels
  }

  depends_on = [module.network]
}

resource "google_sql_database" "outline" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "outline" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  password = random_password.db.result
}
