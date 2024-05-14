output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

output "secrets_manager_secret_arn" {
  description = "The ARN of the secret in AWS Secrets Manager"
  value       = aws_secretsmanager_secret.fast_layer_credentials.arn
}

output "aurora_cluster_arn" {
  description = "The ARN of the Aurora RDS cluster"
  value       = aws_rds_cluster.aurora_cluster.arn
}

output "secret_manager_id" {
  value = aws_secretsmanager_secret.fast_layer_credentials.id
}

output "aurora_cluster_identifier" {
  value = aws_rds_cluster.aurora_cluster.cluster_identifier
}

output "secret_manager_name" {
  value = aws_secretsmanager_secret.fast_layer_credentials.name
  description = "The name of the secret in Secrets Manager"
}