provider "google" {
  project = var.gcpproject
  region  = var.region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.78.0"
    }
  }
}
