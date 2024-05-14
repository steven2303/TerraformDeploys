# Data source para obtener el ID de la cuenta actual
data "aws_caller_identity" "current" {}

# Data source para obtener la región actual
data "aws_region" "current" {}