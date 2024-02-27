resource "aws_security_group" "aurora_sg" {
  name        = "AuroraRDSSecurityGroup"
  description = "Security Group for RDS Aurora PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    self        = true
  }

  # Permitir el tráfico desde una lista de direcciones IP, si la lista no está vacía
  dynamic "ingress" {
    for_each = length(var.aurora_sg_allowed_ips) > 0 ? [1] : []
    content {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.aurora_sg_allowed_ips
    }
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AuroraRDSSecurityGroup"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "LambdaSecurityGroup"
  description = "Security Group for the Lambda Functions"
  vpc_id = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LambdaSG"
  }
}