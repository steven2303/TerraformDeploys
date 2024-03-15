variable "api_name" {}
variable "api_description" {}
variable "resource_path" {}
variable "http_method" {}
variable "stage_name" {}

variable "function_name" {}
variable "handler" {}
variable "runtime" {}
variable "filename" {}
variable "role_arn" {}
variable "layers" {}
variable "memory_size" {}
variable "timeout" {}
variable "environment_variables" {}
variable "subnet_ids" {}
variable "security_group_ids" {}
variable "alias_name" {}
variable "alias_description" {}
variable "account_b_id" {}
variable "lambda_execution_role_name_account_b" {}

# Data source para obtener la región actual
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}