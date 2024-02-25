variable "audit_log_sqs_queue_name" {
  description = "The name of the SQS queue for audit log events"
  type        = string
}

variable "audit_log_landing_bucket_name" {
  description = "The name of the S3 bucket used for landing audit logs"
  type        = string
}
variable "kms_audit_log_arn" {
  type        = string
}
