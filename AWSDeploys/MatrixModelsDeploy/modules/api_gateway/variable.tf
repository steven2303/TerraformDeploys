variable "api_name" {}
variable "api_description" {}
variable "resource_path" {}
variable "stage_name" {}
variable lambda_execution_role_name_account_b {}
variable account_b_id {}

# Data source para obtener la región actual
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}