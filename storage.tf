# Outline's FILE_STORAGE=s3 driver talks to any S3-compatible endpoint, so we point it at
# GCS's S3 interoperability API instead of provisioning a separate object store. This replaces
# the `storage-data` volume used for local file storage in docker-compose.yaml.
resource "google_storage_bucket" "outline_files" {
  name     = "${var.project_id}-outline"
  project  = var.project_id
  location = coalesce(var.storage_bucket_location, var.region)

  uniform_bucket_level_access = true
  force_destroy               = false

  labels = var.labels
}

resource "google_storage_hmac_key" "outline_files" {
  project               = var.project_id
  service_account_email = google_service_account.cloud_run.email

  depends_on = [google_storage_bucket_iam_member.outline_files_writer]
}

resource "google_storage_bucket_iam_member" "outline_files_writer" {
  bucket = google_storage_bucket.outline_files.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}
