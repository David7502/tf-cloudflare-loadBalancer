# provider.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "europe-west1"
}

# Activation des APIs
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
  disable_on_destroy = false
}
