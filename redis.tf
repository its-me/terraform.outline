# Shared Memorystore Redis instance for all app deployments in this project.
# terraform.twenty is the owning caller (create = true); this is a consuming caller
# (create = false) that reads the same `name` back instead of creating its own.
# Each caller isolates its keys via its own var.redis_db index.
module "redis" {
  source = "git::https://github.com/its-me/terraform.module.redis.git?ref=v0.1.0"

  project_id = var.project_id
  region     = var.region
  name       = var.redis_instance_name
  create     = false
}
