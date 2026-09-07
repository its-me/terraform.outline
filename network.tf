# Shared VPC network/subnet/connector for all app deployments in this project.
# Owned and created by terraform.infrastructure; every app (this one included) just
# reads it back (create = false).
module "network" {
  source = "git::https://github.com/its-me/terraform.module.network.git?ref=v0.1.1"

  project_id = var.project_id
  region     = var.region
  name       = var.network_name
  create     = false

  depends_on = [google_project_service.apis]
}
