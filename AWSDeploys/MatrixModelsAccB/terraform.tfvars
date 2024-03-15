# Project Settings
project_name = "fast-layer-athenea-integration"
aws_region = "us-west-2"
perfil_despliegue = "bonus_account"
account_a_id = "577585731673"
lambda_execution_role_name_account_a = "cross-account-654654330879-api-access-role"
# VPC Settings
vpc_cidr_block = "10.0.0.0/16"
internet_cidr_block = "0.0.0.0/0"
# Subnet Settings
subnet_newbits = 4
# Security Group Settings
aurora_sg_allowed_ips = [] #190.235.10.8
# Stage deployment name
stage_name = "dev"