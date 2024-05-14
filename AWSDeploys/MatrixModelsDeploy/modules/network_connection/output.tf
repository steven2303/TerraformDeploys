output "igw_id" {
  value = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway"
}

#output "nat_gateway_id" {
#  value       = aws_nat_gateway.nat_gw.id
#  description = "The ID of the NAT Gateway"
#}
