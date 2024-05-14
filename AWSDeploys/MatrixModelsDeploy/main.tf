module "vpc" {
  source = "./modules/vpc"
  vpc_name = "ue1net${var.stage_name}vpcflm001"
  cidr_block = var.vpc_cidr_block
  providers = {
    aws = aws.oregon
  }
}

module "subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  public_subnet_name = "ue1net${var.stage_name}pubflm00"
  private_subnet_name = "ue1net${var.stage_name}priflm00"
  vpc_cidr_block = var.vpc_cidr_block
  subnet_newbits = var.subnet_newbits
  providers = {
    aws = aws.oregon
  }
}

module "network_connection" {
  source = "./modules/network_connection"
  vpc_id = module.vpc.vpc_id
  igw_name = "ue1net${var.stage_name}igwflm001"
  s3_endpoint_name = "ue1net${var.stage_name}vpeflm001"
  api_gateway_endpoint_name = "ue1net${var.stage_name}vpeflm002"
  secrets_manager_endpoint_name = "ue1net${var.stage_name}vpeflm003"
  lambda_endpoint_name = "ue1net${var.stage_name}vpeflm004"
  first_public_subnet_id = module.subnets.public_subnet_ids[0]
  private_route_table_id  = module.route_table.private_route_table_id
  endpoint_subnet_id = module.subnets.private_subnet_ids[0]
  lambda_security_group_id = module.security_group.lambda_security_group_id
  providers = {
    aws = aws.oregon
  }
}

module "security_group" {
  source = "./modules/security_group"
  arurora_security_group = "ue1seg${var.stage_name}sgpflm001"
  lambda_security_group = "ue1seg${var.stage_name}sgpflm002"
  vpc_id = module.vpc.vpc_id
  aurora_sg_allowed_ips = var.aurora_sg_allowed_ips
  providers = {
    aws = aws.oregon
  }
}

module "rds_secrets" {
  source = "./modules/rds_secrets"
  aurora_subnet_group_name = "ue1dba${var.stage_name}asgflm001"
  aurora_cluster_name = "ue1dba${var.stage_name}cluflm001"
  aurora_instance_name = "ue1dba${var.stage_name}insflm00"
  aurora_security_group_id = module.security_group.aurora_security_group_id
  aurora_engine = var.aurora_engine
  aurora_engine_version = var.aurora_engine_version
  aurora_database_name = var.aurora_database_name
  aurora_master_username = var.aurora_master_username
  private_subnet_ids = module.subnets.private_subnet_ids
  aurora_instance_class = var.aurora_instance_class
  secrets_manager_secret_name = "ue1seg${var.stage_name}secflm001"
  backup_retention_period = var.backup_retention_period
  providers = {
    aws = aws.oregon
  }
}

module "role"  {
  source = "./modules/role"
  secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  project_name = var.project_name
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  s3_resources_bucket_name = module.s3.s3_resources_bucket_name
  aurora_cluster_arn = module.rds_secrets.aurora_cluster_arn
  secrets_manager_secret_arn = module.rds_secrets.secrets_manager_secret_arn
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  glue_connection_name = module.glue.glue_connection_name
  lambda_security_group_name = module.security_group.lambda_security_group_name
  lambda_invoke_model1_arn = module.lambda.lambda_invoke_model1_arn
  lambda_invoke_model2_arn = module.lambda.lambda_invoke_model2_arn
  lambda_train_nltk_model_arn = module.lambda.lambda_train_nltk_model_arn
  stage_name = var.stage_name
  providers = {
    aws = aws.oregon
  }
}

module "route_table"  {
  source = "./modules/route_table"
  private_route_table_name = "ue1net${var.stage_name}rtbflm001"
  internet_cidr_block = var.internet_cidr_block
  igw_id = module.network_connection.igw_id
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  default_route_table_id  = module.vpc.default_route_table_id
  providers = {
    aws = aws.oregon
  }
}

