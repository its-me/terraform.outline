# Cloud Run only pulls from gcr.io, docker.pkg.dev, or docker.io -- not arbitrary
# registries like docker.getoutline.com. This remote repository proxies that upstream
# through Artifact Registry so Cloud Run has a supported host to pull from.
resource "google_artifact_registry_repository" "outline_upstream" {
  project       = var.project_id
  location      = var.region
  repository_id = "outline-upstream"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config {
    description = "Proxies docker.getoutline.com for the Outline server image."

    docker_repository {
      custom_repository {
        uri = "https://docker.getoutline.com"
      }
    }
  }

  depends_on = [google_project_service.apis]
}
