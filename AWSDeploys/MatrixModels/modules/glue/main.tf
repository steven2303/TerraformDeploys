resource "aws_glue_job" "glue_matrix_models_to_rds_etl_job1" {
  name     = "RDSUploadCustomerRecommenderProfileDetails"
  role_arn = var.glue_etl_role
  max_capacity = 1

  command {
    name            = "pythonshell"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/RDSUploadCustomerRecommenderProfileDetails.py"
    python_version  = "3.9"
  }
  execution_property {
    max_concurrent_runs = 2
  }

  connections = [aws_glue_connection.fast_layer_aurora_connection.name]
  timeout = 60 
  default_arguments = {
    "--BUCKET_NAME"          = var.s3_matrix_models_bucket_name
    "--PREFIX_RECOMMENDER"  = var.prefix_recommender
    "--PREFIX_PROFILE"      = var.prefix_profile
    "--SECRET_NAME"          = var.secrets_manager_secret_name
    "--TABLE_NAME"           = "modelos_matrix.recomendador_producto_perfil"
  }
}

resource "aws_glue_job" "glue_matrix_models_to_rds_etl_job2" {
  name     = "RDSUploadCustomerChurnReEntryNewPartner"
  role_arn = var.glue_etl_role
  max_capacity = 1

  command {
    name            = "pythonshell"
    script_location = "s3://${var.s3_resources_bucket_name}/scripts/RDSUploadCustomerChurnReEntryNewPartner.py"
    python_version  = "3.9"
  }
  execution_property {
    max_concurrent_runs = 2
  }

  connections = [aws_glue_connection.fast_layer_aurora_connection.name]
  timeout = 60 
  default_arguments = {
    "--BUCKET_NAME"          = var.s3_matrix_models_bucket_name
    "--PREFIX_CHURN"  = var.prefix_churn
    "--PREFIX_NEW_PARTNER"      = var.prefix_new_partner
    "--PREFIX_RE_ENTRY"      = var.prefix_re_entry
    "--SECRET_NAME"          = var.secrets_manager_secret_name
    "--TABLE_NAME"           = "modelos_matrix.desercion_reingreso_nuevosocio"
  }
}

resource "aws_glue_connection" "fast_layer_aurora_connection" {
  name = "fast-layer-aurora-connection"

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