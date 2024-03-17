# Project Settings
project_name = "matrix-models-integration"
aws_region = "us-west-2"
# VPC Settings
vpc_cidr_block = "10.0.0.0/16"
internet_cidr_block = "0.0.0.0/0"
# Subnet Settings
subnet_newbits = 4
# Security Group Settings
aurora_sg_allowed_ips = [] 
# Aurora RDS Setting
aurora_engine = "aurora-postgresql"
aurora_engine_version = "14.10"
aurora_database_name = "fast_layer_db"
aurora_master_username = "fast_layer_admin"
cluster_instance_count = 1
aurora_instance_class = "db.r5.large"  #db.r5.xlarge
backup_retention_period = 7
# S3 Setting
s3_matrix_models_bucket_name = "matrix-modelos-predictivos-west2"
prefix_recommender = "modelos_matrix/recomendacion_productos/"
prefix_profile = "modelos_matrix/perfil_bonus/"
prefix_churn = "modelos_matrix/fuga_clientes/"
prefix_new_partner = "modelos_matrix/nuevo_socio/"
prefix_re_entry = "modelos_matrix/reingreso_clientes/"
# Secret Manager
secrets_manager_secret_name = "fast_layer_credentials"
# Glue
s3_resources_bucket_name = "aws-glue-assets-577585731673-us-west-2"
# Stage deployment name
stage_name = "dev"
account_b_id = "654654330879"
lambda_execution_role_name_account_b = "LambdaExecutionRole" #  El rol debe existir para que la politica se cree correctamente # LambdaExecutionRole
