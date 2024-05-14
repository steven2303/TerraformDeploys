# Project Settings
project_name = "matrix-models-integration"
aws_region = "us-east-1"
perfil_despliegue = "bonus_account"
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
aurora_instance_class = "db.r5.large"  
backup_retention_period = 7
# S3 Setting
s3_matrix_models_bucket_name = "ue1stgdevas3flm001" 
prefix_recommender = "models/modelo_recomendacion_producto_cliente/"
prefix_profile = "models/modelo_perfil_cliente/"
prefix_churn = "models/modelo_fugas_cliente_socio/"
prefix_new_partner = "models/modelo_cross_cliente_socio/"
prefix_re_entry = "models/modelo_reingreso_cliente_socio/"
# Glue
#s3_resources_bucket_name = #"aws-glue-assets-654654330879-us-east-1" #aws-glue-assets-654654330879-us-east-1 #aws-glue-assets-577585731673-us-west-2
s3_ddl_key = "scripts/DDL/modelos_matrix.sql"
prefix_canje = "data/t_canje/"
prefix_detalle_canje = "data/t_detallecanje/"
prefix_cliente = "views/data/vm_datos_personales/"
prefix_processing_artifacts = "processing_artifacts/"
prefix_sku_catalog = "data/catalogos/CATALOGO_121.csv"
# Stage deployment name
stage_name = "dev"
account_b_id = "339713166451" #654654330879
lambda_execution_role_name_account_b = "bonus-qa-RoleLambda-LvTf9rIpBUe3" #LambdaExecutionRole
