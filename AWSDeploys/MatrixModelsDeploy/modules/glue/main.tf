resource "aws_glue_job" "glue_matrix_models_to_rds_etl_job1" {
  name     = var.glue_etl_job1_name 
  role_arn = var.glue_etl_role
  max_capacity = 1

  command {
    name            = "pythonshell"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/Glue/RDSUploadCustomerRecommenderProfileDetails.zip"
    python_version  = "3.9"
  }
  execution_property {
    max_concurrent_runs = 1
  }

  connections = [aws_glue_connection.fast_layer_aurora_connection.name]
  timeout = 60 
  default_arguments = {
    "--BUCKET_NAME"          = var.s3_matrix_models_bucket_name
    "--PREFIX_RECOMMENDER"  = var.prefix_recommender
    "--PREFIX_PROFILE"      = var.prefix_profile
    "--SECRET_NAME"          = var.secrets_manager_secret_name
    "--TABLE_NAME"           = "modelos_matrix.recomendador_producto_perfil"
    "--ScriptLocationHash"  = filebase64sha256("scripts/Glue/RDSUploadCustomerRecommenderProfileDetails.zip")
  }
}

resource "aws_glue_job" "glue_matrix_models_to_rds_etl_job2" {
  name     = var.glue_etl_job2_name 
  role_arn = var.glue_etl_role
  max_capacity = 1

  command {
    name            = "pythonshell"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/Glue/RDSUploadCustomerChurnReEntryNewPartner.zip"
    python_version  = "3.9"
  }
  execution_property {
    max_concurrent_runs = 1
  }

  connections = [aws_glue_connection.fast_layer_aurora_connection.name]
  timeout = 60 
  default_arguments = {
    "--BUCKET_NAME"          = var.s3_matrix_models_bucket_name
    "--PREFIX_CHURN"  = var.prefix_churn
    "--PREFIX_NEW_PARTNER"      = var.prefix_new_partner
    "--PREFIX_RE_ENTRY"      = var.prefix_re_entry
    "--SECRET_NAME"          = var.secrets_manager_secret_name
    "--TABLE_NAME"           = "modelos_matrix.desercion_reingreso_cross"
    "--ScriptLocationHash"  = filebase64sha256("scripts/Glue/RDSUploadCustomerChurnReEntryNewPartner.zip")
  }
}

resource "aws_glue_connection" "fast_layer_aurora_connection" {
  name = var.glue_aurora_connection_name 

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://${var.aurora_cluster_endpoint}/${var.aurora_database_name}"
    JDBC_ENFORCE_SSL    = "true"
    SECRET_ID           = var.secret_manager_id 
  }

  physical_connection_requirements {
    availability_zone      = var.glue_availability_zone
    security_group_id_list = [var.glue_security_group_id]
    subnet_id              = var.private_subnet_id
  }
}

resource "aws_glue_job" "glue_processing_artifacts_creation_job" {
  name                      = var.glue_etl_job3_name 
  role_arn                  = var.glue_etl_role
  glue_version              = "4.0"
  execution_property {
    max_concurrent_runs = 1
  }
  command {
    name            =  "glueetl"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/Glue/CustomerDataPreprocessing.zip"
    python_version  = "3"
  }
  default_arguments = {
    "--INPUT_BUCKET_NAME"  = var.s3_matrix_models_bucket_name
    "--ARTIFACTS_BUCKET_NAME"     = var.s3_resources_bucket_name
    "--PREFIX_CANJE" = var.prefix_canje
    "--PREFIX_DETALLE_CANJE"     = var.prefix_detalle_canje
    "--PREFIX_CLIENTE" = var.prefix_cliente
    "--SECRET_NAME"     = var.secrets_manager_secret_name
    "--PREFIX_PROCESSING_ARTIFACTS" = var.prefix_processing_artifacts
    "--ScriptLocationHash"  = filebase64sha256("scripts/Glue/CustomerDataPreprocessing.zip")
  }
  number_of_workers = 2
  worker_type       = "G.2X"
  timeout      = 2880
} 


resource "aws_glue_job" "non_redeeming_clients_glue_job" {
  name     = var.glue_etl_job4_name 
  role_arn = var.glue_etl_role
  max_capacity = 1

  command {
    name            = "pythonshell"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/Glue/RDSUploadSkuRecommender.zip"
    python_version  = "3.9"
  }
  execution_property {
    max_concurrent_runs = 1
  }

  connections = [aws_glue_connection.fast_layer_aurora_connection.name]
  timeout = 180
  default_arguments = {
    "--DATA_BUCKET_NAME"          = var.s3_matrix_models_bucket_name
    "--ARTIFACTS_BUCKET_NAME"  = var.s3_resources_bucket_name
    "--PREFIX_PROCESSING_ARTIFACTS"      = var.prefix_processing_artifacts
    "--PREFIX_SKU_CATALOG"      = var.prefix_sku_catalog
    "--SECRET_NAME"          = var.secrets_manager_secret_name
    "--TABLE_NAME"           = "modelos_matrix.recomendador_clientes"
    "--ScriptLocationHash"  = filebase64sha256("scripts/Glue/RDSUploadSkuRecommender.zip")
  }
}