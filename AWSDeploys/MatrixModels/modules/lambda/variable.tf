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

variable "lambda_subnet_ids" {
  description = "List of subnet IDs for the Lambda function"
  type        = list(string)
}

variable "lambda_security_group_ids" {
  description = "List of security group IDs for the Lambda function"
  type        = list(string)
}