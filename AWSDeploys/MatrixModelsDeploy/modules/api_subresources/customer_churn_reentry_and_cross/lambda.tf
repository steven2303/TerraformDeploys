resource "aws_lambda_function" "lambda" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  filename      = var.filename
  source_code_hash = var.source_code_hash
  role          = var.role_arn
  layers        = var.layers
  memory_size   = var.memory_size
  timeout       = var.timeout

  environment {
    variables = var.environment_variables
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_lambda_alias" "alias" {
  name             = var.alias_name
  function_name    = aws_lambda_function.lambda.function_name
  function_version = "$LATEST"
  description      = var.alias_description
}