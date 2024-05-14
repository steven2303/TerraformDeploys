module "ec2" {
  source = "./modules/ec2"
  key_name = var.key_name
  instance_type = var.instance_type
  instance_name = var.instance_name
  ami = var.ami
  ec2_security_group_name = module.sg.ec2_security_group_name
  providers = {
    aws = aws.qa_region
  }
}

module "sg" {
  source = "./modules/security_group"
  ec2_security_group = var.ec2_security_group
  ec2_sg_allowed_ips = var.ec2_sg_allowed_ips
  providers = {
    aws = aws.qa_region
  }
}

