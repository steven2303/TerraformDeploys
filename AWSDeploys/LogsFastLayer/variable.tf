variable "glue_audit_log_job_name" {
  description = "Name assigned to the AWS Glue job, identifying its purpose or function"
  type        = string
}

variable "glue_audit_log_crawler_name" {
  description = "Identifier for the AWS Glue crawler, used for cataloging data sources"
  type        = string
}

variable "glue_audit_log_database_name" {
  description = "Name of the AWS Glue database specifically designed for storing audit logs"
  type        = string
}

variable "glue_audit_log_crawler_paths" {
  description = "List of S3 path locations for the Glue Crawler"
  type        = list(string)
}


variable "lambda_s3_event_trigger_function_name" {
  description = "The name of the Lambda function that triggers on S3 events"
  type        = string
}

variable "lambda_glue_status_monitor_function_name" {
  description = "The name of the Lambda function that checks the status of a Glue job"
  type        = string
}


variable "audit_log_landing_bucket_name" {
  description = "The name of the S3 bucket used for landing audit logs"
  type        = string
}

variable "audit_log_landing_bucket_prefixes" {
  description = "Lista de prefijos de bucket para notificaciones de la cola"
  type        = list(string)
}


variable "email_endpoints" {
  description = "List of email addresses for ETL job status notifications"
  type        = list(string)
}

variable "sns_etl_job_topic_name" {
  description = "The name of the SNS topic for ETL job notifications"
  type        = string
}

variable "audit_log_sqs_queue_name" {
  description = "The name of the SQS queue for audit log events"
  type        = string
}

variable "sfn_state_machine_name" {
  description = "The name of the AWS Step Functions state machine for log processing"
  type        = string
}

variable "lambda_raw_sftp_s3_audit_log_mover_function_name" {
  description = "The name of the Lambda function that moves the raw sftp log file"
  type        = string
}

variable "sftp_audit_log_bucket_name" {
  description = "The name of the S3 raw sftp bucket used for the audit logs"
  type        = string
}

variable "sftp_audit_log_bucket_prefixes" {
  description = "Lista de prefijos de bucket para notificaciones de Lambda"
  type        = list(string)
}

variable "glue_s3_audit_log_error_location" {
  description = "The name of the S3 location where the audit logs errors are being stored"
  type        = string
}

variable "lambda_pgmmaster_log_processor_function_name" {
  description = "The name of the Lambda function that processes the PGM Master logs"
  type        = string
}

variable "s3_audit_logs_processed_bucket_name" {
  description = "The name of the S3 bucket used for storing the processed data"
  type        = string
}

variable "s3_resources_bucket_name" {
  description = "The name of the S3 bucket used for storing the resources of the project"
  type        = string
}

variable "full_audit_log_key_path" {
  description = "The key of the S3 bucket where the logs historical data is stored"
  type        = string
}

variable "perfil_despliegue"{
  type        = string
}
