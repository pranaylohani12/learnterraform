locals {
  base_name = "${var.name_pattern}-${var.project_name}-${var.env}"
}

# Google provider is in use to setup services in GCP
provider "google" {
  project = var.project
  region  = var.region
}

# for each loop is used here to create cloud functions one by one
module "all_http_cloud_functions" {
  source                     = "./modules/http_cloud_function"
  env                        = var.env
  project                    = var.project
  region                     = var.region
  service_account_email      = var.cf_service_account
  google_storage_bucket_name = google_storage_bucket.bucket.name

  for_each             = var.httpgooglecloudfunctions
  function_name        = "${local.base_name}-${each.value.function_name}"
  function_entry_point = each.value.function_entry_point
  function_runtime     = each.value.function_runtime
  function_source_code = each.value.function_src_code

  env_vars = merge(each.value.env_vars, {
    GCLOUD_PROJECT = var.project
    ENV            = var.env
    REGION         = var.region
  })
}

# for each loop is used here to create cloud functions one by one
module "all_pubsub_cloud_functions" {
  source                     = "./modules/pubsub_cloud_function"
  env                        = var.env
  project                    = var.project
  region                     = var.region
  service_account_email      = var.cf_service_account
  google_storage_bucket_name = google_storage_bucket.bucket.name

  for_each                 = var.pubsubgooglecloudfunctions
  function_name            = "${local.base_name}-${each.value.function_name}"
  function_entry_point     = each.value.function_entry_point
  function_runtime         = each.value.function_runtime
  function_source_code     = each.value.function_src_code
  google_pubsub_topic_name = "${local.base_name}-${each.value.function_topic_name}"
  env_vars = merge(each.value.env_vars, {
    GCLOUD_PROJECT = var.project
    ENV            = var.env
    REGION         = var.region
  })
}
