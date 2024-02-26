# VPC Settings
vpc_cidr_block = "10.0.0.0/16"
internet_cidr_block = "0.0.0.0/0"
# Subnet Settings
subnet_newbits = 4
# Security Group Settings
aurora_sg_allowed_ips = ["190.235.10.8/32"] #190.235.10.8
# Aurora RDS Setting
aurora_engine = "aurora-postgresql"
aurora_engine_version = "14.6"
aurora_database_name = "fast_layer_db"
aurora_master_username = "fast_layer_admin"
cluster_instance_count = 1
aurora_instance_class = "db.r5.large"