variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "first_public_subnet_id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "private_route_table_id" {
  description = "The ID of the private route table associated with the VPC"
  type        = string
}
