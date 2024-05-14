resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.igw_name 
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.private_route_table_id]
  tags = {
    Name = var.s3_endpoint_name 
  }
}

resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.endpoint_subnet_id] 
  security_group_ids = [var.lambda_security_group_id] 
  private_dns_enabled = true
  tags = {
    Name = var.secrets_manager_endpoint_name 
  }
}


resource "aws_vpc_endpoint" "api_gateway_endpoint" {
  vpc_id            = var.vpc_id  
  service_name      = "com.amazonaws.${data.aws_region.current.name}.execute-api"  
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.endpoint_subnet_id]
  security_group_ids = [var.lambda_security_group_id] 
  private_dns_enabled = true
  tags = {
    Name = var.api_gateway_endpoint_name 
  }
}

resource "aws_vpc_endpoint" "lambda_endpoint" {
  vpc_id            = var.vpc_id  
  service_name      = "com.amazonaws.${data.aws_region.current.name}.lambda"
  vpc_endpoint_type = "Interface"
  subnet_ids = [var.endpoint_subnet_id]
  security_group_ids = [var.lambda_security_group_id]
  private_dns_enabled = true
  tags = {
    Name = var.lambda_endpoint_name 
  }
}