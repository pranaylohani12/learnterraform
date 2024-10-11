# Create google cloud storage bucket that will host the source code

#tfsec:ignore:google-storage-bucket-encryption-customer-key

resource "google_storage_bucket" "logs" {
  #checkov:skip=CKV_GCP_83 Skipped the CSEK related checks as we are not using CSEK in our environment
  #checkov:skip=CKV_GCP_62 Skipped logging for the logging bucket itself
  name                        = "${local.base_name}-logs"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "bucket" {
  #checkov:skip=CKV_GCP_83 Skipped the CSEK related checks as we are not using CSEK in our environment
  name                        = "${local.base_name}-data"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true
  public_access_prevention    = "enforced"
  versioning {
    enabled = true
  }
  logging {
    log_bucket = google_storage_bucket.logs.name
  }
}
