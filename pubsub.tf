# create pub/sub topic
resource "google_pubsub_topic" "notifications_topic" {
  #checkov:skip=CKV_GCP_83 Skipped as we are not using CSEK in our environment. Encrypted using Google Managed Keys at rest
  name = "${local.base_name}-notifications-topic"
}

resource "google_pubsub_schema" "database_topic_schema" {
  name       = "${local.base_name}-schema-for-bq"
  type       = "AVRO"
  definition = <<AVRO_SCHEMA
  {
    "type": "record",
    "name": "Avro",
    "fields": [
      {
        "name": "UserId",
        "type": "string"
      },
      {
        "name": "CSP",
        "type": "string"
      },
      {
        "name": "Project_Id",
        "type": "string"
      },
      {
        "name": "Project_Name",
        "type": "string"
      }
    ]
  }
  AVRO_SCHEMA
}

resource "google_pubsub_topic" "database_topic" {
  #checkov:skip=CKV_GCP_83 Skipped as we are not using CSEK in our environment. Encrypted using Google Managed Keys at rest
  depends_on = [google_pubsub_schema.database_topic_schema]
  name       = "${local.base_name}-database-topic"
  schema_settings {
    schema   = "projects/${var.project}/schemas/${google_pubsub_schema.database_topic_schema.name}"
    encoding = "JSON"
  }
}

resource "google_pubsub_subscription" "updatebq" {
  name  = "${local.base_name}-updatebq"
  topic = google_pubsub_topic.database_topic.name

  bigquery_config {
    table               = "${var.project}:${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.default.table_id}"
    use_topic_schema    = true
    write_metadata      = false
    drop_unknown_fields = true
  }

  depends_on = [google_bigquery_table.default]
}
