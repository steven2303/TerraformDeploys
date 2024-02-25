output "vpc_id" {
  value = aws_vpc.main.id
}

output "default_route_table_id" {
  value = aws_vpc.main.default_route_table_id
}