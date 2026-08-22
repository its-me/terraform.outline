locals {
  image = "docker.getoutline.com/outlinewiki/outline:${var.image_tag}"

  # Plain (non-secret) env vars.
  base_env = {
    NODE_ENV                  = "production"
    URL                       = "https://${var.domain}"
    PORT                      = "3000"
    REDIS_URL                 = local.redis_url
    FILE_STORAGE              = "s3"
    AWS_REGION                = "auto"
    AWS_S3_UPLOAD_BUCKET_NAME = google_storage_bucket.outline_files.name
    AWS_S3_UPLOAD_BUCKET_URL  = "https://storage.googleapis.com/${google_storage_bucket.outline_files.name}"
    AWS_S3_FORCE_PATH_STYLE   = "true"
    AWS_S3_ACL                = "private"
    # Standard AWS SDK credential env var, used by Outline's S3 storage driver
    # against GCS's S3-interoperability API (no IAM-role credential chain on GCP).
    AWS_ACCESS_KEY_ID = google_storage_hmac_key.outline_files.access_id
  }

  # Secret-backed env vars: map of env var name -> key into google_secret_manager_secret.outline.
  fixed_secret_env = {
    SECRET_KEY            = "secret-key"
    UTILS_SECRET          = "utils-secret"
    DATABASE_URL          = "database-url"
    AWS_SECRET_ACCESS_KEY = "storage-secret-access-key"
  }

  # Merges the fixed secrets above with the pluggable auth-provider secrets from
  # var.auth_env into a single env-var-name -> secret_id map for the dynamic block below.
  secret_env_ids = merge(
    { for env_name, key in local.fixed_secret_env : env_name => google_secret_manager_secret.outline[key].secret_id },
    { for env_name in local.auth_env_keys : env_name => google_secret_manager_secret.outline_auth[env_name].secret_id },
  )
}

resource "google_cloud_run_v2_service" "server" {
  name                = "outline"
  project             = var.project_id
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.server_min_instance_count
      max_instance_count = var.server_max_instance_count
    }

    vpc_access {
      connector = module.network.vpc_connector_id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    containers {
      name  = "server"
      image = local.image

      ports {
        container_port = 3000
      }

      resources {
        limits = {
          cpu    = var.server_cpu
          memory = var.server_memory
        }
      }

      dynamic "env" {
        for_each = local.base_env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = local.secret_env_ids
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }

      startup_probe {
        http_get {
          path = "/_health"
          port = 3000
        }
        initial_delay_seconds = 10
        period_seconds        = 5
        failure_threshold     = 20
        timeout_seconds       = 5
      }

      liveness_probe {
        http_get {
          path = "/_health"
          port = 3000
        }
        period_seconds  = 10
        timeout_seconds = 5
      }
    }
  }

  depends_on = [
    module.postgresql,
    module.redis,
    google_secret_manager_secret_version.outline,
    google_secret_manager_secret_version.outline_auth,
  ]
}
