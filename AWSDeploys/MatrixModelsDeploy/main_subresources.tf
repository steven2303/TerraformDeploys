module "customer_products_recommender_and_profile_api" {
  source = "./modules/api_subresources/products_recommender_and_profile"
  resource_path         = "recommender-profile"
  http_method           = "GET"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn

  function_name         = "ue1com${var.stage_name}lmbflm003"
  handler               = "GetCustomerRecommenderProfileDetails.lambda_handler"
  runtime               = "python3.10"
  filename              = "scripts/Lambda/GetCustomerRecommenderProfileDetails.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/GetCustomerRecommenderProfileDetails.zip")

  role_arn              = module.role.lambda_role_arn
  layers                = ["arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size           = 128
  timeout               = 5
  environment_variables = {
    secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  }
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.security_group.lambda_security_group_id]
  alias_name         = "dev"
  alias_description  = "Development alias for getting recommender products and profile details of the customer"
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  providers = {
    aws = aws.oregon
  }
  depends_on = [module.role.lambda_vpc_access_policy_attachment_id]
}

module "customer_churn_reentry_and_newpartner_api" {
  source = "./modules/api_subresources/customer_churn_reentry_and_cross"
  resource_path         = "churn-reentry-cross"
  http_method           = "GET"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn

  function_name         = "ue1com${var.stage_name}lmbflm004"
  handler               = "GetCustomerChurnReEntryCrossDetails.lambda_handler"
  runtime               = "python3.10"
  filename              = "scripts/Lambda/GetCustomerChurnReEntryCrossDetails.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/GetCustomerChurnReEntryCrossDetails.zip")

  role_arn              = module.role.lambda_role_arn
  layers                = ["arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size           = 128
  timeout               = 5
  environment_variables = {
    secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  }
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.security_group.lambda_security_group_id]
  alias_name         = "dev"
  alias_description  = "Development alias for getting customer churn, re-entry and cross predections details"
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  providers = {
    aws = aws.oregon
  }
  depends_on = [module.role.lambda_vpc_access_policy_attachment_id]
}

module "products_recommender" {
  source = "./modules/api_subresources/products_recommender"
  resource_path         = "sku-recommender"
  http_method           = "GET"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn

  function_name         = "ue1com${var.stage_name}lmbflm007"
  handler               = "GetSkuRecommendationDetails.lambda_handler"
  runtime               = "python3.10"
  filename              = "scripts/Lambda/GetSkuRecommendationDetails.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/GetSkuRecommendationDetails.zip")

  role_arn              = module.role.lambda_role_arn
  layers                = ["arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size           = 128
  timeout               = 5
  environment_variables = {
    secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  }
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.security_group.lambda_security_group_id]
  alias_name         = "dev"
  alias_description  = "Development alias for getting SKU recommendations to non-redeemed and redeemed clients"
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  providers = {
    aws = aws.oregon
  }
  depends_on = [module.role.lambda_vpc_access_policy_attachment_id]
}
