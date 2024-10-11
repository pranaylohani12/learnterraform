resource "google_bigquery_dataset" "default" {
  #checkov:skip=CKV_GCP_81 Skipped as we are not using CSEK in our environment. Encrypted using Google Managed Keys at rest
  dataset_id    = "${lower(replace(local.base_name, "-", ""))}_bq_dataset" # bqdatasetid only takes underscore and not hyphens
  friendly_name = "${lower(replace(local.base_name, "-", ""))}_bq_dataset"
  description   = "This is storing info related to experimental environment"
  location      = var.region

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  #checkov:skip=CKV_GCP_80 Skipped as we are not using CSEK in our environment. Encrypted using Google Managed Keys at rest
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = "${lower(replace(local.base_name, "-", ""))}_bq_table"
  deletion_protection = false

  labels = {
    env = "default"
  }

  schema = <<EOF
[
  {
    "name": "UserId",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The requestor email id"
  },
  {
    "name": "CSP",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The requested cloud provider"
  },
  {
    "name": "Project_Id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The project id created for the requestor"
  },
  {
    "name": "Project_Name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The project name created for the requestor"
  },
  {
    "name": "Project_Start",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Requestor's project start date"
  },
  {
    "name": "Project_End",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Requestor's project end date"
  },
  {
    "name": "Project_Billing",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Billing account associated with the requestor's project"
  },
  {
    "name": "Project_Budget",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Total budget allocated to the requestors project"
  },
  {
    "name": "Project_Status",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Requestor's project current status"
  },
  {
    "name": "data",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "To store extra mgs from the topic"
  }
]
EOF
}
