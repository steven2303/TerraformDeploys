resource "aws_lambda_function" "lambda_trigger_glue_job" {
  function_name = var.lambda_trigger_glue_job_name 
  handler       = "TriggerMatrixModelGlueJob.lambda_handler"
  role          = var.lambda_role_arn
  runtime       = "python3.10"

  # Assuming you have a ZIP file with your Lambda code
  filename      = "scripts/Lambda/TriggerMatrixModelGlueJob.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/TriggerMatrixModelGlueJob.zip")
  # Add necessary environment variables, e.g., the Glue job name
  environment {
    variables = {
      GLUE_JOB_NAME1 = var.glue_job_name1
      GLUE_JOB_NAME2 = var.glue_job_name2
      GLUE_JOB_NAME3 = var.glue_job_name3
      PREFIXES_JOB1 = jsonencode(var.s3_matrix_models_prefixes_list1)
      PREFIXES_JOB2 = jsonencode(var.s3_matrix_models_prefixes_list2)
      PREFIXES_JOB3 = jsonencode(var.s3_matrix_models_prefixes_list3)
    }
  }
}

# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_trigger_glue_job.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_matrix_models_bucket_name}"
}

resource "aws_lambda_function" "lambda_execute_sql_ddl" {
  function_name = var.lambda_execute_sql_ddl_name
  handler       = "ExecuteSQLDDL.lambda_handler"
  runtime       = "python3.10"
  role          = var.lambda_role_arn
  memory_size           = 128
  timeout               = 30
  filename         = "scripts/Lambda/ExecuteSQLDDL.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/ExecuteSQLDDL.zip")
  layers        = ["arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSSDKPandas-Python310:11"]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      RESOURCE_BUCKET = var.s3_resources_bucket_name
      DDL_KEY = var.s3_ddl_key
      SECRETS_MANAGER_SECRET_NAME = var.secrets_manager_secret_name
    }
  }
}

resource "aws_lambda_permission" "allow_eventbridge_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_execute_sql_ddl.function_name
  principal     = "events.amazonaws.com"
  source_arn    = var.rds_instance_creation_rule_arn
}

resource "aws_lambda_function" "lambda_invoke_model1" {
  function_name = var.lambda_invoke_model1_name 
  handler       = "LambdaInvokeModel1.lambda_handler"
  runtime       = "python3.10"
  role          = var.lambda_role_arn
  memory_size           = 4000
  timeout               = 900
  filename         = "scripts/Lambda/LambdaInvokeModel1.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/LambdaInvokeModel1.zip")
  layers        = ["arn:aws:lambda:${data.aws_region.current.name}:336392948345:layer:AWSSDKPandas-Python310:11"]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  ephemeral_storage {
    size = 3000
  }

  environment {
    variables = {
      ARTIFACTS_BUCKET_NAME = var.s3_resources_bucket_name
      DATA_BUCKET_NAME = var.s3_matrix_models_bucket_name
      PREFIX_PROCESSING_ARTIFACTS = var.prefix_processing_artifacts
      PREFIX_SKU_CATALOG = var.prefix_sku_catalog
      SECRETS_MANAGER_NAME = var.secrets_manager_secret_name
    }
  }
}

resource "aws_lambda_function" "lambda_execute_client_group_prediction" {
  function_name = var.lambda_execute_client_group_prediction_name 
  handler       = "ExecuteClientGroupPrediction.lambda_handler"
  role          = var.lambda_role_arn
  runtime       = "python3.10"
  memory_size           = 512
  timeout               = 900
  filename      = "scripts/Lambda/ExecuteClientGroupPrediction.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/ExecuteClientGroupPrediction.zip")
  ephemeral_storage {
    size = 512
  }
  environment {
    variables = {
      BUCKET_NAME = var.s3_resources_bucket_name
      PREFIX_PROCESSING_ARTIFACTS = var.prefix_processing_artifacts
      LAMBDA_ARN_MODEL1 = aws_lambda_function.lambda_invoke_model1.arn 
      LAMBDA_ARN_MODEL2 = aws_lambda_function.lambda_invoke_model2.arn 
      LAMBDA_ARN_NLP_MODEL_TRAINING = aws_lambda_function.lambda_train_nltk_model.arn 
      GLUE_JOB = var.non_redeeming_clients_glue_job_name
    }
  }
}

# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke_model" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_execute_client_group_prediction.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_resources_bucket_name}"
}

resource "aws_lambda_permission" "allow_s3_catalog_invoke_model" {
  statement_id  = "AllowExecutionFromS3-catalog"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_execute_client_group_prediction.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.s3_matrix_models_bucket_name}"
}

resource "aws_lambda_layer_version" "scikit_learn" {
  layer_name          = "scikit_learn"
  description         = "Capa de scikit learn"
  compatible_runtimes = ["python3.10"]
  compatible_architectures = ["x86_64"]
  s3_bucket           = var.s3_resources_bucket_name
  s3_key              = "scripts/Layer/sklearn.zip"
  # source_code_hash    = filebase64sha256("scripts/Layer/sklearn.zip")
  depends_on = [
    var.output_layer
  ]
}

resource "aws_lambda_function" "lambda_invoke_model2" {
  function_name = var.lambda_invoke_model2_name 
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"
  role          = var.lambda_role_arn
  memory_size           = 3000
  timeout               = 900
  filename         = "scripts/Lambda/LambdaInvokeModel2.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/LambdaInvokeModel2.zip")
  layers = [
    aws_lambda_layer_version.scikit_learn.arn
  ]
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
  ephemeral_storage {
    size = 1000
  }
  environment {
    variables = {
      RESOURCES_BUCKET_NAME = var.s3_resources_bucket_name
      DATA_BUCKET_NAME = var.s3_matrix_models_bucket_name
      PREFIX_PROCESSING_ARTIFACTS = var.prefix_processing_artifacts
      SECRETS_MANAGER_NAME = var.secrets_manager_secret_name
      PREFIX_SKU_CATALOG = var.prefix_sku_catalog
    }
  }
}

resource "aws_lambda_function" "lambda_train_nltk_model" {
  function_name = var.lambda_train_nltk_model_name 
  handler       = "lambda_function.lambda_handler"
  role          = var.lambda_role_arn
  runtime       = "python3.10"
  memory_size           = 512
  timeout               = 120
  filename      = "scripts/Lambda/TrainNLPModel.zip"
  source_code_hash = filebase64sha256("scripts/Lambda/TrainNLPModel.zip")
  ephemeral_storage {
    size = 512
  }
  layers = [
    aws_lambda_layer_version.scikit_learn.arn
  ]
  environment {
    variables = {
      DATA_BUCKET_NAME = var.s3_matrix_models_bucket_name
      RESOURCES_BUCKET_NAME = var.s3_resources_bucket_name
      PREFIX_PROCESSING_ARTIFACTS = var.prefix_processing_artifacts
      PREFIX_SKU_CATALOG = var.prefix_sku_catalog
    }
  }
}
