output "private_route_table_id" {
  value       = aws_route_table.private_rt.id
  description = "The ID of the private route table"
}
