resource "aws_security_group" "rds_sg" {
  name        = "RDSSecurityGroup"
  description = "Security Group for RDS PostgreSQL instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["38.253.180.19/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDSSecurityGroup"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "RDSSubnetGroup"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "RDSSubnetGroup"
  }
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier     = "aurora-cluster-demo"
  engine                 = "aurora-postgresql"
  engine_version         = "14.6"
  database_name          = "app_demo"
  master_username        = "admin"
  master_password        = "securepassword"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true

  tags = {
    Name = "AuroraClusterDemo"
  }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = var.instance_count
  identifier          = "aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = var.instance_class
  engine              = aws_rds_cluster.aurora_cluster.engine
  engine_version      = aws_rds_cluster.aurora_cluster.engine_version

  tags = {
    Name = "AuroraInstance${count.index}"
  }
}