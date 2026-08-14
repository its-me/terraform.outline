resource "random_password" "db" {
  length  = 32
  special = false
}

# Shared Cloud SQL instance for all app deployments in this project.
# terraform.twenty is the owning caller (create = true); this is a consuming caller
# (create = false) that reads the same `name` back instead of creating its own,
# managing its own database/user on top.
module "postgresql" {
  source = "git::https://github.com/its-me/terraform.module.postgresql.git?ref=main"

  project_id = var.project_id
  region     = var.region
  name       = var.db_instance_name
  create     = false
}

resource "google_sql_database" "outline" {
  name     = var.db_name
  project  = var.project_id
  instance = module.postgresql.instance_name
}

resource "google_sql_user" "outline" {
  name     = var.db_user
  project  = var.project_id
  instance = module.postgresql.instance_name
  password = random_password.db.result
}
