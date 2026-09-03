# Hex-encoded 32-byte keys, as required by Outline for SECRET_KEY/UTILS_SECRET
# (see .env.sample: "Generate a hex-encoded 32-byte random key").
resource "random_id" "secret_key" {
  byte_length = 32
}

resource "random_id" "utils_secret" {
  byte_length = 32
}

locals {
  database_url = "postgres://${var.postgresql_user}:${module.postgresql.database_password}@${module.postgresql.instance_private_ip}:5432/${var.postgresql_name}"
  redis_url    = "redis://${module.redis.host}:${module.redis.port}/${var.redis_db}"

  secrets = {
    secret-key                = random_id.secret_key.hex
    utils-secret              = random_id.utils_secret.hex
    database-url              = local.database_url
    storage-secret-access-key = google_storage_hmac_key.outline_files.secret
  }
}

resource "google_secret_manager_secret" "outline" {
  for_each = local.secrets

  project   = var.project_id
  secret_id = "outline-${each.key}"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "outline" {
  for_each = local.secrets

  secret      = google_secret_manager_secret.outline[each.key].id
  secret_data = each.value
}

# Third-party sign-in provider credentials (at least one is required for Outline to
# have any working sign-in option, e.g. GOOGLE_CLIENT_ID/GOOGLE_CLIENT_SECRET). Supplied
# via var.auth_env since the set of providers/credentials is deployment-specific.
#
# var.auth_env is sensitive, so its keys are pulled out via nonsensitive() for use as
# for_each identifiers (Terraform forbids sensitive values there); the credential values
# themselves stay sensitive throughout.
locals {
  auth_env_keys = nonsensitive(toset(keys(var.auth_env)))
}

resource "google_secret_manager_secret" "outline_auth" {
  for_each = local.auth_env_keys

  project   = var.project_id
  secret_id = "outline-auth-${lower(replace(each.value, "_", "-"))}"

  replication {
    auto {}
  }

  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret_version" "outline_auth" {
  for_each = local.auth_env_keys

  secret      = google_secret_manager_secret.outline_auth[each.value].id
  secret_data = var.auth_env[each.value]
}
