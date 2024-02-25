resource "aws_glue_job" "glue_audit_log_etl_job" {
  name                      = var.glue_audit_log_job_name
  role_arn                  = aws_iam_role.glue_etl_role.arn # var.glue_audit_log_iam_role_arn ########################################## ROL AQUI
  glue_version              = "4.0"
  execution_property {
    max_concurrent_runs = 4
  }
  command {
    name            =  "glueetl"
    script_location = var.glue_audit_log_script_location_s3
    python_version  = "3"
  }
  number_of_workers = 2
  worker_type       = "G.1X"
  timeout      = 2880
}

resource "aws_glue_job" "glue_audit_log_etl_job_full" {
  name                      = "${var.glue_audit_log_job_name}Full"
  role_arn                  = aws_iam_role.glue_etl_role.arn
  glue_version              = "4.0"
  execution_property {
    max_concurrent_runs = 4
  }
  command {
    name            =  "glueetl"
    script_location = replace(var.glue_audit_log_script_location_s3, ".py", "Full.py")
    python_version  = "3"
  }
  number_of_workers = 5
  worker_type       = "G.1X"
  timeout      = 2880
}

resource "aws_glue_catalog_database" "glue_audit_log_catalog_database" {
  name = var.glue_audit_log_database_name
}

resource "aws_glue_crawler" "glue_audit_log_crawler" {
  name          = var.glue_audit_log_crawler_name
  database_name = aws_glue_catalog_database.glue_audit_log_catalog_database.name
  role          = aws_iam_role.glue_etl_role.arn # var.glue_audit_log_iam_role_arn ########################################## ROL AQUI
  dynamic "s3_target" {
    for_each = var.glue_audit_log_crawler_paths

    content {
      #path = s3_target.value
      path = "s3://${var.s3_audit_logs_processed_bucket_name}/${s3_target.value}"
    }
  }

  schema_change_policy {
    delete_behavior = "DELETE_FROM_DATABASE"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}
