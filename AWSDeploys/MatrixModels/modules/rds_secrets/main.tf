resource "random_password" "db_password" {
  length           = 16
  special          = true
  #override_special = "_%@"
}

resource "aws_secretsmanager_secret" "fast_layer_credentials" {
  name = "fast_layer_credentials"
}

resource "aws_secretsmanager_secret_version" "fast_layer_credentials_version" {
  secret_id     = aws_secretsmanager_secret.fast_layer_credentials.id
  secret_string = jsonencode({
    DBUser = var.aurora_master_username
    DBPassword = random_password.db_password.result
    DBHost = aws_rds_cluster.aurora_cluster.endpoint
    DBName = var.aurora_database_name 
  })
  depends_on   = [aws_rds_cluster.aurora_cluster]
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "auroradb-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "AuroraDBSubnetGroup"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "fast-layer-aurora-cluster"
  engine                 = var.aurora_engine 
  engine_version         = var.aurora_engine_version 
  database_name          = var.aurora_database_name 
  master_username        = var.aurora_master_username
  master_password        = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [var.aurora_security_group_id]
  skip_final_snapshot    = true
  #final_snapshot_identifier = "fast-layer-aurora-cluster-final-snapshot"
  storage_encrypted = true
  #kms_key_id        = aws_kms_key.db_key.id
  #backup_retention_period = 7
  #preferred_backup_window = "07:00-09:00"
  #enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  tags = {
    Name = "AuroraClusterDemo"
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.cluster_instance_count
  identifier          = "aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.aurora_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  tags = {
    Name = "AuroraInstance${count.index}"
  }
}
