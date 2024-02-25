output "aurora_security_group_id" {
  description = "The ID of the Aurora RDS security group"
  value       = aws_security_group.aurora_sg.id
}

