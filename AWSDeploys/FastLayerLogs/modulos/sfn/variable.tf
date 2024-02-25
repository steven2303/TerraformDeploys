variable "sfn_state_machine_name" {
  description = "The name of the AWS Step Functions state machine for log processing"
  type        = string
}

variable "glue_audit_log_job_name" {
  description = "Name assigned to the AWS Glue job, identifying its purpose or function"
  type        = string
}

variable "glue_audit_log_crawler_name" {
  description = "Identifier for the AWS Glue crawler, used for cataloging data sources"
  type        = string
}

variable "lambda_glue_status_monitor_function_arn" {
  description = "The ARN of the Lambda function that checks the status of a Glue job"
  type        = string
}

variable "sns_etl_job_topic_arn" {
  description = "The ARN of the SNS topic for ETL job notifications"
  type        = string
}

variable "sfn_audit_log_iam_role_arn" {
  description = "ARN of the IAM role for AWS Step function service"
  type        = string
}
