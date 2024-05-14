# Data source para obtener el ID de la cuenta actual
data "aws_caller_identity" "current" {}

# Data source para obtener la región actual
data "aws_region" "current" {}

data "aws_iam_role" "lambda_role" {
  name = "bonus-qa-RoleLambda-LvTf9rIpBUe3"
}

data "aws_subnet" "subnet" {
  id = "subnet-0e90a1c84a0e17b47"  
}

data "aws_security_group" "sg" {
  id = "sg-09a7853ba75a4009a"  
}