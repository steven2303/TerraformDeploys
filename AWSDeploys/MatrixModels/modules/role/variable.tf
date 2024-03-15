variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my_project"
}

variable "s3_matrix_models_bucket_name" {
  description = "The name of the S3 bucket for matrix models"
  type        = string
}

variable "secrets_manager_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  type        = string
}

variable "aurora_cluster_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  type        = string
}

variable "secrets_manager_secret_name" {
  description = "The name of the secret in AWS Secrets Manager"
  type        = string
}


variable "account_b_id" {}
variable "lambda_execution_role_name_account_b"{}
variable glue_connection_name {}
variable lambda_security_group_name {}