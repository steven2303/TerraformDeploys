variable "vpc_id" {
  description = "VPC ID for the RDS security group"
  type        = string
}

variable "igw_id" {
  description = "The ID of the Internet Gateway"
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  type        = string
}

variable "internet_cidr_block" {
  description = "CIDR block for routing internet traffic"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of subnet IDs to associate with the public route table"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of subnet IDs to associate with the private route table"
  type        = list(string)
}

variable "default_route_table_id" {
  description = "The ID of the main route table associated with the VPC"
  type        = string
}
