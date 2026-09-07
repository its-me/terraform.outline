# Outline's FILE_STORAGE=s3 driver talks to any S3-compatible endpoint, so we point it at
# GCS's S3 interoperability API instead of provisioning a separate object store. This replaces
# the `storage-data` volume used for local file storage in docker-compose.yaml.
resource "google_storage_bucket" "outline_files" {
  name     = "${var.project_id}-outline"
  project  = var.project_id
  location = coalesce(var.storage_bucket_location, var.region)

  # Outline's S3 storage driver always sends an ACL (AWS_S3_ACL, "private" or
  # "public-read") on uploads -- GCS rejects any ACL when uniform bucket-level access
  # is on ("Cannot insert legacy ACL for an object..."), so it must stay off here even
  # though IAM (google_storage_bucket_iam_member below) already governs real access.
  uniform_bucket_level_access = false
  force_destroy               = false

  # Outline's browser client uploads attachments/avatars/workspace imports directly to
  # this bucket via a presigned URL, not through the server. Without CORS allowing
  # var.domain to make cross-origin PUT requests, the browser blocks the upload before
  # it leaves the client, surfacing as a generic "Upload failed" in the UI.
  cors {
    origin          = ["https://${var.domain}"]
    method          = ["GET", "HEAD", "PUT", "POST"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

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
