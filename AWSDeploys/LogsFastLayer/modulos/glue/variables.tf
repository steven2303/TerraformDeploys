variable "glue_audit_log_job_name" {
  description = "Name assigned to the AWS Glue job, identifying its purpose or function"
  type        = string
}

variable "glue_audit_log_crawler_name" {
  description = "Identifier for the AWS Glue crawler, used for cataloging data sources"
  type        = string
}

variable "glue_audit_log_script_location_s3" {
  description = "S3 bucket location where the PySpark script for the Glue job is stored"
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

#variable "glue_audit_log_iam_role_arn" {
#  description = "ARN of the IAM role for AWS Glue service"
#  type        = string
#}

variable "s3_audit_logs_processed_bucket_name" {
  description = "The name of the S3 bucket used for storing the processed data"
  type        = string
}

variable "upload_scripts_arn" {
  type = list(string)
}

variable "audit_log_input_full_path" {
  description = "The key of the S3 bucket where the logs historical data is stored"
  type        = string
}

variable "audit_log_output_path" {
  description = "The name of the S3 location where the audit logs are being stored after being processed"
  type        = string
}

variable "audit_log_error_path" {
  description = "The name of the S3 location where the audit logs errors are being stored"
  type        = string
}