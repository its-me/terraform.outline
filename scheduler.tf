# Outline relies on external cron calls to run its scheduled jobs (temp file cleanup,
# document popularity, email reminders, trash removal) -- there's no built-in scheduler.
# See https://docs.getoutline.com/s/hosting/doc/scheduled-jobs-RhZzCt770H
#
# The token is embedded in the job's URI (Cloud Scheduler's only auth option for a plain
# HTTP target), so anyone with read access to this Cloud Scheduler job (not just Secret
# Manager access to utils-secret) can see it -- a broader exposure than the secret gets
# elsewhere in this config, but unavoidable given Outline's own auth mechanism for this
# endpoint (a query/body token, not a bearer/OIDC header).
resource "google_cloud_scheduler_job" "outline_cron_hourly" {
  name      = "outline-cron-hourly"
  project   = var.project_id
  region    = var.region
  schedule  = "0 * * * *"
  time_zone = "Etc/UTC"

  http_target {
    uri         = sensitive("https://${var.domain}/api/cron.hourly?token=${random_id.utils_secret.hex}")
    http_method = "GET"
  }

  depends_on = [google_project_service.apis]
}

resource "google_cloud_scheduler_job" "outline_cron_daily" {
  name      = "outline-cron-daily"
  project   = var.project_id
  region    = var.region
  schedule  = "0 3 * * *"
  time_zone = "Etc/UTC"

  http_target {
    uri         = sensitive("https://${var.domain}/api/cron.daily?token=${random_id.utils_secret.hex}")
    http_method = "GET"
  }

  depends_on = [google_project_service.apis]
}
