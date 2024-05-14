variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "my_project"
}


#variable "lambda_subnet_ids" {}

# variable "lambda_security_group_ids" {}

variable "account_a_id" {
  description = "The AWS Account ID of Account A"
  type        = string
}

variable "lambda_execution_role_name_account_a" {
  description = "The name of the IAM role for Lambda execution in Account A"
  type        = string
  default     = "LambdaExecutionRole"
}