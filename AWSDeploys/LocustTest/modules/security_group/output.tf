output "ec2_security_group_id" {
  description = "The ID of the Aurora RDS security group"
  value       = aws_security_group.ec2_sg.id
}

output "ec2_security_group_name" {
  value = aws_security_group.ec2_sg.name
}

