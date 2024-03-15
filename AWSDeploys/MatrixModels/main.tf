module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr_block
  providers = {
    aws = aws.oregon
  }
}

module "subnets" {
  source = "./modules/subnet"
  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  subnet_newbits = var.subnet_newbits
  providers = {
    aws = aws.oregon
  }
}

module "network_connection" {
  source = "./modules/network_connection"
  vpc_id = module.vpc.vpc_id
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
  vpc_id = module.vpc.vpc_id
  aurora_sg_allowed_ips = var.aurora_sg_allowed_ips
  providers = {
    aws = aws.oregon
  }
}

module "rds_secrets" {
  source = "./modules/rds_secrets"
  aurora_security_group_id = module.security_group.aurora_security_group_id
  aurora_engine = var.aurora_engine
  aurora_engine_version = var.aurora_engine_version
  aurora_database_name = var.aurora_database_name
  aurora_master_username = var.aurora_master_username
  private_subnet_ids = module.subnets.private_subnet_ids
  aurora_instance_class = var.aurora_instance_class
  secrets_manager_secret_name = var.secrets_manager_secret_name
  providers = {
    aws = aws.oregon
  }
}

#module "lambda"  {
#  source = "./modules/lambda"
#  secrets_manager_secret_name = var.secrets_manager_secret_name
#  project_name = var.project_name
#  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
#  aurora_cluster_arn = module.rds_secrets.aurora_cluster_arn
#  secrets_manager_secret_arn = module.rds_secrets.secrets_manager_secret_arn
#  lambda_subnet_ids = module.subnets.private_subnet_ids
#  lambda_security_group_ids = [module.security_group.lambda_security_group_id]
#  providers = {
#    aws = aws.oregon
#  }
#}

module "role"  {
  source = "./modules/role"
  secrets_manager_secret_name = var.secrets_manager_secret_name
  project_name = var.project_name
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  aurora_cluster_arn = module.rds_secrets.aurora_cluster_arn
  secrets_manager_secret_arn = module.rds_secrets.secrets_manager_secret_arn
  account_b_id = var.account_b_id
  lambda_execution_role_name_account_b = var.lambda_execution_role_name_account_b
  glue_connection_name = module.glue.glue_connection_name
  lambda_security_group_name = module.security_group.lambda_security_group_name
  providers = {
    aws = aws.oregon
  }
}

module "route_table"  {
  source = "./modules/route_table"
  internet_cidr_block = var.internet_cidr_block
  igw_id = module.network_connection.igw_id
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  #nat_gateway_id = module.network_connection.nat_gateway_id
  default_route_table_id  = module.vpc.default_route_table_id
  providers = {
    aws = aws.oregon
  }
}

module "glue"  {
  source = "./modules/glue"
  s3_resources_bucket_name = var.s3_resources_bucket_name
  glue_etl_role = module.role.lambda_role_arn
  secret_manager_id = module.rds_secrets.secret_manager_id
  private_subnet_id = module.subnets.private_subnet_ids[0]
  glue_security_group_id = module.security_group.lambda_security_group_id
  glue_availability_zone = module.subnets.private_subnet_azs[0]
  aurora_cluster_endpoint = module.rds_secrets.aurora_cluster_endpoint
  aurora_database_name = var.aurora_database_name
  s3_matrix_models_bucket_name = var.s3_matrix_models_bucket_name
  secrets_manager_secret_name = var.secrets_manager_secret_name
  prefix_recommender = var.prefix_recommender
  prefix_profile = var.prefix_profile
  prefix_churn = var.prefix_churn
  prefix_new_partner = var.prefix_new_partner
  prefix_re_entry = var.prefix_re_entry
  providers = {
    aws = aws.oregon
  }
}
