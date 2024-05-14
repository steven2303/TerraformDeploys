resource "random_password" "db_password" {
  length           = 16
  special          = true
}

resource "aws_secretsmanager_secret" "fast_layer_credentials" {
  name = var.secrets_manager_secret_name
}

resource "aws_secretsmanager_secret_version" "fast_layer_credentials_version" {
  secret_id     = aws_secretsmanager_secret.fast_layer_credentials.id
  secret_string = jsonencode({
    DBUser = var.aurora_master_username
    DBPassword = random_password.db_password.result
    DBHost = aws_rds_cluster.aurora_cluster.endpoint
    DBReaderHost = aws_rds_cluster.aurora_cluster.reader_endpoint
    DBName = var.aurora_database_name
  })
  depends_on   = [aws_rds_cluster.aurora_cluster]
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = var.aurora_subnet_group_name 
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = var.aurora_subnet_group_name
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = var.aurora_cluster_name 
  engine                 = var.aurora_engine 
  engine_version         = var.aurora_engine_version 
  database_name          = var.aurora_database_name 
  master_username        = var.aurora_master_username
  master_password        = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids = [var.aurora_security_group_id]
  skip_final_snapshot    = true
  final_snapshot_identifier = "fast-layer-aurora-cluster-final-snapshot"
  storage_encrypted = true
  backup_retention_period = var.backup_retention_period
  preferred_backup_window = "03:00-05:00"
  preferred_maintenance_window = "Sun:23:00-Mon:01:30"
  enable_http_endpoint   = true 
  tags = {
    Name = var.aurora_cluster_name
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.cluster_instance_count
  identifier          = "${var.aurora_instance_name}${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.aurora_instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version
  tags = {
    Name = "${var.aurora_instance_name}${count.index}"
  }
}
