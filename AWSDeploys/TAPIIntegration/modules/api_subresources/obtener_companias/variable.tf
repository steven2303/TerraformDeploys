variable "resource_path" {}
variable "http_method" {}
variable "stage_name" {}
variable parent_id {}
variable parent_path {}
variable api_id {}
variable api_arn {}

variable "function_name" {}
variable "handler" {}
variable "runtime" {}
variable "filename" {}
variable "source_code_hash" {}
#variable "role_arn" {}
variable "layers" {}
variable "memory_size" {}
variable "timeout" {}
#variable "environment_variables" {}
variable "subnet_ids" {}
variable "security_group_ids" {}
variable "alias_name" {}
variable "alias_description" {}

# Data source para obtener la región actual
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_role" "lambda_role" {
  name = "deploy0703-v0-RoleLambda-GEHzWxwZ6SiK"
}