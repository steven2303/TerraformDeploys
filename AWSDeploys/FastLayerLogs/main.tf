module "glue_module" {
  source = "./modulos/glue"
  glue_audit_log_job_name       = var.glue_audit_log_job_name
  glue_audit_log_script_location_s3 = var.glue_audit_log_script_location_s3
  glue_audit_log_database_name  = var.glue_audit_log_database_name
  glue_audit_log_crawler_name   = var.glue_audit_log_crawler_name
  glue_audit_log_crawler_paths  = var.glue_audit_log_crawler_paths
  glue_audit_log_iam_role_arn = var.glue_audit_log_iam_role_arn
  s3_audit_logs_processed_bucket_name = module.s3_module.s3_audit_logs_processed_bucket_name
  providers = {
    aws = aws.virginia
  }
}

module "lambda_module" {
  source = "./modulos/lambda"
  lambda_s3_event_trigger_function_name    = var.lambda_s3_event_trigger_function_name
  lambda_glue_status_monitor_function_name = var.lambda_glue_status_monitor_function_name
  sfn_state_machine_arn = module.sfn_module.sfn_state_machine_arn
  audit_log_sqs_queue_arn = module.sqs_module.audit_log_sqs_queue_arn
  lambda_audit_log_iam_role_arn = var.lambda_audit_log_iam_role_arn
  lambda_raw_sftp_s3_audit_log_mover_function_name = var.lambda_raw_sftp_s3_audit_log_mover_function_name
  sftp_audit_log_bucket_name = var.sftp_audit_log_bucket_name
  audit_log_landing_bucket_name = var.audit_log_landing_bucket_name
  audit_log_landing_bucket_prefixes = var.audit_log_landing_bucket_prefixes
  glue_s3_audit_log_destination_location = "s3://${module.s3_module.s3_audit_logs_processed_bucket_name}/${var.glue_audit_log_crawler_paths[0]}"
  glue_s3_audit_log_error_location = "s3://${module.s3_module.s3_audit_logs_processed_bucket_name}/${var.glue_s3_audit_log_error_location}"
  lambda_pgmmaster_log_processor_function_name = var.lambda_pgmmaster_log_processor_function_name
  lambda_s3_pgmmaster_log_destination_location = "s3://${module.s3_module.s3_audit_logs_processed_bucket_name}/${var.glue_audit_log_crawler_paths[1]}"
  pgmmaster_log_bucket_name = split("/",replace("s3://${module.s3_module.s3_audit_logs_processed_bucket_name}/${var.glue_audit_log_crawler_paths[1]}","s3://",""))[0]
  sqs_queue_url = module.sqs_module.sqs_queue_url
  kms_audit_log_arn = module.kms_module.kms_audit_log_arn
  providers = { 
    aws = aws.virginia
  }
}

module "s3_module" {
  source = "./modulos/s3"
  audit_log_landing_bucket_name    = var.audit_log_landing_bucket_name
  audit_log_landing_bucket_prefix = var.audit_log_landing_bucket_prefixes[0]
  audit_log_sqs_queue_arn = module.sqs_module.audit_log_sqs_queue_arn
  sftp_audit_log_bucket_name = var.sftp_audit_log_bucket_name
  raw_sftp_audit_log_lambda_queue_arn = module.lambda_module.lambda_raw_sftp_s3_audit_log_mover_function_arn
  sftp_audit_log_bucket_prefixes = var.sftp_audit_log_bucket_prefixes
  lambda_pgmmaster_log_processor_function_arn = module.lambda_module.lambda_pgmmaster_log_processor_function_arn
  pgmmaster_log_processor_bucket_prefix = var.audit_log_landing_bucket_prefixes[1]
  s3_audit_logs_processed_bucket_name = var.s3_audit_logs_processed_bucket_name
  providers = {
    aws = aws.virginia
  }
}

module "sns_module" {
  source = "./modulos/sns"
  email_endpoints    = var.email_endpoints
  sns_etl_job_topic_name = var.sns_etl_job_topic_name
  providers = {
    aws = aws.virginia
  }
}

module "sqs_module" {
  source = "./modulos/sqs"
  audit_log_sqs_queue_name    = var.audit_log_sqs_queue_name
  audit_log_landing_bucket_name = var.audit_log_landing_bucket_name
  kms_audit_log_arn = module.kms_module.kms_audit_log_arn
  providers = {
    aws = aws.virginia
  }
}

module "kms_module" {
  source = "./modulos/kms"
  lambda_role_arn = module.lambda_module.lambda_role_arn
  providers = {
    aws = aws.virginia
  }
}

module "sfn_module" {
  source = "./modulos/sfn"
  sfn_state_machine_name    = var.sfn_state_machine_name
  glue_audit_log_job_name = module.glue_module.glue_audit_log_job_name
  glue_audit_log_crawler_name = module.glue_module.glue_audit_log_crawler_name
  lambda_glue_status_monitor_function_arn = module.lambda_module.lambda_glue_status_monitor_function_arn
  sns_etl_job_topic_arn = module.sns_module.sns_etl_job_topic_arn
  sfn_audit_log_iam_role_arn = var.sfn_audit_log_iam_role_arn
  providers = {
    aws = aws.virginia
  }
}