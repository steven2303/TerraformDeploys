resource "aws_lambda_function" "api_caller_lambda" {
  function_name = "APICallerLambda"
  handler       = "APICallerLambda.lambda_handler"
  runtime       = "python3.10"
  filename      = "scripts/APICallerLambda.zip"
  role          = aws_iam_role.lambda_role.arn
  memory_size   = 128
  timeout       = 30
  
  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }
}

resource "aws_lambda_alias" "api_caller_dev_alias" {
  name             = "dev"
  function_name    = aws_lambda_function.api_caller_lambda.function_name
  function_version = "$LATEST"
  description      = "Alias for API invocation in the Fast Layer Account development environment"
}
