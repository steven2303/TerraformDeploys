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