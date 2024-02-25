variable "audit_log_landing_bucket_name" {
  description = "The name of the S3 bucket used for landing audit logs"
  type        = string
}

variable "audit_log_landing_bucket_prefix" {
  description = "The S3 bucket prefix for audit log files"
  type        = string
}

variable "audit_log_sqs_queue_arn" {
  description = "ARN of the SQS queue"
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

variable "raw_sftp_audit_log_lambda_queue_arn" {
  description = "ARN of the Lambda function"
  type        = string
}

variable "lambda_pgmmaster_log_processor_function_arn" {
  description = "ARN of the Lambda function"
  type        = string
}

variable "pgmmaster_log_processor_bucket_prefix" {
  description = "The S3 bucket prefix for the pgm master file"
  type        = string
}

variable "s3_audit_logs_processed_bucket_name" {
  description = "The name of the S3 bucket used for storing the processed data"
  type        = string
}
