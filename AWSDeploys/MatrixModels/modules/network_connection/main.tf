resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main-igw"
  }
}

#resource "aws_eip" "nat_eip" {
#}

#resource "aws_nat_gateway" "nat_gw" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id     = var.first_public_subnet_id

#  tags = {
#    Name = "MainNATGW"
#  }

#  depends_on = [
#    aws_eip.nat_eip,
#  ]
#}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [var.private_route_table_id]
  tags = {
    Name = "s3endpoint"
  }
}

resource "aws_vpc_endpoint" "secrets_manager_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [var.endpoint_subnet_id] 
  security_group_ids = [var.lambda_security_group_id] 
  tags = {
    Name = "secretmanagerendpoint"
  }
}
