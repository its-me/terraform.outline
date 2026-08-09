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

# Shared VPC network/subnet/connector for all Wheelers app deployments in this project.
# terraform.twenty is the owning caller (create = true); this is a consuming caller
# (create = false) that reads the same `name` back instead of creating its own.
module "network" {
  source = "git::https://github.com/its-me/terraform.module.network.git"

  project_id = var.project_id
  region     = var.region
  name       = "wheelers"
  create     = false

  depends_on = [google_project_service.apis]
}
