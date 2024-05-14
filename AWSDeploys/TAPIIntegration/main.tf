module "lambda"  {
  source = "./modules/lambda"

  providers = {
    aws = aws.development
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_name              = "ue1api-${var.stage_name}-${var.project_name}"
  api_description       = "Tapi Integration"
  resource_path         = "tapi"
  stage_name            = var.stage_name
  providers = {
    aws = aws.development
  }
}