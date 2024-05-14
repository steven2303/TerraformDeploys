# Project Settings
project_name = "testing-locust"
aws_region = "us-east-2"
perfil_despliegue = "qa_athenea"
# 
instance_type = "c5.2xlarge"
key_name = "dev_key"
instance_name = "Locust Load Testing Instance"
ami = "ami-09b90e09742640522"
ec2_security_group = "locust_security_group"
#
ec2_sg_allowed_ips = ["190.237.27.43/32"] 

#terraform output -raw private_key > mykey.pem