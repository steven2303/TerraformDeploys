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

module "lambda"  {
  source = "./modules/lambda"
  project_name = var.project_name
  lambda_subnet_ids = module.subnets.private_subnet_ids
  lambda_security_group_ids = [module.security_group.lambda_security_group_id]
  account_a_id = var.account_a_id
  lambda_execution_role_name_account_a = var.lambda_execution_role_name_account_a
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
  nat_gateway_id = module.network_connection.nat_gateway_id
  default_route_table_id  = module.vpc.default_route_table_id
  providers = {
    aws = aws.oregon
  }
}
