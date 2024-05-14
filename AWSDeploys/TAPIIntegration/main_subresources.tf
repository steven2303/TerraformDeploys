module "customer_products_recommender_and_profile_api" {
  source = "./modules/api_subresources/obtener_companias"
  http_method           = "POST"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn
  resource_path         = "obtener_companias"

  function_name         = "tapi_obtener_compania"
  handler               = "tapi_obtener_compania.lambda_handler"
  runtime               = "python3.10"
  filename              = "resources/scripts/tapi_obtener_compania.zip"
  source_code_hash = filebase64sha256("resources/scripts/tapi_obtener_compania.zip")

  layers = [
    #aws_lambda_layer_version.pg8000.arn,
    module.lambda.dependencias_layer_arn,
    "arn:aws:lambda:us-east-2:577585731673:layer:pg8000:221",
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:14"
  ]
  memory_size           = 128
  timeout               = 30

  subnet_ids         = ["subnet-0055251db610c9dd6"] 
  security_group_ids = ["sg-0cc730e48311db0c3"]   
  alias_name         = "dev"
  alias_description  = "Development alias"
  providers = {
    aws = aws.development
  }
}

module "api_obtener_detalle_compania" {
  source = "./modules/api_subresources/obtener_detalle_compania"
  http_method           = "POST"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn
  resource_path         = "obtener_detalle_compania"

  function_name         = "tapi_obtener_detalle_compania"
  handler               = "tapi_obtener_detalle_compania.lambda_handler"
  runtime               = "python3.10"
  filename              = "resources/scripts/tapi_obtener_detalle_compania.zip"
  source_code_hash = filebase64sha256("resources/scripts/tapi_obtener_detalle_compania.zip")

  layers = [
    #aws_lambda_layer_version.pg8000.arn,
    module.lambda.dependencias_layer_arn,
    "arn:aws:lambda:us-east-2:577585731673:layer:pg8000:221",
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:14"
  ]
  memory_size           = 128
  timeout               = 30

  subnet_ids         = ["subnet-0055251db610c9dd6"] 
  security_group_ids = ["sg-0cc730e48311db0c3"]   
  alias_name         = "dev"
  alias_description  = "Development alias"
  providers = {
    aws = aws.development
  }
}

module "api_obtener_detalle_pago" {
  source = "./modules/api_subresources/obtener_detalle_pago"
  http_method           = "POST"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn
  resource_path         = "obtener_detalle_pago"

  function_name         = "tapi_obtener_detalle_pago"
  handler               = "tapi_obtener_detalle_pago.lambda_handler"
  runtime               = "python3.10"
  filename              = "resources/scripts/tapi_obtener_detalle_pago.zip"
  source_code_hash = filebase64sha256("resources/scripts/tapi_obtener_detalle_pago.zip")

  layers = [
    #aws_lambda_layer_version.pg8000.arn,
    module.lambda.dependencias_layer_arn,
    "arn:aws:lambda:us-east-2:577585731673:layer:pg8000:221",
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:14"
  ]
  memory_size           = 128
  timeout               = 30

  subnet_ids         = ["subnet-0055251db610c9dd6"] 
  security_group_ids = ["sg-0cc730e48311db0c3"]   
  alias_name         = "dev"
  alias_description  = "Development alias"
  providers = {
    aws = aws.development
  }
}


module "api_obtener_estatus_pago" {
  source = "./modules/api_subresources/obtener_estatus_pago"
  http_method           = "POST"
  stage_name            = var.stage_name
  parent_id             = module.api_gateway.tapi_resource_id
  parent_path           = module.api_gateway.tapi_resource_name
  api_id                = module.api_gateway.tapi_api_id
  api_arn               = module.api_gateway.tapi_api_arn
  resource_path         = "obtener_estatus_pago"

  function_name         = "tapi_obtener_estatus_pago"
  handler               = "tapi_obtener_estatus_pago.lambda_handler"
  runtime               = "python3.10"
  filename              = "resources/scripts/tapi_obtener_estatus_pago.zip"
  source_code_hash = filebase64sha256("resources/scripts/tapi_obtener_estatus_pago.zip")

  layers = [
    #aws_lambda_layer_version.pg8000.arn,
    module.lambda.dependencias_layer_arn,
    "arn:aws:lambda:us-east-2:577585731673:layer:pg8000:221",
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python310:14"
  ]
  memory_size           = 128
  timeout               = 30

  subnet_ids         = ["subnet-0055251db610c9dd6"] 
  security_group_ids = ["sg-0cc730e48311db0c3"]   
  alias_name         = "dev"
  alias_description  = "Development alias"
  providers = {
    aws = aws.development
  }
}