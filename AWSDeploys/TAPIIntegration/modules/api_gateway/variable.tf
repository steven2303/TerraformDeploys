variable "api_name" {}
variable "api_description" {}
variable "resource_path" {}
variable "stage_name" {}

# Data source para obtener la región actual
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}