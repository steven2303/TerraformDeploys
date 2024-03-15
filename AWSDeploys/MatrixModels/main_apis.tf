module "customer_products_recommender_and_profile_api" {
  source = "./modules/api_rest/products_recommender_and_profile"
  api_name              = "customer-products-recommender-and-profile-api"
  api_description       = "API for getting customer recommender profile details"
  resource_path         = "products-recommender-and-profile"
  http_method           = "GET"
  stage_name            = var.stage_name

  function_name         = "GetCustomerRecommenderProfileDetails"
  handler               = "GetCustomerRecommenderProfileDetails.lambda_handler"
  runtime               = "python3.10"
  filename              = "scripts/GetCustomerRecommenderProfileDetails.zip"

  role_arn              = module.role.lambda_role_arn
  layers                = ["arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size           = 128
  timeout               = 30
  environment_variables = {
    secrets_manager_secret_name = var.secrets_manager_secret_name
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
  source = "./modules/api_rest/customer_churn_reentry_and_newpartner"
  api_name              = "customer-churn-reentry-and-newpartner-api"
  api_description       = "API for getting customer churn, reentry and newpartner prediction details"
  resource_path         = "churn-reentry-and-newpartner"
  http_method           = "GET"
  stage_name            = var.stage_name

  function_name         = "GetCustomerChurnReEntryNewPartnerDetails"
  handler               = "GetCustomerChurnReEntryNewPartnerDetails.lambda_handler"
  runtime               = "python3.10"
  filename              = "scripts/GetCustomerChurnReEntryNewPartnerDetails.zip"

  role_arn              = module.role.lambda_role_arn
  layers                = ["arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:11"]
  memory_size           = 128
  timeout               = 30
  environment_variables = {
    secrets_manager_secret_name = var.secrets_manager_secret_name
  }
  subnet_ids         = module.subnets.private_subnet_ids
  security_group_ids = [module.security_group.lambda_security_group_id]
  alias_name         = "dev"
  alias_description  = "Development alias for getting customer churn, re-entry and new partner predections details"
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  providers = {
    aws = aws.oregon
  }
  depends_on = [module.role.lambda_vpc_access_policy_attachment_id]
}

