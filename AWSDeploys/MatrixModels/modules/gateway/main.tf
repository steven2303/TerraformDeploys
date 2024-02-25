resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat_eip" {
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.first_public_subnet_id

  tags = {
    Name = "MainNATGW"
  }

  depends_on = [
    aws_eip.nat_eip,
  ]
}
