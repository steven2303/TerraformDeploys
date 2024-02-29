resource "aws_lambda_function" "get_customer_recommender_profile_details" {
  function_name = "GetCustomerRecommenderProfileDetails"
  handler       = "GetCustomerRecommenderProfileDetails.lambda_handler"
  runtime       = "python3.10"
  filename      = "scripts/GetCustomerRecommenderProfileDetails.zip"
  role          = aws_iam_role.lambda_role.arn
  layers = ["arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size   = 128
  timeout       = 30

  environment {
    variables = {
      SECRET_ID = var.secrets_manager_secret_name
    }
  }
  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }
}

resource "aws_lambda_alias" "get_customer_details_dev_alias" {
  name             = "dev"
  function_name    = aws_lambda_function.get_customer_recommender_profile_details.function_name
  function_version = "$LATEST"
  description      = "Development alias for getting recommender products and profile details of the customer"
}
