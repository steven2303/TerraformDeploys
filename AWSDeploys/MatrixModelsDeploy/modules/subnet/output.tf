output "public_subnet_ids" {
  value = [for s in aws_subnet.public_subnet : s.id]
  description = "A list of public subnet IDs"
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private_subnet : s.id]
  description = "A list of private subnet IDs"
}

output "private_subnet_azs" {
  value = [for subnet in aws_subnet.private_subnet : subnet.availability_zone]
}
