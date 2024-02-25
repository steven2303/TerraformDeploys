resource "aws_route" "internet_access" {
  route_table_id         = var.default_route_table_id 
  destination_cidr_block = var.internet_cidr_block 
  gateway_id             = var.igw_id 
}

resource "aws_route_table_association" "public_rt_association" {
  for_each = {for idx, subnet_id in var.public_subnet_ids : idx => subnet_id}

  subnet_id      = each.value
  route_table_id = var.default_route_table_id 
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.internet_cidr_block
    nat_gateway_id  = var.nat_gateway_id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = {for idx, subnet_id in var.private_subnet_ids : idx => subnet_id}

  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}