resource "aws_security_group" "lambda_sg" {
  name        = "LambdaSecurityGroup"
  description = "Security Group for the Lambda Functions"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

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