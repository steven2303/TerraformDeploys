resource "aws_security_group" "ec2_sg" {
  name        = var.ec2_security_group 
  description = "Security group for Locust EC2 instance"

  # Permitir el tráfico desde una lista de direcciones IP, si la lista no está vacía
  dynamic "ingress" {
    for_each = length(var.ec2_sg_allowed_ips) > 0 ? var.ec2_sg_allowed_ips : []
    content {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  tags = {
    Name = var.ec2_security_group
  }
}

