resource "aws_subnet" "public_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, count.index * 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.public_subnet_name}${count.index}"
  }
}


resource "aws_subnet" "private_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, var.subnet_newbits, count.index * 2 + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.private_subnet_name}${count.index}"
  }
}