module "glue"  {
  source = "./modules/glue"
  glue_etl_job1_name = "ue1com${var.stage_name}gluflm001"
  glue_etl_job2_name = "ue1com${var.stage_name}gluflm002"
  glue_etl_job3_name = "ue1com${var.stage_name}gluflm003"
  glue_etl_job4_name = "ue1com${var.stage_name}gluflm004"
  glue_aurora_connection_name = "ue1api${var.stage_name}gluflm001"
  s3_resources_bucket_name = module.s3.s3_resources_bucket_name
  glue_etl_role = module.role.lambda_role_arn
  secret_manager_id = module.rds_secrets.secret_manager_id
  private_subnet_id = module.subnets.private_subnet_ids[0]
  glue_security_group_id = module.security_group.lambda_security_group_id
  glue_availability_zone = module.subnets.private_subnet_azs[0]
  aurora_cluster_endpoint = module.rds_secrets.aurora_cluster_endpoint
  aurora_database_name = var.aurora_database_name
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  prefix_recommender = var.prefix_recommender
  prefix_profile = var.prefix_profile
  prefix_churn = var.prefix_churn
  prefix_new_partner = var.prefix_new_partner
  prefix_re_entry = var.prefix_re_entry
  prefix_canje = var.prefix_canje
  prefix_detalle_canje = var.prefix_detalle_canje
  prefix_cliente = var.prefix_cliente
  prefix_processing_artifacts = var.prefix_processing_artifacts
  prefix_sku_catalog = var.prefix_sku_catalog
  providers = {
    aws = aws.oregon
  }
  depends_on = [
    module.s3.s3_script_file_keys
  ]
}

module "s3" {
  source = "./modules/s3"
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  s3_prefix_trigger = "${split("/", var.prefix_recommender)[0]}/"
  lambda_s3_to_glue_trigger_arn = module.lambda.lambda_trigger_glue_job_arn
  s3_resources_bucket_name = "ue1stg${var.stage_name}as3flm003" #var.s3_resources_bucket_name  "ue1stgdevas3flm001" 
  perfil_despliegue = var.perfil_despliegue
  s3_prefix_trigger_preprocessing = var.prefix_detalle_canje
  s3_prefix_trigger_model = "${var.prefix_processing_artifacts}clients_dictionary/clients_dictionary.json"
  lambda_invoke_model1_arn = module.lambda.lambda_execute_client_group_prediction_arn
  prefix_sku_catalog = var.prefix_sku_catalog
  providers = {
    aws = aws.oregon
  }
}

module "lambda"  {
  source = "./modules/lambda"
  lambda_trigger_glue_job_name = "ue1com${var.stage_name}lmbflm001"
  lambda_execute_sql_ddl_name = "ue1com${var.stage_name}lmbflm002"
  lambda_execute_client_group_prediction_name = "ue1com${var.stage_name}lmbflm005"
  lambda_invoke_model1_name = "ue1com${var.stage_name}lmbflm006"
  lambda_invoke_model2_name = "ue1com${var.stage_name}lmbflm008"
  lambda_train_nltk_model_name = "ue1com${var.stage_name}lmbflm009"
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  glue_job_name1 = module.glue.glue_job_name1
  glue_job_name2 = module.glue.glue_job_name2
  glue_job_name3 = module.glue.glue_job_name3
  lambda_role_arn = module.role.lambda_role_arn
  s3_matrix_models_prefixes_list1 = [var.prefix_recommender, var.prefix_profile]
  s3_matrix_models_prefixes_list2 = [var.prefix_churn, var.prefix_new_partner, var.prefix_re_entry]
  s3_matrix_models_prefixes_list3 = [var.prefix_detalle_canje]
  s3_resources_bucket_name = module.s3.s3_resources_bucket_name
  s3_ddl_key = var.s3_ddl_key
  secrets_manager_secret_name = module.rds_secrets.secret_manager_name
  subnet_ids = module.subnets.private_subnet_ids
  rds_instance_creation_rule_arn = module.eventbridge.rds_instance_creation_rule_arn
  security_group_ids = [module.security_group.lambda_security_group_id]
  prefix_processing_artifacts = var.prefix_processing_artifacts
  prefix_sku_catalog = var.prefix_sku_catalog
  output_layer = module.s3.s3_script_file_keys
  non_redeeming_clients_glue_job_name = module.glue.non_redeeming_clients_glue_job_name
  providers = {
    aws = aws.oregon
  }
}


module "eventbridge" {
  source = "./modules/eventbridge"
  rds_creation_event_rule_name = "ue1api${var.stage_name}evtflm001"
  aurora_cluster_identifier = module.rds_secrets.aurora_cluster_identifier
  lambda_execute_sql_ddl_arn = module.lambda.lambda_execute_sql_ddl_arn
  providers = {
    aws = aws.oregon
  }
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_name              = "ue1api${var.stage_name}apiflm001"
  api_description       = "API for getting matrix models predictions results"
  resource_path         = "matrix_models"
  stage_name            = var.stage_name
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  account_b_id          = var.account_b_id
  providers = {
    aws = aws.oregon
  }
}