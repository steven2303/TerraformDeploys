# Data source para obtener el ID de la cuenta actual
data "aws_caller_identity" "current" {}

# Data source para obtener la región actual
data "aws_region" "current" {}

#data "aws_s3_bucket" "mi_bucket" {
#  bucket = var.s3_resources_bucket_name
#}