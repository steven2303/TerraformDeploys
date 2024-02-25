variable "lambda_s3_event_trigger_function_name" {
  description = "The name of the Lambda function that triggers on S3 events"
  type        = string
}

variable "lambda_glue_status_monitor_function_name" {
  description = "The name of the Lambda function that checks the status of a Glue job"
  type        = string
}

variable "lambda_raw_sftp_s3_audit_log_mover_function_name" {
  description = "The name of the Lambda function that moves the raw sftp log file"
  type        = string
}


variable "sfn_state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  type        = string
}

variable "audit_log_sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}

#variable "lambda_audit_log_iam_role_arn" {
#  description = "ARN of the IAM role for AWS Lambda service"
#  type        = string
#}

variable "sftp_audit_log_bucket_name" {
  description = "The name of the S3 bucket for sftp raw audit logs"
  type        = string
}

variable "audit_log_landing_bucket_name" {
  description = "The name of the S3 bucket for the audit logs"
  type        = string
}

variable "audit_log_landing_bucket_prefixes" {
  description = "Lista de prefijos de bucket para notificaciones de la cola"
  type        = list(string)
}

variable "glue_s3_audit_log_destination_location" {
  description = "The name of the S3 location where the audit logs are being stored after being processed"
  type        = string
}

variable "glue_s3_audit_log_error_location" {
  description = "The name of the S3 location where the audit logs errors are being stored"
  type        = string
}

variable "lambda_s3_pgmmaster_log_destination_location" {
  description = "The name of the S3 location where the pgm master are being stored"
  type        = string
}

variable "lambda_pgmmaster_log_processor_function_name" {
  description = "The name of the Lambda function that processes the PGM Master logs"
  type        = string
}

variable "pgmmaster_log_bucket_name" {
  description = "The name of the S3 bucket where the processed logs and master will be stored."
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the SQS queue"
  type        = string
}

variable "kms_audit_log_arn" {
  type        = string
}

