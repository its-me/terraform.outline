resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "outline-cloud-run"
  display_name = "Outline Cloud Run"
}

resource "google_project_iam_member" "cloud_run_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_secret_manager_secret_iam_member" "cloud_run_secret_access" {
  for_each = merge(google_secret_manager_secret.outline, google_secret_manager_secret.outline_auth)

  project   = var.project_id
  secret_id = each.value.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}
