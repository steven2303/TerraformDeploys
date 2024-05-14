resource "aws_instance" "locust" {
  ami           = var.ami  # AMI de Amazon Linux 2, ajustar según la región
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key.key_name

  security_groups = [var.ec2_security_group_name]

  user_data = file("scripts/install_locust.sh")  # Script para instalar Locust

  tags = {
    Name = var.instance_name
  }
}


resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}
