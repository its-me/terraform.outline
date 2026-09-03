# Shared Cloud SQL instance for all app deployments in this project.
# terraform.twenty is the owning caller (create = true); this is a consuming caller
# (create = false) that reads the same `name` back instead of creating its own.
# Each caller still manages its own database/user via the module.
module "postgresql" {
  source = "git::https://github.com/its-me/terraform.module.postgresql.git?ref=v0.1.3"

  project_id = var.project_id
  region     = var.region
  name       = var.db_instance_name
  create     = false

  database_name = var.db_name
  database_user = var.db_user
}
