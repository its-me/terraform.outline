locals {
  required_apis = [
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "vpcaccess.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.required_apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Shared VPC network/subnet/connector for all app deployments in this project.
# Owned and created by terraform.infrastructure; every app (this one included) just
# reads it back (create = false).
module "network" {
  source = "git::https://github.com/its-me/terraform.module.network.git?ref=v0.1.0"

  project_id = var.project_id
  region     = var.region
  name       = var.network_name
  create     = false

  depends_on = [google_project_service.apis]
}
