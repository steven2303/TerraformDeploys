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

module "gateway" {
  source = "./modules/gateway"
  vpc_id = module.vpc.vpc_id
  first_public_subnet_id = module.subnets.public_subnet_ids[0]
  providers = {
    aws = aws.oregon
  }
}

#module "rds" {
#  source = "./modules/rds"
#  private_subnet_ids = module.subnets.private_subnet_ids
#  vpc_id = module.vpc.vpc_id
#}

module "route_table"  {
  source = "./modules/route_table"
  internet_cidr_block = var.internet_cidr_block
  igw_id = module.gateway.igw_id
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.subnets.public_subnet_ids
  private_subnet_ids = module.subnets.private_subnet_ids
  nat_gateway_id = module.gateway.nat_gateway_id
  default_route_table_id  = module.vpc.default_route_table_id
  providers = {
    aws = aws.oregon
  }
}