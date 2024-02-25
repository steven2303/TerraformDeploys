output "aurora_cluster_endpoint" {
  description = "The endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_reader_endpoint" {
  description = "The reader endpoint of the Aurora cluster"
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}